// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MonitorsTable extends Monitors
    with TableInfo<$MonitorsTable, MonitorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uptimeRobotMonitorIdMeta =
      const VerificationMeta('uptimeRobotMonitorId');
  @override
  late final GeneratedColumn<int> uptimeRobotMonitorId = GeneratedColumn<int>(
    'uptime_robot_monitor_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _friendlyNameMeta = const VerificationMeta(
    'friendlyName',
  );
  @override
  late final GeneratedColumn<String> friendlyName = GeneratedColumn<String>(
    'friendly_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allTimeUptimeRatioMeta =
      const VerificationMeta('allTimeUptimeRatio');
  @override
  late final GeneratedColumn<double> allTimeUptimeRatio =
      GeneratedColumn<double>(
        'all_time_uptime_ratio',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _responseTimeMsMeta = const VerificationMeta(
    'responseTimeMs',
  );
  @override
  late final GeneratedColumn<int> responseTimeMs = GeneratedColumn<int>(
    'response_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNotifiedStatusMeta =
      const VerificationMeta('lastNotifiedStatus');
  @override
  late final GeneratedColumn<int> lastNotifiedStatus = GeneratedColumn<int>(
    'last_notified_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<bool> muted = GeneratedColumn<bool>(
    'muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    uptimeRobotMonitorId,
    friendlyName,
    url,
    type,
    status,
    allTimeUptimeRatio,
    responseTimeMs,
    lastSyncedAt,
    lastNotifiedStatus,
    muted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitors';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonitorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('uptime_robot_monitor_id')) {
      context.handle(
        _uptimeRobotMonitorIdMeta,
        uptimeRobotMonitorId.isAcceptableOrUnknown(
          data['uptime_robot_monitor_id']!,
          _uptimeRobotMonitorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uptimeRobotMonitorIdMeta);
    }
    if (data.containsKey('friendly_name')) {
      context.handle(
        _friendlyNameMeta,
        friendlyName.isAcceptableOrUnknown(
          data['friendly_name']!,
          _friendlyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_friendlyNameMeta);
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('all_time_uptime_ratio')) {
      context.handle(
        _allTimeUptimeRatioMeta,
        allTimeUptimeRatio.isAcceptableOrUnknown(
          data['all_time_uptime_ratio']!,
          _allTimeUptimeRatioMeta,
        ),
      );
    }
    if (data.containsKey('response_time_ms')) {
      context.handle(
        _responseTimeMsMeta,
        responseTimeMs.isAcceptableOrUnknown(
          data['response_time_ms']!,
          _responseTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    if (data.containsKey('last_notified_status')) {
      context.handle(
        _lastNotifiedStatusMeta,
        lastNotifiedStatus.isAcceptableOrUnknown(
          data['last_notified_status']!,
          _lastNotifiedStatusMeta,
        ),
      );
    }
    if (data.containsKey('muted')) {
      context.handle(
        _mutedMeta,
        muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonitorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitorRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      uptimeRobotMonitorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uptime_robot_monitor_id'],
      )!,
      friendlyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}friendly_name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      allTimeUptimeRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}all_time_uptime_ratio'],
      )!,
      responseTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_time_ms'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
      lastNotifiedStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_notified_status'],
      ),
      muted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}muted'],
      )!,
    );
  }

  @override
  $MonitorsTable createAlias(String alias) {
    return $MonitorsTable(attachedDatabase, alias);
  }
}

