import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

class VersionModel {
  final String id;
  final String number;
  final String? title;
  final String? description;
  final String? status;
  final DateTime? releasedAt;
  final bool updateRequired;
  final bool mustUpdate;
  final bool skipPremium;
  final String? storeUrl;

  VersionModel({
    required this.id,
    required this.number,
    this.title,
    this.description,
    this.status,
    this.releasedAt,
    this.updateRequired = false,
    this.mustUpdate = false,
    this.skipPremium = false,
    this.storeUrl,
  });

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      number: json[VersionKeys.number]?.toString() ?? '',
      title: json[VersionKeys.title] as String?,
      description: json[VersionKeys.description] as String?,
      status: json[VersionKeys.status] as String?,
      releasedAt: AppDateTime.fromUtc(json[VersionKeys.releasedAt]),
      updateRequired: json[VersionKeys.updateRequired] == true,
      mustUpdate: json[VersionKeys.mustUpdate] == true,
      skipPremium: json[VersionKeys.skipPremium] == true,
      storeUrl: json[VersionKeys.storeUrl] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ApiKeys.id: id,
      VersionKeys.number: number,
      if (title != null) VersionKeys.title: title,
      if (description != null) VersionKeys.description: description,
      if (status != null) VersionKeys.status: status,
      if (releasedAt != null)
        VersionKeys.releasedAt: AppDateTime.toUtcIso(releasedAt),
      VersionKeys.updateRequired: updateRequired,
      VersionKeys.mustUpdate: mustUpdate,
      VersionKeys.skipPremium: skipPremium,
      if (storeUrl != null) VersionKeys.storeUrl: storeUrl,
    };
  }
}
