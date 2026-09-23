/// Centralized JSON keys for asset and media upload requests/responses.
class AssetKeys {
  const AssetKeys._();

  static const asset = 'asset';
  static const storageDetails = 'storage_details';
  static const storageKey = 'storage_key';
  static const file = 'file';
  static const folder = 'folder';
  static const name = 'name';
  static const title = 'title';
  static const description = 'description';
  static const metadata = 'metadata';
  static const url = 'url';
  static const type = 'type';
  static const format = 'format';
  static const extension = 'extension';
  static const sizeBytes = 'size_bytes';
  static const durationSecs = 'duration_secs';
  static const source = 'source';
  static const assetableType = 'assetable_type';
  static const assetableId = 'assetable_id';
  static const createdById = 'created_by_id';
  static const bytes = 'bytes';
  static const status = 'status';
  static const parentAssetId = 'parent_asset_id';
  static const children = 'children';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const thumbnail = 'thumbnail';
  static const subtitle = 'subtitle';
  static const subtitles = 'subtitles';
  static const statusReady = 'ready';
  static const content = 'content';
  static const coreUrl = 'core_url';

  // ===== Playback response keys =====
  static const assetId = 'asset_id';
  static const delivery = 'delivery';
  static const expiresAt = 'expires_at';
  static const contentType = 'content_type';
  static const media = 'media';

  // ===== Asset type filters (legacy query param) =====
  static const typeAudio = 'audio';
  static const typeVideo = 'video';
  static const typeAvatar = 'avatar';
  static const typeAttachment = 'attachment';
  static const typeThumbnail = 'thumbnail';
  static const typeSubtitle = 'subtitle';
  static const typeGeneral = 'general';

  // ===== Asset format values (attributes.format) =====
  static const formatAudio = 'audio';
  static const formatVideo = 'video';
  static const formatImage = 'image';
  static const formatAttachment = 'attachment';
  static const formatSubtitle = 'subtitle';

  /// Extensions opened with the in-app text preview (no external app).
  static const textAttachmentExtensions = {
    'md',
    'markdown',
    'txt',
    'json',
    'csv',
    'xml',
    'html',
    'htm',
    'log',
    'yaml',
    'yml',
  };

  // ===== Extensions & Formats =====
  static const extensionSrt = 'srt';
  static const extensionEnc = 'enc';
  static const imageExtensions = ['jpg', 'png', 'webp', 'jpeg'];

  // ===== Upload constants (FormData values) =====
  static const assetableUser = 'User';
  static const sourceUpload = 'upload';
}
