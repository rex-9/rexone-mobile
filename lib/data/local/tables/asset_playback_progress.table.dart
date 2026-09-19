import 'package:drift/drift.dart';

/// SQLite table storing local playback progress per asset and user.
class AssetPlaybackProgressTable extends Table {
  @override
  String get tableName => 'asset_playback_progress';

  TextColumn get assetId => text()();
  TextColumn get userId => text()();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {assetId, userId};
}
