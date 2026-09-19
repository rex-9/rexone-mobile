// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LocalAssetsTableTable extends LocalAssetsTable
    with TableInfo<$LocalAssetsTableTable, LocalAssetsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extensionMeta = const VerificationMeta(
    'extension',
  );
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
    'extension',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<BigInt> sizeBytes = GeneratedColumn<BigInt>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecsMeta = const VerificationMeta(
    'durationSecs',
  );
  @override
  late final GeneratedColumn<int> durationSecs = GeneratedColumn<int>(
    'duration_secs',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetableTypeMeta = const VerificationMeta(
    'assetableType',
  );
  @override
  late final GeneratedColumn<String> assetableType = GeneratedColumn<String>(
    'assetable_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetableIdMeta = const VerificationMeta(
    'assetableId',
  );
  @override
  late final GeneratedColumn<String> assetableId = GeneratedColumn<String>(
    'assetable_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentAssetIdMeta = const VerificationMeta(
    'parentAssetId',
  );
  @override
  late final GeneratedColumn<String> parentAssetId = GeneratedColumn<String>(
    'parent_asset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByIdMeta = const VerificationMeta(
    'createdById',
  );
  @override
  late final GeneratedColumn<String> createdById = GeneratedColumn<String>(
    'created_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _childrenJsonMeta = const VerificationMeta(
    'childrenJson',
  );
  @override
  late final GeneratedColumn<String> childrenJson = GeneratedColumn<String>(
    'children_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadStateMeta = const VerificationMeta(
    'downloadState',
  );
  @override
  late final GeneratedColumn<String> downloadState = GeneratedColumn<String>(
    'download_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _downloadProgressMeta = const VerificationMeta(
    'downloadProgress',
  );
  @override
  late final GeneratedColumn<double> downloadProgress = GeneratedColumn<double>(
    'download_progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    title,
    description,
    url,
    type,
    format,
    extension,
    sizeBytes,
    durationSecs,
    source,
    status,
    assetableType,
    assetableId,
    parentAssetId,
    createdById,
    metadataJson,
    childrenJson,
    createdAt,
    updatedAt,
    downloadState,
    downloadProgress,
    localFilePath,
    errorMessage,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssetsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('extension')) {
      context.handle(
        _extensionMeta,
        extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('duration_secs')) {
      context.handle(
        _durationSecsMeta,
        durationSecs.isAcceptableOrUnknown(
          data['duration_secs']!,
          _durationSecsMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('assetable_type')) {
      context.handle(
        _assetableTypeMeta,
        assetableType.isAcceptableOrUnknown(
          data['assetable_type']!,
          _assetableTypeMeta,
        ),
      );
    }
    if (data.containsKey('assetable_id')) {
      context.handle(
        _assetableIdMeta,
        assetableId.isAcceptableOrUnknown(
          data['assetable_id']!,
          _assetableIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_asset_id')) {
      context.handle(
        _parentAssetIdMeta,
        parentAssetId.isAcceptableOrUnknown(
          data['parent_asset_id']!,
          _parentAssetIdMeta,
        ),
      );
    }
    if (data.containsKey('created_by_id')) {
      context.handle(
        _createdByIdMeta,
        createdById.isAcceptableOrUnknown(
          data['created_by_id']!,
          _createdByIdMeta,
        ),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('children_json')) {
      context.handle(
        _childrenJsonMeta,
        childrenJson.isAcceptableOrUnknown(
          data['children_json']!,
          _childrenJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('download_state')) {
      context.handle(
        _downloadStateMeta,
        downloadState.isAcceptableOrUnknown(
          data['download_state']!,
          _downloadStateMeta,
        ),
      );
    }
    if (data.containsKey('download_progress')) {
      context.handle(
        _downloadProgressMeta,
        downloadProgress.isAcceptableOrUnknown(
          data['download_progress']!,
          _downloadProgressMeta,
        ),
      );
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAssetsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssetsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      ),
      extension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}size_bytes'],
      ),
      durationSecs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_secs'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      assetableType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assetable_type'],
      ),
      assetableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assetable_id'],
      ),
      parentAssetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_asset_id'],
      ),
      createdById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_id'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      childrenJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}children_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      downloadState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_state'],
      )!,
      downloadProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}download_progress'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      ),
    );
  }

  @override
  $LocalAssetsTableTable createAlias(String alias) {
    return $LocalAssetsTableTable(attachedDatabase, alias);
  }
}

