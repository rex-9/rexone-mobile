// lib/modules/notification/data/models/notification.model.dart
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

/// Representation of an in-app user notification in the mobile client.
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? link;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime? readAt;
  final String? notificationId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String? get templateId => notificationId;
  bool get isIamUpdated =>
      data[NotificationKeys.type] == NotificationConstants.iamUpdated;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.link,
    this.data = const {},
    this.read = false,
    this.readAt,
    String? notificationId,
    String? templateId,
    required this.createdAt,
    this.updatedAt,
  }) : notificationId = notificationId ?? templateId;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Handle JSONAPI style or flat map
    final attributes = json[ApiKeys.attributes] is Map
        ? Map<String, dynamic>.from(json[ApiKeys.attributes] as Map)
        : json;

    final id =
        json[ApiKeys.id]?.toString() ??
        attributes[ApiKeys.id]?.toString() ??
        '';

    return NotificationModel(
      id: id,
      title: attributes[NotificationKeys.title]?.toString() ?? '',
      message: attributes[NotificationKeys.message]?.toString() ?? '',
      link: attributes[NotificationKeys.link]?.toString(),
      data: attributes[NotificationKeys.data] is Map
          ? Map<String, dynamic>.from(attributes[NotificationKeys.data] as Map)
          : const {},
      read: attributes[NotificationKeys.read] as bool? ?? false,
      readAt: AppDateTime.fromUtc(attributes[NotificationKeys.readAt]),
      notificationId:
          attributes[NotificationKeys.notificationId]?.toString() ??
          attributes[NotificationKeys.templateId]?.toString(),
      createdAt:
          AppDateTime.fromUtc(attributes[NotificationKeys.createdAt]) ??
          DateTime.now(),
      updatedAt: AppDateTime.fromUtc(attributes['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ApiKeys.id: id,
      NotificationKeys.title: title,
      NotificationKeys.message: message,
      NotificationKeys.link: link,
      NotificationKeys.data: data,
      NotificationKeys.read: read,
      NotificationKeys.readAt: AppDateTime.toUtcIso(readAt),
      NotificationKeys.notificationId: notificationId,
      NotificationKeys.templateId: notificationId,
      NotificationKeys.createdAt: AppDateTime.toUtcIso(createdAt),
      'updated_at': AppDateTime.toUtcIso(updatedAt),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? link,
    Map<String, dynamic>? data,
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
      data: data ?? this.data,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
      notificationId: notificationId ?? templateId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
