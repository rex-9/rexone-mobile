# Client SQLite Database Architecture (`rexone_mobile`)

## 1. Overview & Architectural Philosophy

The mobile client uses **Drift** (`drift_flutter` with SQLite FFI) for local persistence, offline caching, and media download management.

To prevent architectural drift and divergence between backend and mobile applications, the client database strictly mirrors the canonical backend relational design defined in [`rexone-core/docs/SCHEMA.md`](file:///Users/rex/Desktop/Dev/rexone/rexone-core/docs/SCHEMA.md):
- **Identical Column Naming & Types**: Tables and columns in SQLite mirror the backend `assets` and child entity schemas in `snake_case`.
- **Polymorphic Domain Associations**: Assets are linked to domain models (`Course`, `GymSession`, `MeditationPodcast`, `ChatMessage`, etc.) using `assetable_type` and `assetable_id`.
- **Parent-Child Hierarchy**: Parent assets (videos, audios) own child assets (thumbnails, `.srt` subtitles, attachments) via `parent_asset_id`.
- **Single Source of Truth**: When offline, the client queries local Drift tables. When online, downloaded assets are preferred for playback to save user bandwidth and ensure instant startup.

---

## 2. Table Specifications

### 2.1. `local_assets`
Mirrors backend `assets` table ([`docs/SCHEMA.md` § 7.1](file:///Users/rex/Desktop/Dev/rexone/rexone-core/docs/SCHEMA.md#71-assets)) with offline lifecycle fields.

| Column | SQLite Type | Nullable | Default | Description / Notes |
| :--- | :--- | :---: | :--- | :--- |
| `id` | `TEXT` (UUID) | ❌ | Primary Key | Canonical UUID from backend `assets.id` |
| `name` | `TEXT` | ❌ | — | Original file name or identifier |
| `title` | `TEXT` | ✔️ | `NULL` | Human-friendly title |
| `description` | `TEXT` | ✔️ | `NULL` | Optional asset description |
| `url` | `TEXT` | ❌ | — | Cloud or CDN URL |
| `type` | `TEXT` | ❌ | `'general'` | Semantic role: `general`, `avatar`, `tts`, `attachment` |
| `format` | `TEXT` | ✔️ | `NULL` | Media kind: `video`, `audio`, `image`, `doc` |
| `extension` | `TEXT` | ✔️ | `NULL` | File extension without dot (e.g. `mp4`, `mp3`, `webp`) |
| `size_bytes` | `INTEGER` (Int64) | ✔️ | `NULL` | Remote file size in bytes |
| `duration_secs` | `INTEGER` | ✔️ | `NULL` | Audio or video duration in seconds |
| `source` | `TEXT` | ❌ | `''` | Origin: `upload`, `google`, etc. |
| `status` | `TEXT` | ✔️ | `'ready'` | Backend pipeline status |
| `assetable_type` | `TEXT` | ✔️ | `NULL` | Polymorphic owner type (`Course`, `GymSession`, etc.) |
| `assetable_id` | `TEXT` (UUID) | ✔️ | `NULL` | Polymorphic owner ID |
| `parent_asset_id` | `TEXT` (UUID) | ✔️ | `NULL` | Parent asset ID if converted or nested |
| `created_by_id` | `TEXT` (UUID) | ✔️ | `NULL` | Creator UUID |
| `metadata_json` | `TEXT` (JSON) | ✔️ | `NULL` | Serialized metadata JSON payload |
| `children_json` | `TEXT` (JSON) | ✔️ | `NULL` | Cached array of child asset models |
| `created_at` | `DATETIME` | ✔️ | `NULL` | Timestamp |
| `updated_at` | `DATETIME` | ✔️ | `NULL` | Timestamp |
| `download_state` | `TEXT` | ❌ | `'none'` | Offline state: `none`, `queued`, `downloading`, `paused`, `processing`, `ready`, `failed` |
| `download_progress`| `REAL` | ❌ | `0.0` | Download progress fraction (`0.0` to `1.0`) |
| `local_file_path` | `TEXT` | ✔️ | `NULL` | Path to encrypted offline payload (`.enc`) |
| `error_message` | `TEXT` | ✔️ | `NULL` | Failure error message if state is `failed` |
| `downloaded_at` | `DATETIME` | ✔️ | `NULL` | Timestamp when download completed and verified |

---

### 2.2. `local_child_assets`
Stores child resources attached to a parent asset (thumbnails, subtitles, transcripts).

| Column | SQLite Type | Nullable | Default | Description / Notes |
| :--- | :--- | :---: | :--- | :--- |
| `id` | `TEXT` (UUID) | ❌ | Primary Key | Child asset UUID |
| `parent_asset_id` | `TEXT` (UUID) | ❌ | — | Foreign reference to `local_assets.id` |
| `name` | `TEXT` | ❌ | — | Child original filename |
| `title` | `TEXT` | ✔️ | `NULL` | Subtitle track language or thumbnail label |
| `description` | `TEXT` | ✔️ | `NULL` | Optional description |
| `url` | `TEXT` | ❌ | — | Remote URL |
| `type` | `TEXT` | ✔️ | `NULL` | Semantic type: `thumbnail`, `subtitle`, `attachment` |
| `format` | `TEXT` | ✔️ | `NULL` | Format: `image`, `subtitle` |
| `extension` | `TEXT` | ✔️ | `NULL` | Extension: `webp`, `jpg`, `srt`, `vtt` |
| `size_bytes` | `INTEGER` (Int64) | ✔️ | `NULL` | Size in bytes |
| `local_file_path` | `TEXT` | ✔️ | `NULL` | Local unencrypted file path (e.g. `.srt` or image thumbnail) |
| `is_downloaded` | `INTEGER` (Bool) | ❌ | `0` | Boolean flag indicating local availability |

---

### 2.3. `asset_playback_progress`
Maintains user playback progress across sessions.

| Column | SQLite Type | Nullable | Default | Description / Notes |
| :--- | :--- | :---: | :--- | :--- |
| `asset_id` | `TEXT` (UUID) | ❌ | Primary Key | Reference to `local_assets.id` |
| `position_millis` | `INTEGER` (Int64) | ❌ | `0` | Playback position in milliseconds |
| `duration_millis` | `INTEGER` (Int64) | ❌ | `0` | Total duration in milliseconds |
| `completed` | `INTEGER` (Bool) | ❌ | `0` | Marked true if user reached end |
| `last_played_at` | `DATETIME` | ❌ | Current Time | Timestamp of last playback activity |

---

### 2.4. `offline_sync_queue`
Guarantees reliable background synchronization of client events (play counts, analytics, completions) when connectivity is restored.

| Column | SQLite Type | Nullable | Default | Description / Notes |
| :--- | :--- | :---: | :--- | :--- |
| `id` | `INTEGER` | ❌ | Autoincrement | Primary Key |
| `action` | `TEXT` | ❌ | — | Sync action name (e.g. `log_view`, `update_progress`) |
| `payload_json` | `TEXT` | ❌ | — | Serialized request body |
| `retry_count` | `INTEGER` | ❌ | `0` | Number of failed attempts |
| `created_at` | `DATETIME` | ❌ | Current Time | Queued timestamp |

---

## 3. Polymorphic Domain Queries

To query offline assets belonging to specific domains without duplicating tables, use `getDownloadedAssetsByAssetable`:

```dart
final db = Get.find<AppDatabase>();

// Fetch all downloaded video/audio assets for a Course
final courseAssets = await db.getDownloadedAssetsByAssetable(
  assetableType: 'Course',
  assetableId: courseId,
);

// Fetch all downloaded meditation podcasts
final meditationAssets = await db.getDownloadedAssetsByAssetable(
  assetableType: 'MeditationPodcast',
);
```

---

## 4. Encryption & Storage Transparency

1. **AES-256-GCM Encryption**:
   - Media binaries are saved as `.enc` encrypted files in the app's sandboxed document directory.
   - Key derivation utilizes hardware-backed keystore credentials or `MEDIA_OFFLINE_ENCRYPTION_KEY`.
2. **Deterministic Disk Tracking**:
   - `MediaDownloadService.getOccupiedDiskSizeBytes(assetId)` accurately computes the total footprint (encrypted media + unencrypted `.srt` subtitle files + cached thumbnails).
3. **Storage Freeing UX**:
   - Users are presented with an exact freed-storage confirmation dialog:
     ```
     Remove "{title}" from downloaded videos? This will free up 4.2 MB of device storage.
     [ Remove (4.2 MB) ]
     ```
   - On deletion, all physical files are purged and Drift records are reset to `downloadState = 'none'`.

---

## 5. Schema Migrations

Drift migrations use `MigrationStrategy`:
1. Increments `schemaVersion` in `database.dart`.
2. Adds `onUpgrade` step with `m.createTable` or `m.addColumn`.
3. Ensures all changes remain backward-compatible and preserve user-downloaded media across app updates.