class MonitorRow extends DataClass implements Insertable<MonitorRow> {
  final String id;
  final String accountId;
  final int uptimeRobotMonitorId;
  final String friendlyName;
  final String url;
  final int type;
  final int status;
  final double allTimeUptimeRatio;
  final int responseTimeMs;
  final DateTime lastSyncedAt;
  final int? lastNotifiedStatus;
  final bool muted;
  const MonitorRow({
    required this.id,
    required this.accountId,
    required this.uptimeRobotMonitorId,
    required this.friendlyName,
    required this.url,
    required this.type,
    required this.status,
    required this.allTimeUptimeRatio,
    required this.responseTimeMs,
    required this.lastSyncedAt,
    this.lastNotifiedStatus,
    required this.muted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['uptime_robot_monitor_id'] = Variable<int>(uptimeRobotMonitorId);
    map['friendly_name'] = Variable<String>(friendlyName);
    map['url'] = Variable<String>(url);
    map['type'] = Variable<int>(type);
    map['status'] = Variable<int>(status);
    map['all_time_uptime_ratio'] = Variable<double>(allTimeUptimeRatio);
    map['response_time_ms'] = Variable<int>(responseTimeMs);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    if (!nullToAbsent || lastNotifiedStatus != null) {
      map['last_notified_status'] = Variable<int>(lastNotifiedStatus);
    }
    map['muted'] = Variable<bool>(muted);
    return map;
  }

  MonitorsCompanion toCompanion(bool nullToAbsent) {
    return MonitorsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      uptimeRobotMonitorId: Value(uptimeRobotMonitorId),
      friendlyName: Value(friendlyName),
      url: Value(url),
      type: Value(type),
      status: Value(status),
      allTimeUptimeRatio: Value(allTimeUptimeRatio),
      responseTimeMs: Value(responseTimeMs),
      lastSyncedAt: Value(lastSyncedAt),
      lastNotifiedStatus: lastNotifiedStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastNotifiedStatus),
      muted: Value(muted),
    );
  }

  factory MonitorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitorRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      uptimeRobotMonitorId: serializer.fromJson<int>(
        json['uptimeRobotMonitorId'],
      ),
      friendlyName: serializer.fromJson<String>(json['friendlyName']),
      url: serializer.fromJson<String>(json['url']),
      type: serializer.fromJson<int>(json['type']),
      status: serializer.fromJson<int>(json['status']),
      allTimeUptimeRatio: serializer.fromJson<double>(
        json['allTimeUptimeRatio'],
      ),
      responseTimeMs: serializer.fromJson<int>(json['responseTimeMs']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
      lastNotifiedStatus: serializer.fromJson<int?>(json['lastNotifiedStatus']),
      muted: serializer.fromJson<bool>(json['muted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'uptimeRobotMonitorId': serializer.toJson<int>(uptimeRobotMonitorId),
      'friendlyName': serializer.toJson<String>(friendlyName),
      'url': serializer.toJson<String>(url),
      'type': serializer.toJson<int>(type),
      'status': serializer.toJson<int>(status),
      'allTimeUptimeRatio': serializer.toJson<double>(allTimeUptimeRatio),
      'responseTimeMs': serializer.toJson<int>(responseTimeMs),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
      'lastNotifiedStatus': serializer.toJson<int?>(lastNotifiedStatus),
      'muted': serializer.toJson<bool>(muted),
    };
  }

  MonitorRow copyWith({
    String? id,
    String? accountId,
    int? uptimeRobotMonitorId,
    String? friendlyName,
    String? url,
    int? type,
    int? status,
    double? allTimeUptimeRatio,
    int? responseTimeMs,
    DateTime? lastSyncedAt,
    Value<int?> lastNotifiedStatus = const Value.absent(),
    bool? muted,
  }) => MonitorRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    uptimeRobotMonitorId: uptimeRobotMonitorId ?? this.uptimeRobotMonitorId,
    friendlyName: friendlyName ?? this.friendlyName,
    url: url ?? this.url,
    type: type ?? this.type,
    status: status ?? this.status,
    allTimeUptimeRatio: allTimeUptimeRatio ?? this.allTimeUptimeRatio,
    responseTimeMs: responseTimeMs ?? this.responseTimeMs,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    lastNotifiedStatus: lastNotifiedStatus.present
        ? lastNotifiedStatus.value
        : this.lastNotifiedStatus,
    muted: muted ?? this.muted,
  );
  MonitorRow copyWithCompanion(MonitorsCompanion data) {
    return MonitorRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      uptimeRobotMonitorId: data.uptimeRobotMonitorId.present
          ? data.uptimeRobotMonitorId.value
          : this.uptimeRobotMonitorId,
      friendlyName: data.friendlyName.present
          ? data.friendlyName.value
          : this.friendlyName,
      url: data.url.present ? data.url.value : this.url,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      allTimeUptimeRatio: data.allTimeUptimeRatio.present
          ? data.allTimeUptimeRatio.value
          : this.allTimeUptimeRatio,
      responseTimeMs: data.responseTimeMs.present
          ? data.responseTimeMs.value
          : this.responseTimeMs,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastNotifiedStatus: data.lastNotifiedStatus.present
          ? data.lastNotifiedStatus.value
          : this.lastNotifiedStatus,
      muted: data.muted.present ? data.muted.value : this.muted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitorRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('uptimeRobotMonitorId: $uptimeRobotMonitorId, ')
          ..write('friendlyName: $friendlyName, ')
          ..write('url: $url, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('allTimeUptimeRatio: $allTimeUptimeRatio, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastNotifiedStatus: $lastNotifiedStatus, ')
          ..write('muted: $muted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    uptimeRobotMonitorId,
    friendlyName,
    url,
    type,
    status,
    allTimeUptimeRatio,
    responseTimeMs,
    lastSyncedAt,
    lastNotifiedStatus,
    muted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitorRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.uptimeRobotMonitorId == this.uptimeRobotMonitorId &&
          other.friendlyName == this.friendlyName &&
          other.url == this.url &&
          other.type == this.type &&
          other.status == this.status &&
          other.allTimeUptimeRatio == this.allTimeUptimeRatio &&
          other.responseTimeMs == this.responseTimeMs &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastNotifiedStatus == this.lastNotifiedStatus &&
          other.muted == this.muted);
}

class MonitorsCompanion extends UpdateCompanion<MonitorRow> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<int> uptimeRobotMonitorId;
  final Value<String> friendlyName;
  final Value<String> url;
  final Value<int> type;
  final Value<int> status;
  final Value<double> allTimeUptimeRatio;
  final Value<int> responseTimeMs;
  final Value<DateTime> lastSyncedAt;
  final Value<int?> lastNotifiedStatus;
  final Value<bool> muted;
  final Value<int> rowid;
  const MonitorsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.uptimeRobotMonitorId = const Value.absent(),
    this.friendlyName = const Value.absent(),
    this.url = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.allTimeUptimeRatio = const Value.absent(),
    this.responseTimeMs = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastNotifiedStatus = const Value.absent(),
    this.muted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonitorsCompanion.insert({
    required String id,
    required String accountId,
    required int uptimeRobotMonitorId,
    required String friendlyName,
    required String url,
    required int type,
    required int status,
    this.allTimeUptimeRatio = const Value.absent(),
    this.responseTimeMs = const Value.absent(),
    required DateTime lastSyncedAt,
    this.lastNotifiedStatus = const Value.absent(),
    this.muted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       uptimeRobotMonitorId = Value(uptimeRobotMonitorId),
       friendlyName = Value(friendlyName),
       url = Value(url),
       type = Value(type),
       status = Value(status),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<MonitorRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<int>? uptimeRobotMonitorId,
    Expression<String>? friendlyName,
    Expression<String>? url,
    Expression<int>? type,
    Expression<int>? status,
    Expression<double>? allTimeUptimeRatio,
    Expression<int>? responseTimeMs,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? lastNotifiedStatus,
    Expression<bool>? muted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (uptimeRobotMonitorId != null)
        'uptime_robot_monitor_id': uptimeRobotMonitorId,
      if (friendlyName != null) 'friendly_name': friendlyName,
      if (url != null) 'url': url,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (allTimeUptimeRatio != null)
        'all_time_uptime_ratio': allTimeUptimeRatio,
      if (responseTimeMs != null) 'response_time_ms': responseTimeMs,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastNotifiedStatus != null)
        'last_notified_status': lastNotifiedStatus,
      if (muted != null) 'muted': muted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonitorsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<int>? uptimeRobotMonitorId,
    Value<String>? friendlyName,
    Value<String>? url,
    Value<int>? type,
    Value<int>? status,
    Value<double>? allTimeUptimeRatio,
    Value<int>? responseTimeMs,
    Value<DateTime>? lastSyncedAt,
    Value<int?>? lastNotifiedStatus,
    Value<bool>? muted,
    Value<int>? rowid,
  }) {
    return MonitorsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      uptimeRobotMonitorId: uptimeRobotMonitorId ?? this.uptimeRobotMonitorId,
      friendlyName: friendlyName ?? this.friendlyName,
      url: url ?? this.url,
      type: type ?? this.type,
      status: status ?? this.status,
      allTimeUptimeRatio: allTimeUptimeRatio ?? this.allTimeUptimeRatio,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastNotifiedStatus: lastNotifiedStatus ?? this.lastNotifiedStatus,
      muted: muted ?? this.muted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (uptimeRobotMonitorId.present) {
      map['uptime_robot_monitor_id'] = Variable<int>(
        uptimeRobotMonitorId.value,
      );
    }
    if (friendlyName.present) {
      map['friendly_name'] = Variable<String>(friendlyName.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (allTimeUptimeRatio.present) {
      map['all_time_uptime_ratio'] = Variable<double>(allTimeUptimeRatio.value);
    }
    if (responseTimeMs.present) {
      map['response_time_ms'] = Variable<int>(responseTimeMs.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastNotifiedStatus.present) {
      map['last_notified_status'] = Variable<int>(lastNotifiedStatus.value);
    }
    if (muted.present) {
      map['muted'] = Variable<bool>(muted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitorsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('uptimeRobotMonitorId: $uptimeRobotMonitorId, ')
          ..write('friendlyName: $friendlyName, ')
          ..write('url: $url, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('allTimeUptimeRatio: $allTimeUptimeRatio, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastNotifiedStatus: $lastNotifiedStatus, ')
          ..write('muted: $muted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatusHistoryTable extends StatusHistory
    with TableInfo<$StatusHistoryTable, StatusHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatusHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _monitorIdMeta = const VerificationMeta(
    'monitorId',
  );
  @override
  late final GeneratedColumn<String> monitorId = GeneratedColumn<String>(
    'monitor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES monitors (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseTimeMsMeta = const VerificationMeta(
    'responseTimeMs',
  );
  @override
  late final GeneratedColumn<int> responseTimeMs = GeneratedColumn<int>(
    'response_time_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowId,
    monitorId,
    status,
    recordedAt,
    responseTimeMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'status_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatusHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('monitor_id')) {
      context.handle(
        _monitorIdMeta,
        monitorId.isAcceptableOrUnknown(data['monitor_id']!, _monitorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_monitorIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('response_time_ms')) {
      context.handle(
        _responseTimeMsMeta,
        responseTimeMs.isAcceptableOrUnknown(
          data['response_time_ms']!,
          _responseTimeMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  StatusHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatusHistoryEntry(
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      )!,
      monitorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monitor_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      responseTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_time_ms'],
      ),
    );
  }

  @override
  $StatusHistoryTable createAlias(String alias) {
    return $StatusHistoryTable(attachedDatabase, alias);
  }
}

class StatusHistoryEntry extends DataClass
    implements Insertable<StatusHistoryEntry> {
  final int rowId;
  final String monitorId;
  final int status;
  final DateTime recordedAt;
  final int? responseTimeMs;
  const StatusHistoryEntry({
    required this.rowId,
    required this.monitorId,
    required this.status,
    required this.recordedAt,
    this.responseTimeMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['monitor_id'] = Variable<String>(monitorId);
    map['status'] = Variable<int>(status);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || responseTimeMs != null) {
      map['response_time_ms'] = Variable<int>(responseTimeMs);
    }
    return map;
  }

  StatusHistoryCompanion toCompanion(bool nullToAbsent) {
    return StatusHistoryCompanion(
      rowId: Value(rowId),
      monitorId: Value(monitorId),
      status: Value(status),
      recordedAt: Value(recordedAt),
      responseTimeMs: responseTimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(responseTimeMs),
    );
  }

  factory StatusHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatusHistoryEntry(
      rowId: serializer.fromJson<int>(json['rowId']),
      monitorId: serializer.fromJson<String>(json['monitorId']),
      status: serializer.fromJson<int>(json['status']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      responseTimeMs: serializer.fromJson<int?>(json['responseTimeMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'monitorId': serializer.toJson<String>(monitorId),
      'status': serializer.toJson<int>(status),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'responseTimeMs': serializer.toJson<int?>(responseTimeMs),
    };
  }

  StatusHistoryEntry copyWith({
    int? rowId,
    String? monitorId,
    int? status,
    DateTime? recordedAt,
    Value<int?> responseTimeMs = const Value.absent(),
  }) => StatusHistoryEntry(
    rowId: rowId ?? this.rowId,
    monitorId: monitorId ?? this.monitorId,
    status: status ?? this.status,
    recordedAt: recordedAt ?? this.recordedAt,
    responseTimeMs: responseTimeMs.present
        ? responseTimeMs.value
        : this.responseTimeMs,
  );
  StatusHistoryEntry copyWithCompanion(StatusHistoryCompanion data) {
    return StatusHistoryEntry(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      monitorId: data.monitorId.present ? data.monitorId.value : this.monitorId,
      status: data.status.present ? data.status.value : this.status,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      responseTimeMs: data.responseTimeMs.present
          ? data.responseTimeMs.value
          : this.responseTimeMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatusHistoryEntry(')
          ..write('rowId: $rowId, ')
          ..write('monitorId: $monitorId, ')
          ..write('status: $status, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('responseTimeMs: $responseTimeMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(rowId, monitorId, status, recordedAt, responseTimeMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusHistoryEntry &&
          other.rowId == this.rowId &&
          other.monitorId == this.monitorId &&
          other.status == this.status &&
          other.recordedAt == this.recordedAt &&
          other.responseTimeMs == this.responseTimeMs);
}

class StatusHistoryCompanion extends UpdateCompanion<StatusHistoryEntry> {
  final Value<int> rowId;
  final Value<String> monitorId;
  final Value<int> status;
  final Value<DateTime> recordedAt;
  final Value<int?> responseTimeMs;
  const StatusHistoryCompanion({
    this.rowId = const Value.absent(),
    this.monitorId = const Value.absent(),
    this.status = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.responseTimeMs = const Value.absent(),
  });
  StatusHistoryCompanion.insert({
    this.rowId = const Value.absent(),
    required String monitorId,
    required int status,
    required DateTime recordedAt,
    this.responseTimeMs = const Value.absent(),
  }) : monitorId = Value(monitorId),
       status = Value(status),
       recordedAt = Value(recordedAt);
  static Insertable<StatusHistoryEntry> custom({
    Expression<int>? rowId,
    Expression<String>? monitorId,
    Expression<int>? status,
    Expression<DateTime>? recordedAt,
    Expression<int>? responseTimeMs,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (monitorId != null) 'monitor_id': monitorId,
      if (status != null) 'status': status,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (responseTimeMs != null) 'response_time_ms': responseTimeMs,
    });
  }

  StatusHistoryCompanion copyWith({
    Value<int>? rowId,
    Value<String>? monitorId,
    Value<int>? status,
    Value<DateTime>? recordedAt,
    Value<int?>? responseTimeMs,
  }) {
    return StatusHistoryCompanion(
      rowId: rowId ?? this.rowId,
      monitorId: monitorId ?? this.monitorId,
      status: status ?? this.status,
      recordedAt: recordedAt ?? this.recordedAt,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (monitorId.present) {
      map['monitor_id'] = Variable<String>(monitorId.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (responseTimeMs.present) {
      map['response_time_ms'] = Variable<int>(responseTimeMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatusHistoryCompanion(')
          ..write('rowId: $rowId, ')
          ..write('monitorId: $monitorId, ')
          ..write('status: $status, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('responseTimeMs: $responseTimeMs')
          ..write(')'))
        .toString();
  }
}

class $NotificationLogTable extends NotificationLog
    with TableInfo<$NotificationLogTable, NotificationLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _monitorIdMeta = const VerificationMeta(
    'monitorId',
  );
  @override
  late final GeneratedColumn<String> monitorId = GeneratedColumn<String>(
    'monitor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES monitors (id)',
    ),
  );
  static const VerificationMeta _eventMeta = const VerificationMeta('event');
  @override
  late final GeneratedColumn<String> event = GeneratedColumn<String>(
    'event',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [rowId, monitorId, event, sentAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('monitor_id')) {
      context.handle(
        _monitorIdMeta,
        monitorId.isAcceptableOrUnknown(data['monitor_id']!, _monitorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_monitorIdMeta);
    }
    if (data.containsKey('event')) {
      context.handle(
        _eventMeta,
        event.isAcceptableOrUnknown(data['event']!, _eventMeta),
      );
    } else if (isInserting) {
      context.missing(_eventMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  NotificationLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationLogEntry(
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      )!,
      monitorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monitor_id'],
      )!,
      event: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      )!,
    );
  }

  @override
  $NotificationLogTable createAlias(String alias) {
    return $NotificationLogTable(attachedDatabase, alias);
  }
}

class NotificationLogEntry extends DataClass
    implements Insertable<NotificationLogEntry> {
  final int rowId;
  final String monitorId;
  final String event;
  final DateTime sentAt;
  const NotificationLogEntry({
    required this.rowId,
    required this.monitorId,
    required this.event,
    required this.sentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['monitor_id'] = Variable<String>(monitorId);
    map['event'] = Variable<String>(event);
    map['sent_at'] = Variable<DateTime>(sentAt);
    return map;
  }

  NotificationLogCompanion toCompanion(bool nullToAbsent) {
    return NotificationLogCompanion(
      rowId: Value(rowId),
      monitorId: Value(monitorId),
      event: Value(event),
      sentAt: Value(sentAt),
    );
  }

  factory NotificationLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationLogEntry(
      rowId: serializer.fromJson<int>(json['rowId']),
      monitorId: serializer.fromJson<String>(json['monitorId']),
      event: serializer.fromJson<String>(json['event']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'monitorId': serializer.toJson<String>(monitorId),
      'event': serializer.toJson<String>(event),
      'sentAt': serializer.toJson<DateTime>(sentAt),
    };
  }

  NotificationLogEntry copyWith({
    int? rowId,
    String? monitorId,
    String? event,
    DateTime? sentAt,
  }) => NotificationLogEntry(
    rowId: rowId ?? this.rowId,
    monitorId: monitorId ?? this.monitorId,
    event: event ?? this.event,
    sentAt: sentAt ?? this.sentAt,
  );
  NotificationLogEntry copyWithCompanion(NotificationLogCompanion data) {
    return NotificationLogEntry(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      monitorId: data.monitorId.present ? data.monitorId.value : this.monitorId,
      event: data.event.present ? data.event.value : this.event,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogEntry(')
          ..write('rowId: $rowId, ')
          ..write('monitorId: $monitorId, ')
          ..write('event: $event, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rowId, monitorId, event, sentAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationLogEntry &&
          other.rowId == this.rowId &&
          other.monitorId == this.monitorId &&
          other.event == this.event &&
          other.sentAt == this.sentAt);
}

class NotificationLogCompanion extends UpdateCompanion<NotificationLogEntry> {
  final Value<int> rowId;
  final Value<String> monitorId;
  final Value<String> event;
  final Value<DateTime> sentAt;
  const NotificationLogCompanion({
    this.rowId = const Value.absent(),
    this.monitorId = const Value.absent(),
    this.event = const Value.absent(),
    this.sentAt = const Value.absent(),
  });
  NotificationLogCompanion.insert({
    this.rowId = const Value.absent(),
    required String monitorId,
    required String event,
    required DateTime sentAt,
  }) : monitorId = Value(monitorId),
       event = Value(event),
       sentAt = Value(sentAt);
  static Insertable<NotificationLogEntry> custom({
    Expression<int>? rowId,
    Expression<String>? monitorId,
    Expression<String>? event,
    Expression<DateTime>? sentAt,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (monitorId != null) 'monitor_id': monitorId,
      if (event != null) 'event': event,
      if (sentAt != null) 'sent_at': sentAt,
    });
  }

  NotificationLogCompanion copyWith({
    Value<int>? rowId,
    Value<String>? monitorId,
    Value<String>? event,
    Value<DateTime>? sentAt,
  }) {
    return NotificationLogCompanion(
      rowId: rowId ?? this.rowId,
      monitorId: monitorId ?? this.monitorId,
      event: event ?? this.event,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (monitorId.present) {
      map['monitor_id'] = Variable<String>(monitorId.value);
    }
    if (event.present) {
      map['event'] = Variable<String>(event.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogCompanion(')
          ..write('rowId: $rowId, ')
          ..write('monitorId: $monitorId, ')
          ..write('event: $event, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MonitorsTable monitors = $MonitorsTable(this);
  late final $StatusHistoryTable statusHistory = $StatusHistoryTable(this);
  late final $NotificationLogTable notificationLog = $NotificationLogTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    monitors,
    statusHistory,
    notificationLog,
  ];
}

typedef $$MonitorsTableCreateCompanionBuilder =
    MonitorsCompanion Function({
      required String id,
      required String accountId,
      required int uptimeRobotMonitorId,
      required String friendlyName,
      required String url,
      required int type,
      required int status,
      Value<double> allTimeUptimeRatio,
      Value<int> responseTimeMs,
      required DateTime lastSyncedAt,
      Value<int?> lastNotifiedStatus,
      Value<bool> muted,
      Value<int> rowid,
    });
typedef $$MonitorsTableUpdateCompanionBuilder =
    MonitorsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<int> uptimeRobotMonitorId,
      Value<String> friendlyName,
      Value<String> url,
      Value<int> type,
      Value<int> status,
      Value<double> allTimeUptimeRatio,
      Value<int> responseTimeMs,
      Value<DateTime> lastSyncedAt,
      Value<int?> lastNotifiedStatus,
      Value<bool> muted,
      Value<int> rowid,
    });

final class $$MonitorsTableReferences
    extends BaseReferences<_$AppDatabase, $MonitorsTable, MonitorRow> {
  $$MonitorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StatusHistoryTable, List<StatusHistoryEntry>>
  _statusHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.statusHistory,
    aliasName: 'monitors__id__status_history__monitor_id',
  );

  $$StatusHistoryTableProcessedTableManager get statusHistoryRefs {
    final manager = $$StatusHistoryTableTableManager(
      $_db,
      $_db.statusHistory,
    ).filter((f) => f.monitorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_statusHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotificationLogTable, List<NotificationLogEntry>>
  _notificationLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.notificationLog,
    aliasName: 'monitors__id__notification_log__monitor_id',
  );

  $$NotificationLogTableProcessedTableManager get notificationLogRefs {
    final manager = $$NotificationLogTableTableManager(
      $_db,
      $_db.notificationLog,
    ).filter((f) => f.monitorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _notificationLogRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MonitorsTableFilterComposer
    extends Composer<_$AppDatabase, $MonitorsTable> {
  $$MonitorsTableFilterComposer({
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

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uptimeRobotMonitorId => $composableBuilder(
    column: $table.uptimeRobotMonitorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get friendlyName => $composableBuilder(
    column: $table.friendlyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get allTimeUptimeRatio => $composableBuilder(
    column: $table.allTimeUptimeRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastNotifiedStatus => $composableBuilder(
    column: $table.lastNotifiedStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> statusHistoryRefs(
    Expression<bool> Function($$StatusHistoryTableFilterComposer f) f,
  ) {
    final $$StatusHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.statusHistory,
      getReferencedColumn: (t) => t.monitorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatusHistoryTableFilterComposer(
            $db: $db,
            $table: $db.statusHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notificationLogRefs(
    Expression<bool> Function($$NotificationLogTableFilterComposer f) f,
  ) {
    final $$NotificationLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notificationLog,
      getReferencedColumn: (t) => t.monitorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotificationLogTableFilterComposer(
            $db: $db,
            $table: $db.notificationLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MonitorsTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitorsTable> {
  $$MonitorsTableOrderingComposer({
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

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uptimeRobotMonitorId => $composableBuilder(
    column: $table.uptimeRobotMonitorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get friendlyName => $composableBuilder(
    column: $table.friendlyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get allTimeUptimeRatio => $composableBuilder(
    column: $table.allTimeUptimeRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastNotifiedStatus => $composableBuilder(
    column: $table.lastNotifiedStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonitorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitorsTable> {
  $$MonitorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get uptimeRobotMonitorId => $composableBuilder(
    column: $table.uptimeRobotMonitorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get friendlyName => $composableBuilder(
    column: $table.friendlyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get allTimeUptimeRatio => $composableBuilder(
    column: $table.allTimeUptimeRatio,
    builder: (column) => column,
  );

  GeneratedColumn<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastNotifiedStatus => $composableBuilder(
    column: $table.lastNotifiedStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => column);

  Expression<T> statusHistoryRefs<T extends Object>(
    Expression<T> Function($$StatusHistoryTableAnnotationComposer a) f,
  ) {
    final $$StatusHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.statusHistory,
      getReferencedColumn: (t) => t.monitorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatusHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.statusHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notificationLogRefs<T extends Object>(
    Expression<T> Function($$NotificationLogTableAnnotationComposer a) f,
  ) {
    final $$NotificationLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notificationLog,
      getReferencedColumn: (t) => t.monitorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotificationLogTableAnnotationComposer(
            $db: $db,
            $table: $db.notificationLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MonitorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonitorsTable,
          MonitorRow,
          $$MonitorsTableFilterComposer,
          $$MonitorsTableOrderingComposer,
          $$MonitorsTableAnnotationComposer,
          $$MonitorsTableCreateCompanionBuilder,
          $$MonitorsTableUpdateCompanionBuilder,
          (MonitorRow, $$MonitorsTableReferences),
          MonitorRow,
          PrefetchHooks Function({
            bool statusHistoryRefs,
            bool notificationLogRefs,
          })
        > {
  $$MonitorsTableTableManager(_$AppDatabase db, $MonitorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonitorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonitorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> uptimeRobotMonitorId = const Value.absent(),
                Value<String> friendlyName = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<double> allTimeUptimeRatio = const Value.absent(),
                Value<int> responseTimeMs = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<int?> lastNotifiedStatus = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonitorsCompanion(
                id: id,
                accountId: accountId,
                uptimeRobotMonitorId: uptimeRobotMonitorId,
                friendlyName: friendlyName,
                url: url,
                type: type,
                status: status,
                allTimeUptimeRatio: allTimeUptimeRatio,
                responseTimeMs: responseTimeMs,
                lastSyncedAt: lastSyncedAt,
                lastNotifiedStatus: lastNotifiedStatus,
                muted: muted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required int uptimeRobotMonitorId,
                required String friendlyName,
                required String url,
                required int type,
                required int status,
                Value<double> allTimeUptimeRatio = const Value.absent(),
                Value<int> responseTimeMs = const Value.absent(),
                required DateTime lastSyncedAt,
                Value<int?> lastNotifiedStatus = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonitorsCompanion.insert(
                id: id,
                accountId: accountId,
                uptimeRobotMonitorId: uptimeRobotMonitorId,
                friendlyName: friendlyName,
                url: url,
                type: type,
                status: status,
                allTimeUptimeRatio: allTimeUptimeRatio,
                responseTimeMs: responseTimeMs,
                lastSyncedAt: lastSyncedAt,
                lastNotifiedStatus: lastNotifiedStatus,
                muted: muted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MonitorsTable, MonitorRow>(table),
                  $$MonitorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({statusHistoryRefs = false, notificationLogRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (statusHistoryRefs) db.statusHistory,
                    if (notificationLogRefs) db.notificationLog,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (statusHistoryRefs)
                        await $_getPrefetchedData<
                          MonitorRow,
                          $MonitorsTable,
                          StatusHistoryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$MonitorsTableReferences
                              ._statusHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MonitorsTableReferences(
                                db,
                                table,
                                p0,
                              ).statusHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.monitorId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notificationLogRefs)
                        await $_getPrefetchedData<
                          MonitorRow,
                          $MonitorsTable,
                          NotificationLogEntry
                        >(
                          currentTable: table,
                          referencedTable: $$MonitorsTableReferences
                              ._notificationLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MonitorsTableReferences(
                                db,
                                table,
                                p0,
                              ).notificationLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.monitorId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MonitorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonitorsTable,
      MonitorRow,
      $$MonitorsTableFilterComposer,
      $$MonitorsTableOrderingComposer,
      $$MonitorsTableAnnotationComposer,
      $$MonitorsTableCreateCompanionBuilder,
      $$MonitorsTableUpdateCompanionBuilder,
      (MonitorRow, $$MonitorsTableReferences),
      MonitorRow,
      PrefetchHooks Function({bool statusHistoryRefs, bool notificationLogRefs})
    >;
typedef $$StatusHistoryTableCreateCompanionBuilder =
    StatusHistoryCompanion Function({
      Value<int> rowId,
      required String monitorId,
      required int status,
      required DateTime recordedAt,
      Value<int?> responseTimeMs,
    });
typedef $$StatusHistoryTableUpdateCompanionBuilder =
    StatusHistoryCompanion Function({
      Value<int> rowId,
      Value<String> monitorId,
      Value<int> status,
      Value<DateTime> recordedAt,
      Value<int?> responseTimeMs,
    });

final class $$StatusHistoryTableReferences
    extends
        BaseReferences<_$AppDatabase, $StatusHistoryTable, StatusHistoryEntry> {
  $$StatusHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MonitorsTable _monitorIdTable(_$AppDatabase db) =>
      db.monitors.createAlias('status_history__monitor_id__monitors__id');

  $$MonitorsTableProcessedTableManager get monitorId {
    final $_column = $_itemColumn<String>('monitor_id')!;

    final manager = $$MonitorsTableTableManager(
      $_db,
      $_db.monitors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_monitorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StatusHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $StatusHistoryTable> {
  $$StatusHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  $$MonitorsTableFilterComposer get monitorId {
    final $$MonitorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monitorId,
      referencedTable: $db.monitors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonitorsTableFilterComposer(
            $db: $db,
            $table: $db.monitors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatusHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $StatusHistoryTable> {
  $$StatusHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$MonitorsTableOrderingComposer get monitorId {
    final $$MonitorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monitorId,
      referencedTable: $db.monitors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonitorsTableOrderingComposer(
            $db: $db,
            $table: $db.monitors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatusHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatusHistoryTable> {
  $$StatusHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => column,
  );

  $$MonitorsTableAnnotationComposer get monitorId {
    final $$MonitorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monitorId,
      referencedTable: $db.monitors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonitorsTableAnnotationComposer(
            $db: $db,
            $table: $db.monitors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatusHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatusHistoryTable,
          StatusHistoryEntry,
          $$StatusHistoryTableFilterComposer,
          $$StatusHistoryTableOrderingComposer,
          $$StatusHistoryTableAnnotationComposer,
          $$StatusHistoryTableCreateCompanionBuilder,
          $$StatusHistoryTableUpdateCompanionBuilder,
          (StatusHistoryEntry, $$StatusHistoryTableReferences),
          StatusHistoryEntry,
          PrefetchHooks Function({bool monitorId})
        > {
  $$StatusHistoryTableTableManager(_$AppDatabase db, $StatusHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatusHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatusHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatusHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String> monitorId = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int?> responseTimeMs = const Value.absent(),
              }) => StatusHistoryCompanion(
                rowId: rowId,
                monitorId: monitorId,
                status: status,
                recordedAt: recordedAt,
                responseTimeMs: responseTimeMs,
              ),
          createCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                required String monitorId,
                required int status,
                required DateTime recordedAt,
                Value<int?> responseTimeMs = const Value.absent(),
              }) => StatusHistoryCompanion.insert(
                rowId: rowId,
                monitorId: monitorId,
                status: status,
                recordedAt: recordedAt,
                responseTimeMs: responseTimeMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StatusHistoryTable, StatusHistoryEntry>(table),
                  $$StatusHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({monitorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (monitorId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.monitorId,
                                referencedTable: $$StatusHistoryTableReferences
                                    ._monitorIdTable(db),
                                referencedColumn: $$StatusHistoryTableReferences
                                    ._monitorIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StatusHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatusHistoryTable,
      StatusHistoryEntry,
      $$StatusHistoryTableFilterComposer,
      $$StatusHistoryTableOrderingComposer,
      $$StatusHistoryTableAnnotationComposer,
      $$StatusHistoryTableCreateCompanionBuilder,
      $$StatusHistoryTableUpdateCompanionBuilder,
      (StatusHistoryEntry, $$StatusHistoryTableReferences),
      StatusHistoryEntry,
      PrefetchHooks Function({bool monitorId})
    >;
typedef $$NotificationLogTableCreateCompanionBuilder =
    NotificationLogCompanion Function({
      Value<int> rowId,
      required String monitorId,
      required String event,
      required DateTime sentAt,
    });
typedef $$NotificationLogTableUpdateCompanionBuilder =
    NotificationLogCompanion Function({
      Value<int> rowId,
      Value<String> monitorId,
      Value<String> event,
      Value<DateTime> sentAt,
    });

final class $$NotificationLogTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NotificationLogTable,
          NotificationLogEntry
        > {
  $$NotificationLogTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MonitorsTable _monitorIdTable(_$AppDatabase db) =>
      db.monitors.createAlias('notification_log__monitor_id__monitors__id');

  $$MonitorsTableProcessedTableManager get monitorId {
    final $_column = $_itemColumn<String>('monitor_id')!;

    final manager = $$MonitorsTableTableManager(
      $_db,
      $_db.monitors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_monitorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotificationLogTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationLogTable> {
  $$NotificationLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get event => $composableBuilder(
    column: $table.event,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MonitorsTableFilterComposer get monitorId {
    final $$MonitorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monitorId,
      referencedTable: $db.monitors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonitorsTableFilterComposer(
            $db: $db,
            $table: $db.monitors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationLogTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationLogTable> {
  $$NotificationLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get event => $composableBuilder(
    column: $table.event,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MonitorsTableOrderingComposer get monitorId {
    final $$MonitorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monitorId,
      referencedTable: $db.monitors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonitorsTableOrderingComposer(
            $db: $db,
            $table: $db.monitors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationLogTable> {
  $$NotificationLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get event =>
      $composableBuilder(column: $table.event, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  $$MonitorsTableAnnotationComposer get monitorId {
    final $$MonitorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monitorId,
      referencedTable: $db.monitors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonitorsTableAnnotationComposer(
            $db: $db,
            $table: $db.monitors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationLogTable,
          NotificationLogEntry,
          $$NotificationLogTableFilterComposer,
          $$NotificationLogTableOrderingComposer,
          $$NotificationLogTableAnnotationComposer,
          $$NotificationLogTableCreateCompanionBuilder,
          $$NotificationLogTableUpdateCompanionBuilder,
          (NotificationLogEntry, $$NotificationLogTableReferences),
          NotificationLogEntry,
          PrefetchHooks Function({bool monitorId})
        > {
  $$NotificationLogTableTableManager(
    _$AppDatabase db,
    $NotificationLogTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String> monitorId = const Value.absent(),
                Value<String> event = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
              }) => NotificationLogCompanion(
                rowId: rowId,
                monitorId: monitorId,
                event: event,
                sentAt: sentAt,
              ),
          createCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                required String monitorId,
                required String event,
                required DateTime sentAt,
              }) => NotificationLogCompanion.insert(
                rowId: rowId,
                monitorId: monitorId,
                event: event,
                sentAt: sentAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotificationLogTable, NotificationLogEntry>(
                    table,
                  ),
                  $$NotificationLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({monitorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (monitorId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.monitorId,
                                referencedTable:
                                    $$NotificationLogTableReferences
                                        ._monitorIdTable(db),
                                referencedColumn:
                                    $$NotificationLogTableReferences
                                        ._monitorIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotificationLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationLogTable,
      NotificationLogEntry,
      $$NotificationLogTableFilterComposer,
      $$NotificationLogTableOrderingComposer,
      $$NotificationLogTableAnnotationComposer,
      $$NotificationLogTableCreateCompanionBuilder,
      $$NotificationLogTableUpdateCompanionBuilder,
      (NotificationLogEntry, $$NotificationLogTableReferences),
      NotificationLogEntry,
      PrefetchHooks Function({bool monitorId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MonitorsTableTableManager get monitors =>
      $$MonitorsTableTableManager(_db, _db.monitors);
  $$StatusHistoryTableTableManager get statusHistory =>
      $$StatusHistoryTableTableManager(_db, _db.statusHistory);
  $$NotificationLogTableTableManager get notificationLog =>
      $$NotificationLogTableTableManager(_db, _db.notificationLog);
}
