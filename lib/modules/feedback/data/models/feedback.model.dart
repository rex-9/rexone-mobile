// lib/modules/feedback/data/models/feedback.model.dart
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

class FeedbackModel {
  final String id;
  final String content;
  final int? rating;
  final String category;
  final String priority;
  final String status;
  final String platform;
  final String? appVersion;
  final String? os;
  final String? device;
  final String? browser;
  final String? page;
  final Map<String, dynamic>? metadata;
  final String? adminNotes;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FeedbackModel({
    required this.id,
    required this.content,
    this.rating,
    required this.category,
    required this.priority,
    required this.status,
    required this.platform,
    this.appVersion,
    this.os,
    this.device,
    this.browser,
    this.page,
    this.metadata,
    this.adminNotes,
    this.userId,
    this.userName,
    this.userEmail,
    this.createdAt,
    this.updatedAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String? ?? '',
      content: json[FeedbackKeys.content] as String? ?? '',
      rating: json[FeedbackKeys.rating] as int?,
      category: json[FeedbackKeys.category] as String? ?? 'general',
      priority: json[FeedbackKeys.priority] as String? ?? 'medium',
      status: json[FeedbackKeys.status] as String? ?? 'new',
      platform: json[FeedbackKeys.platform] as String? ?? 'android',
      appVersion: json[FeedbackKeys.appVersion] as String?,
      os: json[FeedbackKeys.os] as String?,
      device: json[FeedbackKeys.device] as String?,
      browser: json[FeedbackKeys.browser] as String?,
      page: json[FeedbackKeys.page] as String?,
      metadata: json[FeedbackKeys.metadata] is Map
          ? Map<String, dynamic>.from(json[FeedbackKeys.metadata] as Map)
          : null,
      adminNotes: json[FeedbackKeys.adminNotes] as String?,
      userId: json[FeedbackKeys.userId] as String?,
      userName: json[FeedbackKeys.userName] as String?,
      userEmail: json[FeedbackKeys.userEmail] as String?,
      createdAt: AppDateTime.fromUtc(json[FeedbackKeys.createdAt]),
      updatedAt: AppDateTime.fromUtc(json[FeedbackKeys.updatedAt]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FeedbackKeys.content: content,
      if (rating != null) FeedbackKeys.rating: rating,
      if (page != null) FeedbackKeys.page: page,
      if (appVersion != null) FeedbackKeys.appVersion: appVersion,
      if (os != null) FeedbackKeys.os: os,
      if (device != null) FeedbackKeys.device: device,
      if (metadata != null) FeedbackKeys.metadata: metadata,
    };
  }
}
