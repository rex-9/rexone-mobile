import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:rexone_mobile/constants/constants.dart';

import 'tables/asset_playback_progress.table.dart';
import 'tables/local_assets.table.dart';
import 'tables/local_child_assets.table.dart';
import 'tables/offline_sync_queue.table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  LocalAssetsTable,
  LocalChildAssetsTable,
  AssetPlaybackProgressTable,
  OfflineSyncQueueTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'rexone_offline'));

  @override
  int get schemaVersion => 1;

  // ============================================================
  // PARENT ASSETS
  // ============================================================

  /// Inserts or replaces a parent asset record.
  Future<int> upsertAsset(LocalAssetsTableCompanion asset) {
    return into(localAssetsTable).insertOnConflictUpdate(asset);
  }

  /// Fetches a parent asset by ID.
  Future<LocalAssetsTableData?> getAssetById(String id) {
    return (select(localAssetsTable)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Watches a parent asset by ID reactively.
  Stream<LocalAssetsTableData?> watchAssetById(String id) {
    return (select(localAssetsTable)..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Returns all assets that have been successfully downloaded.
  Future<List<LocalAssetsTableData>> getDownloadedAssets() {
    return (select(localAssetsTable)
          ..where((tbl) => tbl.downloadState.equals(EMediaDownloadState.ready.storageValue))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.downloadedAt)]))
        .get();
  }

  /// Watches all downloaded assets reactively.
  Stream<List<LocalAssetsTableData>> watchDownloadedAssets() {
    return (select(localAssetsTable)
          ..where((tbl) => tbl.downloadState.equals(EMediaDownloadState.ready.storageValue))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.downloadedAt)]))
        .watch();
  }

  /// Returns all tracked local assets regardless of state.
  Future<List<LocalAssetsTableData>> getAllLocalAssets() {
    return select(localAssetsTable).get();
  }

  /// Watches all tracked local assets.
  Stream<List<LocalAssetsTableData>> watchAllLocalAssets() {
    return select(localAssetsTable).watch();
  }

  /// Updates download progress and state for an asset.
  Future<int> updateDownloadState({
    required String assetId,
    required String state,
    double? progress,
    String? localFilePath,
    String? errorMessage,
    DateTime? downloadedAt,
    int? sizeBytes,
  }) {
    return (update(localAssetsTable)..where((tbl) => tbl.id.equals(assetId)))
        .write(
      LocalAssetsTableCompanion(
        downloadState: Value(state),
        downloadProgress:
            progress != null ? Value(progress) : const Value.absent(),
        localFilePath:
            localFilePath != null ? Value(localFilePath) : const Value.absent(),
        errorMessage:
            errorMessage != null ? Value(errorMessage) : const Value.absent(),
        downloadedAt:
            downloadedAt != null ? Value(downloadedAt) : const Value.absent(),
        sizeBytes:
            sizeBytes != null ? Value(BigInt.from(sizeBytes)) : const Value.absent(),
      ),
    );
  }

  /// Returns downloaded assets filtered by polymorphic domain (e.g. Course, GymSession, MeditationPodcast).
  Future<List<LocalAssetsTableData>> getDownloadedAssetsByAssetable({
    required String assetableType,
    String? assetableId,
  }) {
    final query = select(localAssetsTable)
      ..where((tbl) =>
          tbl.downloadState.equals(EMediaDownloadState.ready.storageValue) &
          tbl.assetableType.equals(assetableType));
    if (assetableId != null && assetableId.isNotEmpty) {
      query.where((tbl) => tbl.assetableId.equals(assetableId));
    }
    return (query..orderBy([(tbl) => OrderingTerm.desc(tbl.downloadedAt)])).get();
  }

  /// Returns set of IDs of all assets currently ready offline.
  Future<Set<String>> getDownloadedAssetIds() async {
    final list = await (selectOnly(localAssetsTable)
          ..addColumns([localAssetsTable.id])
          ..where(localAssetsTable.downloadState.equals(EMediaDownloadState.ready.storageValue)))
        .get();
    return list.map((row) => row.read(localAssetsTable.id)!).toSet();
  }

  /// Deletes a parent asset and its child assets.
  Future<void> deleteAssetCascade(String assetId) async {
    await transaction(() async {
      await (delete(localChildAssetsTable)
            ..where((tbl) => tbl.parentAssetId.equals(assetId)))
          .go();
      await (delete(assetPlaybackProgressTable)
            ..where((tbl) => tbl.assetId.equals(assetId)))
          .go();
      await (delete(localAssetsTable)..where((tbl) => tbl.id.equals(assetId)))
          .go();
    });
  }

  // ============================================================
  // CHILD ASSETS (Subtitles, Thumbnails, Attachments)
  // ============================================================

  /// Inserts or replaces a child asset.
  Future<int> upsertChildAsset(LocalChildAssetsTableCompanion child) {
    return into(localChildAssetsTable).insertOnConflictUpdate(child);
  }

  /// Batch inserts or replaces multiple child assets.
  Future<void> upsertChildAssets(List<LocalChildAssetsTableCompanion> children) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(localChildAssetsTable, children);
    });
  }

  /// Gets all child assets for a given parent asset ID.
  Future<List<LocalChildAssetsTableData>> getChildAssets(String parentAssetId) {
    return (select(localChildAssetsTable)
          ..where((tbl) => tbl.parentAssetId.equals(parentAssetId)))
        .get();
  }

  /// Watches all child assets for a given parent asset ID.
  Stream<List<LocalChildAssetsTableData>> watchChildAssets(String parentAssetId) {
    return (select(localChildAssetsTable)
          ..where((tbl) => tbl.parentAssetId.equals(parentAssetId)))
        .watch();
  }

  /// Updates local file path and downloaded flag for a child asset.
  Future<int> markChildAssetDownloaded({
    required String childId,
    required String localFilePath,
  }) {
    return (update(localChildAssetsTable)
          ..where((tbl) => tbl.id.equals(childId)))
        .write(
      LocalChildAssetsTableCompanion(
        localFilePath: Value(localFilePath),
        isDownloaded: const Value(true),
      ),
    );
  }

  // ============================================================
  // PLAYBACK PROGRESS
  // ============================================================

  /// Saves or updates the playback progress of an asset for a user.
  Future<int> savePlaybackProgress({
    required String assetId,
    required String userId,
    required int positionMs,
    required int durationMs,
    bool isCompleted = false,
  }) {
    final now = DateTime.now();
    return into(assetPlaybackProgressTable).insertOnConflictUpdate(
      AssetPlaybackProgressTableCompanion(
        assetId: Value(assetId),
        userId: Value(userId),
        positionMs: Value(positionMs),
        durationMs: Value(durationMs),
        isCompleted: Value(isCompleted),
        completedAt: isCompleted ? Value(now) : const Value.absent(),
        isSynced: const Value(false),
        updatedAt: Value(now),
      ),
    );
  }

  /// Gets playback progress for an asset and user.
  Future<AssetPlaybackProgressTableData?> getPlaybackProgress(
    String assetId,
    String userId,
  ) {
    return (select(assetPlaybackProgressTable)
          ..where(
            (tbl) => tbl.assetId.equals(assetId) & tbl.userId.equals(userId),
          ))
        .getSingleOrNull();
  }

  // ============================================================
  // OUTBOX SYNC QUEUE
  // ============================================================

  /// Enqueues an offline action into the outbox.
  Future<int> enqueueSyncMutation({
    required String actionType,
    required String payloadJson,
  }) {
    return into(offlineSyncQueueTable).insert(
      OfflineSyncQueueTableCompanion(
        actionType: Value(actionType),
        payloadJson: Value(payloadJson),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  /// Gets all pending sync mutations ordered by creation time.
  Future<List<OfflineSyncQueueTableData>> getPendingSyncMutations() {
    return (select(offlineSyncQueueTable)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
        .get();
  }

  /// Removes a completed sync mutation from the queue.
  Future<int> removeSyncMutation(int id) {
    return (delete(offlineSyncQueueTable)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  /// Increments retry attempt on a sync mutation.
  Future<int> incrementSyncAttempt(int id) {
    return customUpdate(
      'UPDATE offline_sync_queue SET attempts = attempts + 1, last_attempt_at = ? WHERE id = ?',
      variables: [
        Variable.withDateTime(DateTime.now()),
        Variable.withInt(id),
      ],
      updates: {offlineSyncQueueTable},
    );
  }

  /// Clears all offline tables (for development reset or full wipe).
  Future<void> clearAllOfflineData() async {
    await transaction(() async {
      await delete(offlineSyncQueueTable).go();
      await delete(assetPlaybackProgressTable).go();
      await delete(localChildAssetsTable).go();
      await delete(localAssetsTable).go();
    });
  }
}
