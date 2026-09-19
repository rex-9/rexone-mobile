import 'package:drift/drift.dart';

/// SQLite table storing child assets (subtitles, thumbnails, attachments).
class LocalChildAssetsTable extends Table {
  @override
  String get tableName => 'local_child_assets';

  TextColumn get id => text()();
  TextColumn get parentAssetId => text()();
  TextColumn get name => text()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get url => text()();
  TextColumn get type => text().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get extension => text().nullable()();
  Int64Column get sizeBytes => int64().nullable()();
  TextColumn get localFilePath => text().nullable()();
  BoolColumn get isDownloaded =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
