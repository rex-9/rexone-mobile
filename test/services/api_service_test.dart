import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/services/api.service.dart';

class SampleItem {
  final String id;
  final String title;

  SampleItem({required this.id, required this.title});

  factory SampleItem.fromJson(Map<String, dynamic> json) {
    return SampleItem(
      id: json[ApiKeys.id]?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}

void main() {
  late ApiService apiService;

  setUp(() {
    apiService = ApiService();
  });

  group('ApiService.flattenRecord', () {
    test('flattens JSON:API resource with attributes and id', () {
      final jsonApi = {
        'id': 'res_123',
        'type': 'articles',
        'attributes': {
          'title': 'Hello World',
          'author': 'Rex',
        },
      };

      final flat = ApiService.flattenRecord(jsonApi);

      expect(flat['id'], 'res_123');
      expect(flat['title'], 'Hello World');
      expect(flat['author'], 'Rex');
      expect(flat.containsKey('attributes'), isFalse);
    });

    test('returns map as-is if no attributes key is present', () {
      final flat = {
        'id': 'res_456',
        'title': 'Already Flat',
      };

      final result = ApiService.flattenRecord(flat);

      expect(result['id'], 'res_456');
      expect(result['title'], 'Already Flat');
    });

    test('returns empty map when input is not a Map', () {
      expect(ApiService.flattenRecord(null), isEmpty);
      expect(ApiService.flattenRecord('not a map'), isEmpty);
      expect(ApiService.flattenRecord([1, 2, 3]), isEmpty);
    });
  });

  group('ApiService.parseRecord', () {
    test('parses successful JSON:API record with fromJson', () {
      final response = Response(
        statusCode: 200,
        body: {
          'status': {'code': 200, 'success': true, 'message': 'Loaded'},
          'data': {
            'id': 'item_1',
            'type': 'sample',
            'attributes': {'title': 'Sample Item 1'},
          },
          'meta': {'extra': 'info'},
        },
      );

      final result = apiService.parseRecord<SampleItem>(
        response,
        SampleItem.fromJson,
      );

      expect(result.success, isTrue);
      expect(result.statusCode, 200);
      expect(result.message, 'Loaded');
      expect(result.data, isNotNull);
      expect(result.data?.id, 'item_1');
      expect(result.data?.title, 'Sample Item 1');
      expect(result.meta?['extra'], 'info');
    });

    test('parses error response with server error details', () {
      final response = Response(
        statusCode: 422,
        body: {
          'status': {
            'code': 422,
            'success': false,
            'error': 'Entity unprocessable',
            'message': 'Failed validation',
          },
          'data': null,
        },
      );

      final result = apiService.parseRecord<SampleItem>(
        response,
        SampleItem.fromJson,
      );

      expect(result.success, isFalse);
      expect(result.statusCode, 422);
      expect(result.error, 'Entity unprocessable');
      expect(result.data, isNull);
    });
  });

  group('ApiService.parsePagyList', () {
    test('parses paginated list with JSON:API items and pagination meta', () {
      final response = Response(
        statusCode: 200,
        body: {
          'status': {'code': 200, 'success': true, 'message': 'Records loaded'},
          'data': [
            {
              'id': 'item_1',
              'type': 'sample',
              'attributes': {'title': 'First'},
            },
            {
              'id': 'item_2',
              'type': 'sample',
              'attributes': {'title': 'Second'},
            },
          ],
          'meta': {
            'pagination': {
              'current_page': 1,
              'total_pages': 5,
              'total_count': 50,
              'limit': 10,
              'next_page': 2,
              'prev_page': null,
            },
          },
        },
      );

      final result = apiService.parsePagyList<SampleItem>(
        response,
        SampleItem.fromJson,
      );

      expect(result.success, isTrue);
      expect(result.statusCode, 200);
      expect(result.records.length, 2);
      expect(result.records[0].id, 'item_1');
      expect(result.records[0].title, 'First');
      expect(result.records[1].id, 'item_2');
      expect(result.records[1].title, 'Second');
      expect(result.pagination, isNotNull);
      expect(result.pagination?.currentPage, 1);
      expect(result.pagination?.totalPages, 5);
      expect(result.pagination?.totalCount, 50);
      expect(result.pagination?.limit, 10);
      expect(result.pagination?.nextPage, 2);
      expect(result.pagination?.prevPage, isNull);
    });

    test('handles empty data list gracefully', () {
      final response = Response(
        statusCode: 200,
        body: {
          'status': {'code': 200, 'success': true, 'message': 'Empty'},
          'data': [],
        },
      );

      final result = apiService.parsePagyList<SampleItem>(
        response,
        SampleItem.fromJson,
      );

      expect(result.success, isTrue);
      expect(result.records, isEmpty);
      expect(result.pagination, isNull);
    });
  });
}