class LocalAssetsTableData extends DataClass
    implements Insertable<LocalAssetsTableData> {
  final String id;
  final String name;
  final String? title;
  final String? description;
  final String url;
  final String type;
  final String? format;
  final String? extension;
  final BigInt? sizeBytes;
  final int? durationSecs;
  final String source;
  final String? status;
  final String? assetableType;
  final String? assetableId;
  final String? parentAssetId;
  final String? createdById;
  final String? metadataJson;
  final String? childrenJson;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String downloadState;
  final double downloadProgress;
  final String? localFilePath;
  final String? errorMessage;
  final DateTime? downloadedAt;
  const LocalAssetsTableData({
    required this.id,
    required this.name,
    this.title,
    this.description,
    required this.url,
    required this.type,
    this.format,
    this.extension,
    this.sizeBytes,
    this.durationSecs,
    required this.source,
    this.status,
    this.assetableType,
    this.assetableId,
    this.parentAssetId,
    this.createdById,
    this.metadataJson,
    this.childrenJson,
    this.createdAt,
    this.updatedAt,
    required this.downloadState,
    required this.downloadProgress,
    this.localFilePath,
    this.errorMessage,
    this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['url'] = Variable<String>(url);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || format != null) {
      map['format'] = Variable<String>(format);
    }
    if (!nullToAbsent || extension != null) {
      map['extension'] = Variable<String>(extension);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<BigInt>(sizeBytes);
    }
    if (!nullToAbsent || durationSecs != null) {
      map['duration_secs'] = Variable<int>(durationSecs);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || assetableType != null) {
      map['assetable_type'] = Variable<String>(assetableType);
    }
    if (!nullToAbsent || assetableId != null) {
      map['assetable_id'] = Variable<String>(assetableId);
    }
    if (!nullToAbsent || parentAssetId != null) {
      map['parent_asset_id'] = Variable<String>(parentAssetId);
    }
    if (!nullToAbsent || createdById != null) {
      map['created_by_id'] = Variable<String>(createdById);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    if (!nullToAbsent || childrenJson != null) {
      map['children_json'] = Variable<String>(childrenJson);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['download_state'] = Variable<String>(downloadState);
    map['download_progress'] = Variable<double>(downloadProgress);
    if (!nullToAbsent || localFilePath != null) {
      map['local_file_path'] = Variable<String>(localFilePath);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    return map;
  }

  LocalAssetsTableCompanion toCompanion(bool nullToAbsent) {
    return LocalAssetsTableCompanion(
      id: Value(id),
      name: Value(name),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      url: Value(url),
      type: Value(type),
      format: format == null && nullToAbsent
          ? const Value.absent()
          : Value(format),
      extension: extension == null && nullToAbsent
          ? const Value.absent()
          : Value(extension),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      durationSecs: durationSecs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSecs),
      source: Value(source),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      assetableType: assetableType == null && nullToAbsent
          ? const Value.absent()
          : Value(assetableType),
      assetableId: assetableId == null && nullToAbsent
          ? const Value.absent()
          : Value(assetableId),
      parentAssetId: parentAssetId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentAssetId),
      createdById: createdById == null && nullToAbsent
          ? const Value.absent()
          : Value(createdById),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      childrenJson: childrenJson == null && nullToAbsent
          ? const Value.absent()
          : Value(childrenJson),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      downloadState: Value(downloadState),
      downloadProgress: Value(downloadProgress),
      localFilePath: localFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localFilePath),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
    );
  }

  factory LocalAssetsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssetsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      url: serializer.fromJson<String>(json['url']),
      type: serializer.fromJson<String>(json['type']),
      format: serializer.fromJson<String?>(json['format']),
      extension: serializer.fromJson<String?>(json['extension']),
      sizeBytes: serializer.fromJson<BigInt?>(json['sizeBytes']),
      durationSecs: serializer.fromJson<int?>(json['durationSecs']),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String?>(json['status']),
      assetableType: serializer.fromJson<String?>(json['assetableType']),
      assetableId: serializer.fromJson<String?>(json['assetableId']),
      parentAssetId: serializer.fromJson<String?>(json['parentAssetId']),
      createdById: serializer.fromJson<String?>(json['createdById']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      childrenJson: serializer.fromJson<String?>(json['childrenJson']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      downloadState: serializer.fromJson<String>(json['downloadState']),
      downloadProgress: serializer.fromJson<double>(json['downloadProgress']),
      localFilePath: serializer.fromJson<String?>(json['localFilePath']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'url': serializer.toJson<String>(url),
      'type': serializer.toJson<String>(type),
      'format': serializer.toJson<String?>(format),
      'extension': serializer.toJson<String?>(extension),
      'sizeBytes': serializer.toJson<BigInt?>(sizeBytes),
      'durationSecs': serializer.toJson<int?>(durationSecs),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String?>(status),
      'assetableType': serializer.toJson<String?>(assetableType),
      'assetableId': serializer.toJson<String?>(assetableId),
      'parentAssetId': serializer.toJson<String?>(parentAssetId),
      'createdById': serializer.toJson<String?>(createdById),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'childrenJson': serializer.toJson<String?>(childrenJson),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'downloadState': serializer.toJson<String>(downloadState),
      'downloadProgress': serializer.toJson<double>(downloadProgress),
      'localFilePath': serializer.toJson<String?>(localFilePath),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
    };
  }

  LocalAssetsTableData copyWith({
    String? id,
    String? name,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? url,
    String? type,
    Value<String?> format = const Value.absent(),
    Value<String?> extension = const Value.absent(),
    Value<BigInt?> sizeBytes = const Value.absent(),
    Value<int?> durationSecs = const Value.absent(),
    String? source,
    Value<String?> status = const Value.absent(),
    Value<String?> assetableType = const Value.absent(),
    Value<String?> assetableId = const Value.absent(),
    Value<String?> parentAssetId = const Value.absent(),
    Value<String?> createdById = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
    Value<String?> childrenJson = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    String? downloadState,
    double? downloadProgress,
    Value<String?> localFilePath = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<DateTime?> downloadedAt = const Value.absent(),
  }) => LocalAssetsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    url: url ?? this.url,
    type: type ?? this.type,
    format: format.present ? format.value : this.format,
    extension: extension.present ? extension.value : this.extension,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    durationSecs: durationSecs.present ? durationSecs.value : this.durationSecs,
    source: source ?? this.source,
    status: status.present ? status.value : this.status,
    assetableType: assetableType.present
        ? assetableType.value
        : this.assetableType,
    assetableId: assetableId.present ? assetableId.value : this.assetableId,
    parentAssetId: parentAssetId.present
        ? parentAssetId.value
        : this.parentAssetId,
    createdById: createdById.present ? createdById.value : this.createdById,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    childrenJson: childrenJson.present ? childrenJson.value : this.childrenJson,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    downloadState: downloadState ?? this.downloadState,
    downloadProgress: downloadProgress ?? this.downloadProgress,
    localFilePath: localFilePath.present
        ? localFilePath.value
        : this.localFilePath,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    downloadedAt: downloadedAt.present ? downloadedAt.value : this.downloadedAt,
  );
  LocalAssetsTableData copyWithCompanion(LocalAssetsTableCompanion data) {
    return LocalAssetsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      url: data.url.present ? data.url.value : this.url,
      type: data.type.present ? data.type.value : this.type,
      format: data.format.present ? data.format.value : this.format,
      extension: data.extension.present ? data.extension.value : this.extension,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      durationSecs: data.durationSecs.present
          ? data.durationSecs.value
          : this.durationSecs,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      assetableType: data.assetableType.present
          ? data.assetableType.value
          : this.assetableType,
      assetableId: data.assetableId.present
          ? data.assetableId.value
          : this.assetableId,
      parentAssetId: data.parentAssetId.present
          ? data.parentAssetId.value
          : this.parentAssetId,
      createdById: data.createdById.present
          ? data.createdById.value
          : this.createdById,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      childrenJson: data.childrenJson.present
          ? data.childrenJson.value
          : this.childrenJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      downloadState: data.downloadState.present
          ? data.downloadState.value
          : this.downloadState,
      downloadProgress: data.downloadProgress.present
          ? data.downloadProgress.value
          : this.downloadProgress,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssetsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('url: $url, ')
          ..write('type: $type, ')
          ..write('format: $format, ')
          ..write('extension: $extension, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('durationSecs: $durationSecs, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('assetableType: $assetableType, ')
          ..write('assetableId: $assetableId, ')
          ..write('parentAssetId: $parentAssetId, ')
          ..write('createdById: $createdById, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('childrenJson: $childrenJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('downloadState: $downloadState, ')
          ..write('downloadProgress: $downloadProgress, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    title,
    description,
    url,
    type,
    format,
    extension,
    sizeBytes,
    durationSecs,
    source,
    status,
    assetableType,
    assetableId,
    parentAssetId,
    createdById,
    metadataJson,
    childrenJson,
    createdAt,
    updatedAt,
    downloadState,
    downloadProgress,
    localFilePath,
    errorMessage,
    downloadedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssetsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.title == this.title &&
          other.description == this.description &&
          other.url == this.url &&
          other.type == this.type &&
          other.format == this.format &&
          other.extension == this.extension &&
          other.sizeBytes == this.sizeBytes &&
          other.durationSecs == this.durationSecs &&
          other.source == this.source &&
          other.status == this.status &&
          other.assetableType == this.assetableType &&
          other.assetableId == this.assetableId &&
          other.parentAssetId == this.parentAssetId &&
          other.createdById == this.createdById &&
          other.metadataJson == this.metadataJson &&
          other.childrenJson == this.childrenJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.downloadState == this.downloadState &&
          other.downloadProgress == this.downloadProgress &&
          other.localFilePath == this.localFilePath &&
          other.errorMessage == this.errorMessage &&
          other.downloadedAt == this.downloadedAt);
}

class LocalAssetsTableCompanion extends UpdateCompanion<LocalAssetsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String> url;
  final Value<String> type;
  final Value<String?> format;
  final Value<String?> extension;
  final Value<BigInt?> sizeBytes;
  final Value<int?> durationSecs;
  final Value<String> source;
  final Value<String?> status;
  final Value<String?> assetableType;
  final Value<String?> assetableId;
  final Value<String?> parentAssetId;
  final Value<String?> createdById;
  final Value<String?> metadataJson;
  final Value<String?> childrenJson;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> downloadState;
  final Value<double> downloadProgress;
  final Value<String?> localFilePath;
  final Value<String?> errorMessage;
  final Value<DateTime?> downloadedAt;
  final Value<int> rowid;
  const LocalAssetsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.url = const Value.absent(),
    this.type = const Value.absent(),
    this.format = const Value.absent(),
    this.extension = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.durationSecs = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.assetableType = const Value.absent(),
    this.assetableId = const Value.absent(),
    this.parentAssetId = const Value.absent(),
    this.createdById = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.childrenJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.downloadState = const Value.absent(),
    this.downloadProgress = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssetsTableCompanion.insert({
    required String id,
    required String name,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    required String url,
    required String type,
    this.format = const Value.absent(),
    this.extension = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.durationSecs = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.assetableType = const Value.absent(),
    this.assetableId = const Value.absent(),
    this.parentAssetId = const Value.absent(),
    this.createdById = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.childrenJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.downloadState = const Value.absent(),
    this.downloadProgress = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       url = Value(url),
       type = Value(type);
  static Insertable<LocalAssetsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? url,
    Expression<String>? type,
    Expression<String>? format,
    Expression<String>? extension,
    Expression<BigInt>? sizeBytes,
    Expression<int>? durationSecs,
    Expression<String>? source,
    Expression<String>? status,
    Expression<String>? assetableType,
    Expression<String>? assetableId,
    Expression<String>? parentAssetId,
    Expression<String>? createdById,
    Expression<String>? metadataJson,
    Expression<String>? childrenJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? downloadState,
    Expression<double>? downloadProgress,
    Expression<String>? localFilePath,
    Expression<String>? errorMessage,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (url != null) 'url': url,
      if (type != null) 'type': type,
      if (format != null) 'format': format,
      if (extension != null) 'extension': extension,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (durationSecs != null) 'duration_secs': durationSecs,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (assetableType != null) 'assetable_type': assetableType,
      if (assetableId != null) 'assetable_id': assetableId,
      if (parentAssetId != null) 'parent_asset_id': parentAssetId,
      if (createdById != null) 'created_by_id': createdById,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (childrenJson != null) 'children_json': childrenJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (downloadState != null) 'download_state': downloadState,
      if (downloadProgress != null) 'download_progress': downloadProgress,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (errorMessage != null) 'error_message': errorMessage,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssetsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? title,
    Value<String?>? description,
    Value<String>? url,
    Value<String>? type,
    Value<String?>? format,
    Value<String?>? extension,
    Value<BigInt?>? sizeBytes,
    Value<int?>? durationSecs,
    Value<String>? source,
    Value<String?>? status,
    Value<String?>? assetableType,
    Value<String?>? assetableId,
    Value<String?>? parentAssetId,
    Value<String?>? createdById,
    Value<String?>? metadataJson,
    Value<String?>? childrenJson,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? downloadState,
    Value<double>? downloadProgress,
    Value<String?>? localFilePath,
    Value<String?>? errorMessage,
    Value<DateTime?>? downloadedAt,
    Value<int>? rowid,
  }) {
    return LocalAssetsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      type: type ?? this.type,
      format: format ?? this.format,
      extension: extension ?? this.extension,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      durationSecs: durationSecs ?? this.durationSecs,
      source: source ?? this.source,
      status: status ?? this.status,
      assetableType: assetableType ?? this.assetableType,
      assetableId: assetableId ?? this.assetableId,
      parentAssetId: parentAssetId ?? this.parentAssetId,
      createdById: createdById ?? this.createdById,
      metadataJson: metadataJson ?? this.metadataJson,
      childrenJson: childrenJson ?? this.childrenJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      downloadState: downloadState ?? this.downloadState,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      localFilePath: localFilePath ?? this.localFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<BigInt>(sizeBytes.value);
    }
    if (durationSecs.present) {
      map['duration_secs'] = Variable<int>(durationSecs.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (assetableType.present) {
      map['assetable_type'] = Variable<String>(assetableType.value);
    }
    if (assetableId.present) {
      map['assetable_id'] = Variable<String>(assetableId.value);
    }
    if (parentAssetId.present) {
      map['parent_asset_id'] = Variable<String>(parentAssetId.value);
    }
    if (createdById.present) {
      map['created_by_id'] = Variable<String>(createdById.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (childrenJson.present) {
      map['children_json'] = Variable<String>(childrenJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (downloadState.present) {
      map['download_state'] = Variable<String>(downloadState.value);
    }
    if (downloadProgress.present) {
      map['download_progress'] = Variable<double>(downloadProgress.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssetsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('url: $url, ')
          ..write('type: $type, ')
          ..write('format: $format, ')
          ..write('extension: $extension, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('durationSecs: $durationSecs, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('assetableType: $assetableType, ')
          ..write('assetableId: $assetableId, ')
          ..write('parentAssetId: $parentAssetId, ')
          ..write('createdById: $createdById, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('childrenJson: $childrenJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('downloadState: $downloadState, ')
          ..write('downloadProgress: $downloadProgress, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalChildAssetsTableTable extends LocalChildAssetsTable
    with TableInfo<$LocalChildAssetsTableTable, LocalChildAssetsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChildAssetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentAssetIdMeta = const VerificationMeta(
    'parentAssetId',
  );
  @override
  late final GeneratedColumn<String> parentAssetId = GeneratedColumn<String>(
    'parent_asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extensionMeta = const VerificationMeta(
    'extension',
  );
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
    'extension',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<BigInt> sizeBytes = GeneratedColumn<BigInt>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDownloadedMeta = const VerificationMeta(
    'isDownloaded',
  );
  @override
  late final GeneratedColumn<bool> isDownloaded = GeneratedColumn<bool>(
    'is_downloaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_downloaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentAssetId,
    name,
    title,
    description,
    url,
    type,
    format,
    extension,
    sizeBytes,
    localFilePath,
    isDownloaded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_child_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChildAssetsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_asset_id')) {
      context.handle(
        _parentAssetIdMeta,
        parentAssetId.isAcceptableOrUnknown(
          data['parent_asset_id']!,
          _parentAssetIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parentAssetIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('extension')) {
      context.handle(
        _extensionMeta,
        extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
        _isDownloadedMeta,
        isDownloaded.isAcceptableOrUnknown(
          data['is_downloaded']!,
          _isDownloadedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalChildAssetsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChildAssetsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentAssetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_asset_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      ),
      extension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}size_bytes'],
      ),
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      ),
      isDownloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_downloaded'],
      )!,
    );
  }

  @override
  $LocalChildAssetsTableTable createAlias(String alias) {
    return $LocalChildAssetsTableTable(attachedDatabase, alias);
  }
}

class LocalChildAssetsTableData extends DataClass
    implements Insertable<LocalChildAssetsTableData> {
  final String id;
  final String parentAssetId;
  final String name;
  final String? title;
  final String? description;
  final String url;
  final String? type;
  final String? format;
  final String? extension;
  final BigInt? sizeBytes;
  final String? localFilePath;
  final bool isDownloaded;
  const LocalChildAssetsTableData({
    required this.id,
    required this.parentAssetId,
    required this.name,
    this.title,
    this.description,
    required this.url,
    this.type,
    this.format,
    this.extension,
    this.sizeBytes,
    this.localFilePath,
    required this.isDownloaded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['parent_asset_id'] = Variable<String>(parentAssetId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || format != null) {
      map['format'] = Variable<String>(format);
    }
    if (!nullToAbsent || extension != null) {
      map['extension'] = Variable<String>(extension);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<BigInt>(sizeBytes);
    }
    if (!nullToAbsent || localFilePath != null) {
      map['local_file_path'] = Variable<String>(localFilePath);
    }
    map['is_downloaded'] = Variable<bool>(isDownloaded);
    return map;
  }

  LocalChildAssetsTableCompanion toCompanion(bool nullToAbsent) {
    return LocalChildAssetsTableCompanion(
      id: Value(id),
      parentAssetId: Value(parentAssetId),
      name: Value(name),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      url: Value(url),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      format: format == null && nullToAbsent
          ? const Value.absent()
          : Value(format),
      extension: extension == null && nullToAbsent
          ? const Value.absent()
          : Value(extension),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      localFilePath: localFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localFilePath),
      isDownloaded: Value(isDownloaded),
    );
  }

  factory LocalChildAssetsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChildAssetsTableData(
      id: serializer.fromJson<String>(json['id']),
      parentAssetId: serializer.fromJson<String>(json['parentAssetId']),
      name: serializer.fromJson<String>(json['name']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      url: serializer.fromJson<String>(json['url']),
      type: serializer.fromJson<String?>(json['type']),
      format: serializer.fromJson<String?>(json['format']),
      extension: serializer.fromJson<String?>(json['extension']),
      sizeBytes: serializer.fromJson<BigInt?>(json['sizeBytes']),
      localFilePath: serializer.fromJson<String?>(json['localFilePath']),
      isDownloaded: serializer.fromJson<bool>(json['isDownloaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentAssetId': serializer.toJson<String>(parentAssetId),
      'name': serializer.toJson<String>(name),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'url': serializer.toJson<String>(url),
      'type': serializer.toJson<String?>(type),
      'format': serializer.toJson<String?>(format),
      'extension': serializer.toJson<String?>(extension),
      'sizeBytes': serializer.toJson<BigInt?>(sizeBytes),
      'localFilePath': serializer.toJson<String?>(localFilePath),
      'isDownloaded': serializer.toJson<bool>(isDownloaded),
    };
  }

  LocalChildAssetsTableData copyWith({
    String? id,
    String? parentAssetId,
    String? name,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? url,
    Value<String?> type = const Value.absent(),
    Value<String?> format = const Value.absent(),
    Value<String?> extension = const Value.absent(),
    Value<BigInt?> sizeBytes = const Value.absent(),
    Value<String?> localFilePath = const Value.absent(),
    bool? isDownloaded,
  }) => LocalChildAssetsTableData(
    id: id ?? this.id,
    parentAssetId: parentAssetId ?? this.parentAssetId,
    name: name ?? this.name,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    url: url ?? this.url,
    type: type.present ? type.value : this.type,
    format: format.present ? format.value : this.format,
    extension: extension.present ? extension.value : this.extension,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    localFilePath: localFilePath.present
        ? localFilePath.value
        : this.localFilePath,
    isDownloaded: isDownloaded ?? this.isDownloaded,
  );
  LocalChildAssetsTableData copyWithCompanion(
    LocalChildAssetsTableCompanion data,
  ) {
    return LocalChildAssetsTableData(
      id: data.id.present ? data.id.value : this.id,
      parentAssetId: data.parentAssetId.present
          ? data.parentAssetId.value
          : this.parentAssetId,
      name: data.name.present ? data.name.value : this.name,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      url: data.url.present ? data.url.value : this.url,
      type: data.type.present ? data.type.value : this.type,
      format: data.format.present ? data.format.value : this.format,
      extension: data.extension.present ? data.extension.value : this.extension,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChildAssetsTableData(')
          ..write('id: $id, ')
          ..write('parentAssetId: $parentAssetId, ')
          ..write('name: $name, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('url: $url, ')
          ..write('type: $type, ')
          ..write('format: $format, ')
          ..write('extension: $extension, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('isDownloaded: $isDownloaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    parentAssetId,
    name,
    title,
    description,
    url,
    type,
    format,
    extension,
    sizeBytes,
    localFilePath,
    isDownloaded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChildAssetsTableData &&
          other.id == this.id &&
          other.parentAssetId == this.parentAssetId &&
          other.name == this.name &&
          other.title == this.title &&
          other.description == this.description &&
          other.url == this.url &&
          other.type == this.type &&
          other.format == this.format &&
          other.extension == this.extension &&
          other.sizeBytes == this.sizeBytes &&
          other.localFilePath == this.localFilePath &&
          other.isDownloaded == this.isDownloaded);
}

class LocalChildAssetsTableCompanion
    extends UpdateCompanion<LocalChildAssetsTableData> {
  final Value<String> id;
  final Value<String> parentAssetId;
  final Value<String> name;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String> url;
  final Value<String?> type;
  final Value<String?> format;
  final Value<String?> extension;
  final Value<BigInt?> sizeBytes;
  final Value<String?> localFilePath;
  final Value<bool> isDownloaded;
  final Value<int> rowid;
  const LocalChildAssetsTableCompanion({
    this.id = const Value.absent(),
    this.parentAssetId = const Value.absent(),
    this.name = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.url = const Value.absent(),
    this.type = const Value.absent(),
    this.format = const Value.absent(),
    this.extension = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalChildAssetsTableCompanion.insert({
    required String id,
    required String parentAssetId,
    required String name,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    required String url,
    this.type = const Value.absent(),
    this.format = const Value.absent(),
    this.extension = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       parentAssetId = Value(parentAssetId),
       name = Value(name),
       url = Value(url);
  static Insertable<LocalChildAssetsTableData> custom({
    Expression<String>? id,
    Expression<String>? parentAssetId,
    Expression<String>? name,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? url,
    Expression<String>? type,
    Expression<String>? format,
    Expression<String>? extension,
    Expression<BigInt>? sizeBytes,
    Expression<String>? localFilePath,
    Expression<bool>? isDownloaded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentAssetId != null) 'parent_asset_id': parentAssetId,
      if (name != null) 'name': name,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (url != null) 'url': url,
      if (type != null) 'type': type,
      if (format != null) 'format': format,
      if (extension != null) 'extension': extension,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalChildAssetsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? parentAssetId,
    Value<String>? name,
    Value<String?>? title,
    Value<String?>? description,
    Value<String>? url,
    Value<String?>? type,
    Value<String?>? format,
    Value<String?>? extension,
    Value<BigInt?>? sizeBytes,
    Value<String?>? localFilePath,
    Value<bool>? isDownloaded,
    Value<int>? rowid,
  }) {
    return LocalChildAssetsTableCompanion(
      id: id ?? this.id,
      parentAssetId: parentAssetId ?? this.parentAssetId,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      type: type ?? this.type,
      format: format ?? this.format,
      extension: extension ?? this.extension,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      localFilePath: localFilePath ?? this.localFilePath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentAssetId.present) {
      map['parent_asset_id'] = Variable<String>(parentAssetId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<BigInt>(sizeBytes.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<bool>(isDownloaded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChildAssetsTableCompanion(')
          ..write('id: $id, ')
          ..write('parentAssetId: $parentAssetId, ')
          ..write('name: $name, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('url: $url, ')
          ..write('type: $type, ')
          ..write('format: $format, ')
          ..write('extension: $extension, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetPlaybackProgressTableTable extends AssetPlaybackProgressTable
    with
        TableInfo<
          $AssetPlaybackProgressTableTable,
          AssetPlaybackProgressTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetPlaybackProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    assetId,
    userId,
    positionMs,
    durationMs,
    isCompleted,
    completedAt,
    isSynced,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_playback_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetPlaybackProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId, userId};
  @override
  AssetPlaybackProgressTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetPlaybackProgressTableData(
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AssetPlaybackProgressTableTable createAlias(String alias) {
    return $AssetPlaybackProgressTableTable(attachedDatabase, alias);
  }
}

class AssetPlaybackProgressTableData extends DataClass
    implements Insertable<AssetPlaybackProgressTableData> {
  final String assetId;
  final String userId;
  final int positionMs;
  final int durationMs;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isSynced;
  final DateTime updatedAt;
  const AssetPlaybackProgressTableData({
    required this.assetId,
    required this.userId,
    required this.positionMs,
    required this.durationMs,
    required this.isCompleted,
    this.completedAt,
    required this.isSynced,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<String>(assetId);
    map['user_id'] = Variable<String>(userId);
    map['position_ms'] = Variable<int>(positionMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AssetPlaybackProgressTableCompanion toCompanion(bool nullToAbsent) {
    return AssetPlaybackProgressTableCompanion(
      assetId: Value(assetId),
      userId: Value(userId),
      positionMs: Value(positionMs),
      durationMs: Value(durationMs),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
    );
  }

  factory AssetPlaybackProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetPlaybackProgressTableData(
      assetId: serializer.fromJson<String>(json['assetId']),
      userId: serializer.fromJson<String>(json['userId']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<String>(assetId),
      'userId': serializer.toJson<String>(userId),
      'positionMs': serializer.toJson<int>(positionMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AssetPlaybackProgressTableData copyWith({
    String? assetId,
    String? userId,
    int? positionMs,
    int? durationMs,
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    bool? isSynced,
    DateTime? updatedAt,
  }) => AssetPlaybackProgressTableData(
    assetId: assetId ?? this.assetId,
    userId: userId ?? this.userId,
    positionMs: positionMs ?? this.positionMs,
    durationMs: durationMs ?? this.durationMs,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    isSynced: isSynced ?? this.isSynced,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AssetPlaybackProgressTableData copyWithCompanion(
    AssetPlaybackProgressTableCompanion data,
  ) {
    return AssetPlaybackProgressTableData(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      userId: data.userId.present ? data.userId.value : this.userId,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetPlaybackProgressTableData(')
          ..write('assetId: $assetId, ')
          ..write('userId: $userId, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    assetId,
    userId,
    positionMs,
    durationMs,
    isCompleted,
    completedAt,
    isSynced,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetPlaybackProgressTableData &&
          other.assetId == this.assetId &&
          other.userId == this.userId &&
          other.positionMs == this.positionMs &&
          other.durationMs == this.durationMs &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt);
}

class AssetPlaybackProgressTableCompanion
    extends UpdateCompanion<AssetPlaybackProgressTableData> {
  final Value<String> assetId;
  final Value<String> userId;
  final Value<int> positionMs;
  final Value<int> durationMs;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<bool> isSynced;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AssetPlaybackProgressTableCompanion({
    this.assetId = const Value.absent(),
    this.userId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetPlaybackProgressTableCompanion.insert({
    required String assetId,
    required String userId,
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : assetId = Value(assetId),
       userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<AssetPlaybackProgressTableData> custom({
    Expression<String>? assetId,
    Expression<String>? userId,
    Expression<int>? positionMs,
    Expression<int>? durationMs,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<bool>? isSynced,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (userId != null) 'user_id': userId,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetPlaybackProgressTableCompanion copyWith({
    Value<String>? assetId,
    Value<String>? userId,
    Value<int>? positionMs,
    Value<int>? durationMs,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<bool>? isSynced,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AssetPlaybackProgressTableCompanion(
      assetId: assetId ?? this.assetId,
      userId: userId ?? this.userId,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetPlaybackProgressTableCompanion(')
          ..write('assetId: $assetId, ')
          ..write('userId: $userId, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineSyncQueueTableTable extends OfflineSyncQueueTable
    with TableInfo<$OfflineSyncQueueTableTable, OfflineSyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineSyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionType,
    payloadJson,
    attempts,
    lastAttemptAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflineSyncQueueTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineSyncQueueTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineSyncQueueTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OfflineSyncQueueTableTable createAlias(String alias) {
    return $OfflineSyncQueueTableTable(attachedDatabase, alias);
  }
}

class OfflineSyncQueueTableData extends DataClass
    implements Insertable<OfflineSyncQueueTableData> {
  final int id;
  final String actionType;
  final String payloadJson;
  final int attempts;
  final DateTime? lastAttemptAt;
  final DateTime createdAt;
  const OfflineSyncQueueTableData({
    required this.id,
    required this.actionType,
    required this.payloadJson,
    required this.attempts,
    this.lastAttemptAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OfflineSyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return OfflineSyncQueueTableCompanion(
      id: Value(id),
      actionType: Value(actionType),
      payloadJson: Value(payloadJson),
      attempts: Value(attempts),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      createdAt: Value(createdAt),
    );
  }

  factory OfflineSyncQueueTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineSyncQueueTableData(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OfflineSyncQueueTableData copyWith({
    int? id,
    String? actionType,
    String? payloadJson,
    int? attempts,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    DateTime? createdAt,
  }) => OfflineSyncQueueTableData(
    id: id ?? this.id,
    actionType: actionType ?? this.actionType,
    payloadJson: payloadJson ?? this.payloadJson,
    attempts: attempts ?? this.attempts,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    createdAt: createdAt ?? this.createdAt,
  );
  OfflineSyncQueueTableData copyWithCompanion(
    OfflineSyncQueueTableCompanion data,
  ) {
    return OfflineSyncQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSyncQueueTableData(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actionType,
    payloadJson,
    attempts,
    lastAttemptAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineSyncQueueTableData &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.payloadJson == this.payloadJson &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.createdAt == this.createdAt);
}

class OfflineSyncQueueTableCompanion
    extends UpdateCompanion<OfflineSyncQueueTableData> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> payloadJson;
  final Value<int> attempts;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime> createdAt;
  const OfflineSyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OfflineSyncQueueTableCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String payloadJson,
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    required DateTime createdAt,
  }) : actionType = Value(actionType),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OfflineSyncQueueTableData> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? payloadJson,
    Expression<int>? attempts,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OfflineSyncQueueTableCompanion copyWith({
    Value<int>? id,
    Value<String>? actionType,
    Value<String>? payloadJson,
    Value<int>? attempts,
    Value<DateTime?>? lastAttemptAt,
    Value<DateTime>? createdAt,
  }) {
    return OfflineSyncQueueTableCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      payloadJson: payloadJson ?? this.payloadJson,
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalAssetsTableTable localAssetsTable = $LocalAssetsTableTable(
    this,
  );
  late final $LocalChildAssetsTableTable localChildAssetsTable =
      $LocalChildAssetsTableTable(this);
  late final $AssetPlaybackProgressTableTable assetPlaybackProgressTable =
      $AssetPlaybackProgressTableTable(this);
  late final $OfflineSyncQueueTableTable offlineSyncQueueTable =
      $OfflineSyncQueueTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localAssetsTable,
    localChildAssetsTable,
    assetPlaybackProgressTable,
    offlineSyncQueueTable,
  ];
}

typedef $$LocalAssetsTableTableCreateCompanionBuilder =
    LocalAssetsTableCompanion Function({
      required String id,
      required String name,
      Value<String?> title,
      Value<String?> description,
      required String url,
      required String type,
      Value<String?> format,
      Value<String?> extension,
      Value<BigInt?> sizeBytes,
      Value<int?> durationSecs,
      Value<String> source,
      Value<String?> status,
      Value<String?> assetableType,
      Value<String?> assetableId,
      Value<String?> parentAssetId,
      Value<String?> createdById,
      Value<String?> metadataJson,
      Value<String?> childrenJson,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> downloadState,
      Value<double> downloadProgress,
      Value<String?> localFilePath,
      Value<String?> errorMessage,
      Value<DateTime?> downloadedAt,
      Value<int> rowid,
    });
typedef $$LocalAssetsTableTableUpdateCompanionBuilder =
    LocalAssetsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> title,
      Value<String?> description,
      Value<String> url,
      Value<String> type,
      Value<String?> format,
      Value<String?> extension,
      Value<BigInt?> sizeBytes,
      Value<int?> durationSecs,
      Value<String> source,
      Value<String?> status,
      Value<String?> assetableType,
      Value<String?> assetableId,
      Value<String?> parentAssetId,
      Value<String?> createdById,
      Value<String?> metadataJson,
      Value<String?> childrenJson,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> downloadState,
      Value<double> downloadProgress,
      Value<String?> localFilePath,
      Value<String?> errorMessage,
      Value<DateTime?> downloadedAt,
      Value<int> rowid,
    });

class $$LocalAssetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssetsTableTable> {
  $$LocalAssetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSecs => $composableBuilder(
    column: $table.durationSecs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetableType => $composableBuilder(
    column: $table.assetableType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetableId => $composableBuilder(
    column: $table.assetableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentAssetId => $composableBuilder(
    column: $table.parentAssetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childrenJson => $composableBuilder(
    column: $table.childrenJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadState => $composableBuilder(
    column: $table.downloadState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get downloadProgress => $composableBuilder(
    column: $table.downloadProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssetsTableTable> {
  $$LocalAssetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSecs => $composableBuilder(
    column: $table.durationSecs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetableType => $composableBuilder(
    column: $table.assetableType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetableId => $composableBuilder(
    column: $table.assetableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentAssetId => $composableBuilder(
    column: $table.parentAssetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childrenJson => $composableBuilder(
    column: $table.childrenJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadState => $composableBuilder(
    column: $table.downloadState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get downloadProgress => $composableBuilder(
    column: $table.downloadProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssetsTableTable> {
  $$LocalAssetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get extension =>
      $composableBuilder(column: $table.extension, builder: (column) => column);

  GeneratedColumn<BigInt> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get durationSecs => $composableBuilder(
    column: $table.durationSecs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get assetableType => $composableBuilder(
    column: $table.assetableType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assetableId => $composableBuilder(
    column: $table.assetableId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentAssetId => $composableBuilder(
    column: $table.parentAssetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get childrenJson => $composableBuilder(
    column: $table.childrenJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get downloadState => $composableBuilder(
    column: $table.downloadState,
    builder: (column) => column,
  );

  GeneratedColumn<double> get downloadProgress => $composableBuilder(
    column: $table.downloadProgress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$LocalAssetsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssetsTableTable,
          LocalAssetsTableData,
          $$LocalAssetsTableTableFilterComposer,
          $$LocalAssetsTableTableOrderingComposer,
          $$LocalAssetsTableTableAnnotationComposer,
          $$LocalAssetsTableTableCreateCompanionBuilder,
          $$LocalAssetsTableTableUpdateCompanionBuilder,
          (
            LocalAssetsTableData,
            BaseReferences<
              _$AppDatabase,
              $LocalAssetsTableTable,
              LocalAssetsTableData
            >,
          ),
          LocalAssetsTableData,
          PrefetchHooks Function()
        > {
  $$LocalAssetsTableTableTableManager(
    _$AppDatabase db,
    $LocalAssetsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAssetsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAssetsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<String?> extension = const Value.absent(),
                Value<BigInt?> sizeBytes = const Value.absent(),
                Value<int?> durationSecs = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> assetableType = const Value.absent(),
                Value<String?> assetableId = const Value.absent(),
                Value<String?> parentAssetId = const Value.absent(),
                Value<String?> createdById = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<String?> childrenJson = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> downloadState = const Value.absent(),
                Value<double> downloadProgress = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetsTableCompanion(
                id: id,
                name: name,
                title: title,
                description: description,
                url: url,
                type: type,
                format: format,
                extension: extension,
                sizeBytes: sizeBytes,
                durationSecs: durationSecs,
                source: source,
                status: status,
                assetableType: assetableType,
                assetableId: assetableId,
                parentAssetId: parentAssetId,
                createdById: createdById,
                metadataJson: metadataJson,
                childrenJson: childrenJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                downloadState: downloadState,
                downloadProgress: downloadProgress,
                localFilePath: localFilePath,
                errorMessage: errorMessage,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String url,
                required String type,
                Value<String?> format = const Value.absent(),
                Value<String?> extension = const Value.absent(),
                Value<BigInt?> sizeBytes = const Value.absent(),
                Value<int?> durationSecs = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> assetableType = const Value.absent(),
                Value<String?> assetableId = const Value.absent(),
                Value<String?> parentAssetId = const Value.absent(),
                Value<String?> createdById = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<String?> childrenJson = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> downloadState = const Value.absent(),
                Value<double> downloadProgress = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetsTableCompanion.insert(
                id: id,
                name: name,
                title: title,
                description: description,
                url: url,
                type: type,
                format: format,
                extension: extension,
                sizeBytes: sizeBytes,
                durationSecs: durationSecs,
                source: source,
                status: status,
                assetableType: assetableType,
                assetableId: assetableId,
                parentAssetId: parentAssetId,
                createdById: createdById,
                metadataJson: metadataJson,
                childrenJson: childrenJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                downloadState: downloadState,
                downloadProgress: downloadProgress,
                localFilePath: localFilePath,
                errorMessage: errorMessage,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalAssetsTableTable, LocalAssetsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalAssetsTableTable,
                    LocalAssetsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAssetsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssetsTableTable,
      LocalAssetsTableData,
      $$LocalAssetsTableTableFilterComposer,
      $$LocalAssetsTableTableOrderingComposer,
      $$LocalAssetsTableTableAnnotationComposer,
      $$LocalAssetsTableTableCreateCompanionBuilder,
      $$LocalAssetsTableTableUpdateCompanionBuilder,
      (
        LocalAssetsTableData,
        BaseReferences<
          _$AppDatabase,
          $LocalAssetsTableTable,
          LocalAssetsTableData
        >,
      ),
      LocalAssetsTableData,
      PrefetchHooks Function()
    >;
typedef $$LocalChildAssetsTableTableCreateCompanionBuilder =
    LocalChildAssetsTableCompanion Function({
      required String id,
      required String parentAssetId,
      required String name,
      Value<String?> title,
      Value<String?> description,
      required String url,
      Value<String?> type,
      Value<String?> format,
      Value<String?> extension,
      Value<BigInt?> sizeBytes,
      Value<String?> localFilePath,
      Value<bool> isDownloaded,
      Value<int> rowid,
    });
typedef $$LocalChildAssetsTableTableUpdateCompanionBuilder =
    LocalChildAssetsTableCompanion Function({
      Value<String> id,
      Value<String> parentAssetId,
      Value<String> name,
      Value<String?> title,
      Value<String?> description,
      Value<String> url,
      Value<String?> type,
      Value<String?> format,
      Value<String?> extension,
      Value<BigInt?> sizeBytes,
      Value<String?> localFilePath,
      Value<bool> isDownloaded,
      Value<int> rowid,
    });

class $$LocalChildAssetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocalChildAssetsTableTable> {
  $$LocalChildAssetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentAssetId => $composableBuilder(
    column: $table.parentAssetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalChildAssetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalChildAssetsTableTable> {
  $$LocalChildAssetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentAssetId => $composableBuilder(
    column: $table.parentAssetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChildAssetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalChildAssetsTableTable> {
  $$LocalChildAssetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentAssetId => $composableBuilder(
    column: $table.parentAssetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get extension =>
      $composableBuilder(column: $table.extension, builder: (column) => column);

  GeneratedColumn<BigInt> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => column,
  );
}

class $$LocalChildAssetsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalChildAssetsTableTable,
          LocalChildAssetsTableData,
          $$LocalChildAssetsTableTableFilterComposer,
          $$LocalChildAssetsTableTableOrderingComposer,
          $$LocalChildAssetsTableTableAnnotationComposer,
          $$LocalChildAssetsTableTableCreateCompanionBuilder,
          $$LocalChildAssetsTableTableUpdateCompanionBuilder,
          (
            LocalChildAssetsTableData,
            BaseReferences<
              _$AppDatabase,
              $LocalChildAssetsTableTable,
              LocalChildAssetsTableData
            >,
          ),
          LocalChildAssetsTableData,
          PrefetchHooks Function()
        > {
  $$LocalChildAssetsTableTableTableManager(
    _$AppDatabase db,
    $LocalChildAssetsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalChildAssetsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalChildAssetsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalChildAssetsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> parentAssetId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<String?> extension = const Value.absent(),
                Value<BigInt?> sizeBytes = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<bool> isDownloaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChildAssetsTableCompanion(
                id: id,
                parentAssetId: parentAssetId,
                name: name,
                title: title,
                description: description,
                url: url,
                type: type,
                format: format,
                extension: extension,
                sizeBytes: sizeBytes,
                localFilePath: localFilePath,
                isDownloaded: isDownloaded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String parentAssetId,
                required String name,
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String url,
                Value<String?> type = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<String?> extension = const Value.absent(),
                Value<BigInt?> sizeBytes = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<bool> isDownloaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChildAssetsTableCompanion.insert(
                id: id,
                parentAssetId: parentAssetId,
                name: name,
                title: title,
                description: description,
                url: url,
                type: type,
                format: format,
                extension: extension,
                sizeBytes: sizeBytes,
                localFilePath: localFilePath,
                isDownloaded: isDownloaded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocalChildAssetsTableTable,
                    LocalChildAssetsTableData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalChildAssetsTableTable,
                    LocalChildAssetsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalChildAssetsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalChildAssetsTableTable,
      LocalChildAssetsTableData,
      $$LocalChildAssetsTableTableFilterComposer,
      $$LocalChildAssetsTableTableOrderingComposer,
      $$LocalChildAssetsTableTableAnnotationComposer,
      $$LocalChildAssetsTableTableCreateCompanionBuilder,
      $$LocalChildAssetsTableTableUpdateCompanionBuilder,
      (
        LocalChildAssetsTableData,
        BaseReferences<
          _$AppDatabase,
          $LocalChildAssetsTableTable,
          LocalChildAssetsTableData
        >,
      ),
      LocalChildAssetsTableData,
      PrefetchHooks Function()
    >;
typedef $$AssetPlaybackProgressTableTableCreateCompanionBuilder =
    AssetPlaybackProgressTableCompanion Function({
      required String assetId,
      required String userId,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<bool> isSynced,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AssetPlaybackProgressTableTableUpdateCompanionBuilder =
    AssetPlaybackProgressTableCompanion Function({
      Value<String> assetId,
      Value<String> userId,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<bool> isSynced,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AssetPlaybackProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $AssetPlaybackProgressTableTable> {
  $$AssetPlaybackProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetPlaybackProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetPlaybackProgressTableTable> {
  $$AssetPlaybackProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetPlaybackProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetPlaybackProgressTableTable> {
  $$AssetPlaybackProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AssetPlaybackProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetPlaybackProgressTableTable,
          AssetPlaybackProgressTableData,
          $$AssetPlaybackProgressTableTableFilterComposer,
          $$AssetPlaybackProgressTableTableOrderingComposer,
          $$AssetPlaybackProgressTableTableAnnotationComposer,
          $$AssetPlaybackProgressTableTableCreateCompanionBuilder,
          $$AssetPlaybackProgressTableTableUpdateCompanionBuilder,
          (
            AssetPlaybackProgressTableData,
            BaseReferences<
              _$AppDatabase,
              $AssetPlaybackProgressTableTable,
              AssetPlaybackProgressTableData
            >,
          ),
          AssetPlaybackProgressTableData,
          PrefetchHooks Function()
        > {
  $$AssetPlaybackProgressTableTableTableManager(
    _$AppDatabase db,
    $AssetPlaybackProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetPlaybackProgressTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AssetPlaybackProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AssetPlaybackProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> assetId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetPlaybackProgressTableCompanion(
                assetId: assetId,
                userId: userId,
                positionMs: positionMs,
                durationMs: durationMs,
                isCompleted: isCompleted,
                completedAt: completedAt,
                isSynced: isSynced,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assetId,
                required String userId,
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AssetPlaybackProgressTableCompanion.insert(
                assetId: assetId,
                userId: userId,
                positionMs: positionMs,
                durationMs: durationMs,
                isCompleted: isCompleted,
                completedAt: completedAt,
                isSynced: isSynced,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $AssetPlaybackProgressTableTable,
                    AssetPlaybackProgressTableData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AssetPlaybackProgressTableTable,
                    AssetPlaybackProgressTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetPlaybackProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetPlaybackProgressTableTable,
      AssetPlaybackProgressTableData,
      $$AssetPlaybackProgressTableTableFilterComposer,
      $$AssetPlaybackProgressTableTableOrderingComposer,
      $$AssetPlaybackProgressTableTableAnnotationComposer,
      $$AssetPlaybackProgressTableTableCreateCompanionBuilder,
      $$AssetPlaybackProgressTableTableUpdateCompanionBuilder,
      (
        AssetPlaybackProgressTableData,
        BaseReferences<
          _$AppDatabase,
          $AssetPlaybackProgressTableTable,
          AssetPlaybackProgressTableData
        >,
      ),
      AssetPlaybackProgressTableData,
      PrefetchHooks Function()
    >;
typedef $$OfflineSyncQueueTableTableCreateCompanionBuilder =
    OfflineSyncQueueTableCompanion Function({
      Value<int> id,
      required String actionType,
      required String payloadJson,
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      required DateTime createdAt,
    });
typedef $$OfflineSyncQueueTableTableUpdateCompanionBuilder =
    OfflineSyncQueueTableCompanion Function({
      Value<int> id,
      Value<String> actionType,
      Value<String> payloadJson,
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime> createdAt,
    });

class $$OfflineSyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineSyncQueueTableTable> {
  $$OfflineSyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineSyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineSyncQueueTableTable> {
  $$OfflineSyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineSyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineSyncQueueTableTable> {
  $$OfflineSyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OfflineSyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfflineSyncQueueTableTable,
          OfflineSyncQueueTableData,
          $$OfflineSyncQueueTableTableFilterComposer,
          $$OfflineSyncQueueTableTableOrderingComposer,
          $$OfflineSyncQueueTableTableAnnotationComposer,
          $$OfflineSyncQueueTableTableCreateCompanionBuilder,
          $$OfflineSyncQueueTableTableUpdateCompanionBuilder,
          (
            OfflineSyncQueueTableData,
            BaseReferences<
              _$AppDatabase,
              $OfflineSyncQueueTableTable,
              OfflineSyncQueueTableData
            >,
          ),
          OfflineSyncQueueTableData,
          PrefetchHooks Function()
        > {
  $$OfflineSyncQueueTableTableTableManager(
    _$AppDatabase db,
    $OfflineSyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineSyncQueueTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$OfflineSyncQueueTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OfflineSyncQueueTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OfflineSyncQueueTableCompanion(
                id: id,
                actionType: actionType,
                payloadJson: payloadJson,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String actionType,
                required String payloadJson,
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                required DateTime createdAt,
              }) => OfflineSyncQueueTableCompanion.insert(
                id: id,
                actionType: actionType,
                payloadJson: payloadJson,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $OfflineSyncQueueTableTable,
                    OfflineSyncQueueTableData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OfflineSyncQueueTableTable,
                    OfflineSyncQueueTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineSyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfflineSyncQueueTableTable,
      OfflineSyncQueueTableData,
      $$OfflineSyncQueueTableTableFilterComposer,
      $$OfflineSyncQueueTableTableOrderingComposer,
      $$OfflineSyncQueueTableTableAnnotationComposer,
      $$OfflineSyncQueueTableTableCreateCompanionBuilder,
      $$OfflineSyncQueueTableTableUpdateCompanionBuilder,
      (
        OfflineSyncQueueTableData,
        BaseReferences<
          _$AppDatabase,
          $OfflineSyncQueueTableTable,
          OfflineSyncQueueTableData
        >,
      ),
      OfflineSyncQueueTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalAssetsTableTableTableManager get localAssetsTable =>
      $$LocalAssetsTableTableTableManager(_db, _db.localAssetsTable);
  $$LocalChildAssetsTableTableTableManager get localChildAssetsTable =>
      $$LocalChildAssetsTableTableTableManager(_db, _db.localChildAssetsTable);
  $$AssetPlaybackProgressTableTableTableManager
  get assetPlaybackProgressTable =>
      $$AssetPlaybackProgressTableTableTableManager(
        _db,
        _db.assetPlaybackProgressTable,
      );
  $$OfflineSyncQueueTableTableTableManager get offlineSyncQueueTable =>
      $$OfflineSyncQueueTableTableTableManager(_db, _db.offlineSyncQueueTable);
}
