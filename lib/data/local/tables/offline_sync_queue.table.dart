import 'package:drift/drift.dart';

/// Outbox mutation queue for synchronizing offline actions back to the server.
class OfflineSyncQueueTable extends Table {
  @override
  String get tableName => 'offline_sync_queue';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()();
  TextColumn get payloadJson => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
