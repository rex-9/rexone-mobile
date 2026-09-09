// test/services/speech_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/routes/routes.dart';

void main() {
  group('Speech Constants & Routes', () {
    test('SpeechKeys defines all necessary keys', () {
      expect(SpeechKeys.channel, equals('SpeechLiveChannel'));
      expect(SpeechKeys.action, equals('action'));
      expect(SpeechKeys.audio, equals('audio'));
      expect(SpeechKeys.ttsMediaId, equals('tts'));
      expect(SpeechKeys.audioUrl, equals('audio_url'));
      expect(SpeechKeys.text, equals('text'));
      expect(SpeechKeys.voiceName, equals('voice_name'));
      expect(SpeechKeys.messageId, equals('message_id'));
      expect(SpeechKeys.roomId, equals('room_id'));
      expect(SpeechKeys.jobId, equals('job_id'));
      expect(SpeechKeys.status, equals('status'));
      expect(SpeechKeys.chunk, equals('chunk'));
      expect(SpeechKeys.stop, equals('stop'));
      expect(SpeechKeys.partial, equals('partial'));
      expect(SpeechKeys.finalPhrase, equals('final'));
      expect(SpeechKeys.error, equals('error'));
    });

    test('ServerRoutes includes correct speech endpoints', () {
      expect(ServerRoutes.textToSpeech, equals('/v1/speech/tts'));
      expect(ServerRoutes.speechToText, equals('/v1/speech/stt'));
    });

    test('ESpeechEventType enums map correctly', () {
      expect(ESpeechEventType.values.length, greaterThanOrEqualTo(4));
      expect(ESpeechEventType.partial, isA<ESpeechEventType>());
      expect(ESpeechEventType.finalPhrase, isA<ESpeechEventType>());
      expect(ESpeechEventType.error, isA<ESpeechEventType>());
      expect(ESpeechEventType.unknown, isA<ESpeechEventType>());
    });

    test('ESpeechListenResult enum values exist', () {
      expect(ESpeechListenResult.values.length, greaterThanOrEqualTo(5));
      expect(ESpeechListenResult.started, isA<ESpeechListenResult>());
      expect(ESpeechListenResult.alreadyListening, isA<ESpeechListenResult>());
      expect(ESpeechListenResult.disconnected, isA<ESpeechListenResult>());
      expect(ESpeechListenResult.permissionDenied, isA<ESpeechListenResult>());
      expect(ESpeechListenResult.failed, isA<ESpeechListenResult>());
    });
  });
}
