import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/asset.model.dart';

class StorageDetails {
  final String storageKey;
  final int bytes;
  final String format;

  StorageDetails({
    required this.storageKey,
    required this.bytes,
    required this.format,
  });

  factory StorageDetails.fromJson(Map<String, dynamic> json) {
    return StorageDetails(
      storageKey: json[AssetKeys.storageKey]?.toString() ?? '',
      bytes: (json[AssetKeys.bytes] as num?)?.toInt() ?? 0,
      format: json[AssetKeys.format]?.toString() ?? '',
    );
  }
}

class AssetUploadResponse {
  final AssetModel asset;
  final StorageDetails storageDetails;

  AssetUploadResponse({
    required this.asset,
    required this.storageDetails,
  });

  factory AssetUploadResponse.fromJson(Map<String, dynamic> json) {
    final detailsRaw = json[AssetKeys.storageDetails];
    return AssetUploadResponse(
      asset:
          ApiHelper.parseRecord(json[AssetKeys.asset], AssetModel.fromJson) ??
          AssetModel.fromJson(const {}),
      storageDetails: detailsRaw is Map
          ? StorageDetails.fromJson(Map<String, dynamic>.from(detailsRaw))
          : StorageDetails(storageKey: '', bytes: 0, format: ''),
    );
  }
}
