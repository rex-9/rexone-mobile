// test/modules/ai/controllers/ai_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/ai/ai.dart';
import 'package:rexone_mobile/services/services.dart';
import '../../../mocks/test_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAiService fakeAi;
  late FakeSpeechService fakeSpeech;
  late FakePermissionService fakePermissions;
  late AiController controller;

  setUp(() {
    Get.testMode = true;
    fakeAi = FakeAiService();
    fakeSpeech = FakeSpeechService();
    fakePermissions = FakePermissionService();

    Get.put<AiService>(fakeAi);
    Get.put<SpeechService>(fakeSpeech);
    Get.put<PermissionService>(fakePermissions);

    controller = Get.put(AiController());
  });

  tearDown(() {
    Get.reset();
  });

  group('AiController - History & Messages', () {
    test('loadHistory provides default welcome greeting when history is empty', () async {
      fakeAi.historyResponse = const PaginatedResponse<AiMessageModel>(
        records: [],
        message: 'OK',
        statusCode: 200,
        success: true,
      );

      await controller.loadHistory();

      expect(controller.messages.length, equals(1));
      expect(controller.messages.first.id, equals('welcome'));
      expect(controller.messages.first.role, equals(EChatRole.assistant.name));
    });

    test('loadHistory loads message history and updates currentRoomId', () async {
      final mockMessages = [
        AiMessageModel(
          id: 'msg_1',
          role: EChatRole.user.name,
          content: 'Hello AI',
          roomId: 'room_abc',
          createdAt: DateTime.now().toIso8601String(),
        ),
        AiMessageModel(
          id: 'msg_2',
          role: EChatRole.assistant.name,
          content: 'Hello! How can I help?',
          roomId: 'room_abc',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ];

      fakeAi.historyResponse = PaginatedResponse<AiMessageModel>(
        records: mockMessages,
        message: 'OK',
        statusCode: 200,
        success: true,
      );

      await controller.loadHistory('room_abc');

      expect(controller.messages.length, equals(2));
      expect(controller.currentRoomId.value, equals('room_abc'));
      expect(controller.isProcessing.value, isFalse);
    });

    test('sendMessage creates optimistic message and posts to chat service', () async {
      fakeAi.chatResponse = ApiResponse.success(
        message: 'Queued',
        statusCode: 200,
        data: {AiKeys.roomId: 'room_123'},
      );

      await controller.sendMessage('Test message');

      expect(controller.messages.any((m) => m.content == 'Test message'), isTrue);
      expect(controller.currentRoomId.value, equals('room_123'));
    });

    test('sendMessage ignores whitespace-only message', () async {
      final countBefore = controller.messages.length;

      await controller.sendMessage('   ');

      expect(controller.messages.length, equals(countBefore));
    });
  });

  group('AiController - Room Management', () {
    test('loadRooms populates rooms list', () async {
      final mockRooms = [
        AiRoomModel(
          id: 'r_1',
          title: 'First Chat',
          messageCount: 5,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          processing: false,
        ),
      ];

      fakeAi.roomsResponse = PaginatedResponse<AiRoomModel>(
        records: mockRooms,
        message: 'OK',
        statusCode: 200,
        success: true,
      );

      await controller.loadRooms();

      expect(controller.rooms.length, equals(1));
      expect(controller.rooms.first.id, equals('r_1'));
      expect(controller.rooms.first.title, equals('First Chat'));
    });

    test('selectRoom updates room observables and triggers history reload', () {
      final room = AiRoomModel(
        id: 'r_selected',
        title: 'Project Discussion',
        messageCount: 10,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        processing: false,
      );

      controller.selectRoom(room);

      expect(controller.currentRoomId.value, equals('r_selected'));
      expect(controller.currentRoomTitle.value, equals('Project Discussion'));
    });

    test('createNewRoom creates and prepends room to list', () async {
      fakeAi.createRoomResponse = ApiResponse.success(
        message: 'Created',
        statusCode: 201,
        data: AiRoomModel(
          id: 'r_new',
          title: 'Custom Topic',
          messageCount: 0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          processing: false,
        ),
      );

      await controller.createNewRoom('Custom Topic');

      expect(controller.rooms.any((r) => r.id == 'r_new'), isTrue);
      expect(controller.currentRoomId.value, equals('r_new'));
    });

    test('deleteRoom removes room from rooms list and resets currentRoomId if deleted', () async {
      final room = AiRoomModel(
        id: 'r_del',
        title: 'To Delete',
        messageCount: 1,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        processing: false,
      );

      controller.rooms.assignAll([room]);
      controller.currentRoomId.value = 'r_del';

      fakeAi.deleteRoomResponse = ApiResponse.success(message: 'Deleted', statusCode: 200);

      await controller.deleteRoom('r_del');

      expect(controller.rooms, isEmpty);
      expect(controller.currentRoomId.value, isNull);
    });

    test('renameRoom updates room title in list and updates currentRoomTitle if matching', () async {
      final room = AiRoomModel(
        id: 'r_ren',
        title: 'Original Title',
        messageCount: 1,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        processing: false,
      );

      controller.rooms.assignAll([room]);
      controller.currentRoomId.value = 'r_ren';
      controller.currentRoomTitle.value = 'Original Title';

      fakeAi.renameRoomResponse = ApiResponse.success(
        message: 'Renamed',
        statusCode: 200,
        data: room.copyWith(title: 'Updated Title'),
      );

      await controller.renameRoom('r_ren', 'Updated Title');

      expect(controller.rooms.first.title, equals('Updated Title'));
      expect(controller.currentRoomTitle.value, equals('Updated Title'));
    });

    test('sendMessage extracts roomId from response.meta when provided', () async {
      fakeAi.chatResponse = ApiResponse.success(
        message: 'Queued',
        statusCode: 200,
        data: {},
        meta: {AiKeys.roomId: 'room_from_meta'},
      );

      await controller.sendMessage('Check meta room id');

      expect(controller.currentRoomId.value, equals('room_from_meta'));
    });
  });
}
