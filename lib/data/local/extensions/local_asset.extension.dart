import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import '../database.dart';

extension LocalAssetExtension on LocalAssetsTableData {
  /// Converts a persisted SQLite asset record and its children into an [AssetModel].
  AssetModel toAssetModel({
    List<LocalChildAssetsTableData> children = const [],
  }) {
    final subs = children
        .where(
          (c) =>
              c.extension == AssetKeys.extensionSrt ||
              c.format == AssetKeys.extensionSrt ||
              c.type == AssetKeys.typeSubtitle,
        )
        .map(
          (c) => ChildAssetModel(
            id: c.id,
            name: c.name,
            title: c.title,
            description: c.description,
            url: c.localFilePath != null && c.localFilePath!.isNotEmpty
                ? Uri.file(c.localFilePath!).toString()
                : c.url,
            type: c.type,
            format: c.format,
            extension: c.extension ?? AssetKeys.extensionSrt,
            sizeBytes: c.sizeBytes?.toInt(),
            status: AssetKeys.statusReady,
          ),
        )
        .toList();

    final thumbData = children
        .where(
          (c) =>
              c.type == AssetKeys.formatImage ||
              (c.format != null &&
                  AssetKeys.imageExtensions.contains(c.format)) ||
              (c.extension != null &&
                  AssetKeys.imageExtensions.contains(c.extension)),
        )
        .firstOrNull;
    final thumb = thumbData != null
        ? ChildAssetModel(
            id: thumbData.id,
            name: thumbData.name,
            title: thumbData.title,
            url:
                thumbData.localFilePath != null &&
                    thumbData.localFilePath!.isNotEmpty
                ? Uri.file(thumbData.localFilePath!).toString()
                : thumbData.url,
            type: thumbData.type,
            format: thumbData.format,
            extension: thumbData.extension,
            sizeBytes: thumbData.sizeBytes?.toInt(),
            status: AssetKeys.statusReady,
          )
        : null;

    Map<String, dynamic>? meta;
    if (metadataJson != null && metadataJson!.isNotEmpty) {
      try {
        meta = jsonDecode(metadataJson!) as Map<String, dynamic>?;
      } catch (_) {}
    }

    return AssetModel(
      id: id,
      name: name,
      title: title,
      description: description,
      url: localFilePath != null && localFilePath!.isNotEmpty
          ? Uri.file(localFilePath!).toString()
          : url,
      type: type,
      format: format,
      extension: extension,
      sizeBytes: sizeBytes?.toInt(),
      durationSecs: durationSecs,
      source: source,
      status: status ?? AssetKeys.statusReady,
      assetableType: assetableType,
      assetableId: assetableId,
      parentAssetId: parentAssetId,
      createdById: createdById,
      metadata: meta,
      createdAt: createdAt,
      updatedAt: updatedAt,
      thumbnail: thumb,
      subtitles: subs,
    );
  }
}

extension AssetModelToLocalExtension on AssetModel {
  /// Converts an [AssetModel] into a [LocalAssetsTableCompanion] for SQLite persistence.
  LocalAssetsTableCompanion toCompanion({
    String downloadState = EMediaDownloadState.defaultStorageValue,
    double downloadProgress = 0.0,
    String? localFilePath,
    DateTime? downloadedAt,
    String? errorMessage,
  }) {
    return LocalAssetsTableCompanion(
      id: Value(id),
      name: Value(name),
      title: Value(title),
      description: Value(description),
      url: Value(url),
      type: Value(type),
      format: Value(format),
      extension: Value(extension),
      sizeBytes: Value(sizeBytes != null ? BigInt.from(sizeBytes!) : null),
      durationSecs: Value(durationSecs),
      source: Value(source),
      status: Value(status),
      assetableType: Value(assetableType),
      assetableId: Value(assetableId),
      parentAssetId: Value(parentAssetId),
      createdById: Value(createdById),
      metadataJson: Value(metadata != null ? jsonEncode(metadata) : null),
      childrenJson: Value(children != null ? jsonEncode(children) : null),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      downloadState: Value(downloadState),
      downloadProgress: Value(downloadProgress),
      localFilePath: Value(localFilePath),
      errorMessage: Value(errorMessage),
      downloadedAt: Value(downloadedAt),
    );
  }
}

extension ChildAssetModelToLocalExtension on ChildAssetModel {
  /// Converts a [ChildAssetModel] into a [LocalChildAssetsTableCompanion] for SQLite persistence.
  LocalChildAssetsTableCompanion toCompanion(
    String parentAssetId, {
    String? localFilePath,
    bool isDownloaded = false,
  }) {
    return LocalChildAssetsTableCompanion(
      id: Value(id),
      parentAssetId: Value(parentAssetId),
      name: Value(name),
      title: Value(title),
      description: Value(description),
      url: Value(url),
      type: Value(type),
      format: Value(format),
      extension: Value(extension),
      sizeBytes: Value(sizeBytes != null ? BigInt.from(sizeBytes!) : null),
      localFilePath: Value(localFilePath),
      isDownloaded: Value(isDownloaded),
    );
  }
}
