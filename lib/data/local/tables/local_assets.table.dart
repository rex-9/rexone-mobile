import 'package:drift/drift.dart';

/// SQLite table storing local parent assets (videos, audios, and metadata).
class LocalAssetsTable extends Table {
  @override
  String get tableName => 'local_assets';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get url => text()();
  TextColumn get type => text()();
  TextColumn get format => text().nullable()();
  TextColumn get extension => text().nullable()();
  Int64Column get sizeBytes => int64().nullable()();
  IntColumn get durationSecs => integer().nullable()();
  TextColumn get source => text().withDefault(const Constant(''))();
  TextColumn get status => text().nullable()();
  TextColumn get assetableType => text().nullable()();
  TextColumn get assetableId => text().nullable()();
  TextColumn get parentAssetId => text().nullable()();
  TextColumn get createdById => text().nullable()();
  TextColumn get metadataJson => text().nullable()();
  TextColumn get childrenJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Download status & offline file location
  TextColumn get downloadState =>
      text().withDefault(const Constant('none'))();
  RealColumn get downloadProgress =>
      real().withDefault(const Constant(0.0))();
  TextColumn get localFilePath => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get downloadedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
