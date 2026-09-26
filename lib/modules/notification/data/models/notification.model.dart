// lib/modules/notification/data/models/notification.model.dart
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

/// Representation of an in-app user notification in the mobile client.
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? link;
  final String? ctaText;
  final List<String> clients;
  final Map<String, dynamic> metadata;
  final bool read;
  final DateTime? readAt;
  final String? notificationId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String? get templateId => notificationId;
  bool get isIamUpdated =>
      metadata[NotificationKeys.type] == NotificationConstants.iamUpdated;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.link,
    this.ctaText,
    this.clients = const [
      AppConstants.platformWeb,
      AppConstants.platformMobile,
    ],
    this.metadata = const {},
    this.read = false,
    this.readAt,
    String? notificationId,
    String? templateId,
    required this.createdAt,
    this.updatedAt,
  }) : notificationId = notificationId ?? templateId;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      title: json[NotificationKeys.title]?.toString() ?? '',
      message: json[NotificationKeys.message]?.toString() ?? '',
      link: json[NotificationKeys.link]?.toString(),
      ctaText: json[NotificationKeys.ctaText]?.toString(),
      clients: json[NotificationKeys.clients] is List
          ? List<String>.from(json[NotificationKeys.clients] as List)
          : const [AppConstants.platformWeb, AppConstants.platformMobile],
      metadata: json[NotificationKeys.metadata] is Map
          ? Map<String, dynamic>.from(json[NotificationKeys.metadata] as Map)
          : const {},
      read: json[NotificationKeys.read] as bool? ?? false,
      readAt: AppDateTime.fromUtc(json[NotificationKeys.readAt]),
      notificationId:
          json[NotificationKeys.notificationId]?.toString() ??
          json[NotificationKeys.templateId]?.toString(),
      createdAt:
          AppDateTime.fromUtc(json[NotificationKeys.createdAt]) ??
          DateTime.now(),
      updatedAt: AppDateTime.fromUtc(json[NotificationKeys.updatedAt]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ApiKeys.id: id,
      NotificationKeys.title: title,
      NotificationKeys.message: message,
      NotificationKeys.link: link,
      NotificationKeys.ctaText: ctaText,
      NotificationKeys.clients: clients,
      NotificationKeys.metadata: metadata,
      NotificationKeys.read: read,
      NotificationKeys.readAt: AppDateTime.toUtcIso(readAt),
      NotificationKeys.notificationId: notificationId,
      NotificationKeys.templateId: notificationId,
      NotificationKeys.createdAt: AppDateTime.toUtcIso(createdAt),
      NotificationKeys.updatedAt: AppDateTime.toUtcIso(updatedAt),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? link,
    String? ctaText,
    List<String>? clients,
    Map<String, dynamic>? metadata,
    bool? read,
    DateTime? readAt,
    String? notificationId,
    String? templateId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      link: link ?? this.link,
      ctaText: ctaText ?? this.ctaText,
      clients: clients ?? this.clients,
      metadata: metadata ?? this.metadata,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
      notificationId: notificationId ?? templateId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
