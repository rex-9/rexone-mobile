/// Centralized JSON keys for asset and media upload requests/responses.
class AssetKeys {
  const AssetKeys._();

  static const asset = 'asset';
  static const storageDetails = 'storage_details';
  static const storageKey = 'storage_key';
  static const file = 'file';
  static const folder = 'folder';
  static const name = 'name';
  static const displayName = 'display_name';
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

  // ===== Upload constants (FormData values) =====
  static const typeAvatar = 'avatar';
  static const assetableUser = 'User';
  static const sourceUpload = 'upload';
}
