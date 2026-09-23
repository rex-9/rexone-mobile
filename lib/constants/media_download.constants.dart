// lib/constants/media_download.constants.dart

import 'package:rexone_mobile/config/app.config.dart';

/// Offline media download layout and persisted field names.
class MediaDownloadConstants {
  const MediaDownloadConstants._();

  /// Encrypted audio/video (+ decrypted cache + download temp).
  static const offlineRootDirName = 'media_offline';

  /// Plaintext images, attachments, and other non-A/V offline files (named after the app).
  static String get plaintextRootDirName => AppConfig.appName
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]'), '_');

  static const decryptedCacheDirName = 'decrypted_cache';
  static const mediaFileSuffix = '.enc';
  static const subtitleFileSuffix = '.sub.enc';
  static const encryptedExtension = 'enc';
  static const defaultState = 'none';

  static const keySalt = 'rexone_mobile_offline_v1';

  static const downloadTaskGroup = 'media_offline';
  static const tempDirName = '.tmp';
  static const tempMediaSuffix = '.part';
  static const tempSubtitleSuffix = '.sub.part';
  static const maxConcurrentDownloads = 2;

  static const notificationChannelId = 'media_download';

  /// MethodChannel for Live Activity Pause/Resume (must match AppDelegate).
  static const liveActivityMethodChannel =
      'rexone/media_download_live_activity';
  static const liveActivityMethodAction = 'action';
  static const liveActivityMethodTakePending = 'takePending';

  static const metaAssetId = 'assetId';
  static const metaPhase = 'phase';
  static const metaTitle = 'title';
  static const metaMediaFormat = 'mediaFormat';
  static const metaSubtitleId = 'subtitleId';
  static const metaPaused = 'paused';
  static const metaProgress = 'progress';

  static const phaseMedia = 'media';
  static const phaseSubtitle = 'subtitle';

  /// Live Activity action host/query keys (scheme lives in [NotificationConstants]).
  static const iosLiveActivityHost = 'download';
  static const iosActionPause = 'pause';
  static const iosActionResume = 'resume';
  static const iosQueryAction = 'action';
  static const iosQueryAssetId = 'assetId';

  static const jsonAssetId = 'assetId';
  static const jsonState = 'state';
  static const jsonProgress = 'progress';
  static const jsonMediaPath = 'mediaPath';
  static const jsonSubtitlePaths = 'subtitlePaths';
  static const jsonDownloadedAt = 'downloadedAt';
  static const jsonErrorMessage = 'errorMessage';
  static const jsonTitle = 'title';
  static const jsonMediaFormat = 'mediaFormat';
}
