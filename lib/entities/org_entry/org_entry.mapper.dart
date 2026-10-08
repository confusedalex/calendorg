// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'org_entry.dart';

class OrgEntryMapper extends ClassMapperBase<OrgEntry> {
  OrgEntryMapper._();

  static OrgEntryMapper? _instance;
  static OrgEntryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrgEntryMapper._());
      MapperContainer.globals.useAll([
        OrgTimestampMapper(),
        OrgPlanningEntryMapper(),
      ]);
      OrgEntryLocatorMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrgEntry';

  static OrgEntryLocator _$locator(OrgEntry v) => v.locator;
  static const Field<OrgEntry, OrgEntryLocator> _f$locator = Field(
    'locator',
    _$locator,
  );
  static String? _$todoKeyword(OrgEntry v) => v.todoKeyword;
  static const Field<OrgEntry, String> _f$todoKeyword = Field(
    'todoKeyword',
    _$todoKeyword,
  );
  static bool _$containsTimestampInHeadline(OrgEntry v) =>
      v.containsTimestampInHeadline;
  static const Field<OrgEntry, bool> _f$containsTimestampInHeadline = Field(
    'containsTimestampInHeadline',
    _$containsTimestampInHeadline,
  );
  static String _$title(OrgEntry v) => v.title;
  static const Field<OrgEntry, String> _f$title = Field('title', _$title);
  static List<String> _$tags(OrgEntry v) => v.tags;
  static const Field<OrgEntry, List<String>> _f$tags = Field('tags', _$tags);
  static List<OrgTimestamp> _$timestamps(OrgEntry v) => v.timestamps;
  static const Field<OrgEntry, List<OrgTimestamp>> _f$timestamps = Field(
    'timestamps',
    _$timestamps,
  );
  static OrgPlanningEntry? _$scheduled(OrgEntry v) => v.scheduled;
  static const Field<OrgEntry, OrgPlanningEntry> _f$scheduled = Field(
    'scheduled',
    _$scheduled,
    opt: true,
  );
  static OrgPlanningEntry? _$deadline(OrgEntry v) => v.deadline;
  static const Field<OrgEntry, OrgPlanningEntry> _f$deadline = Field(
    'deadline',
    _$deadline,
    opt: true,
  );
  static String _$filePath(OrgEntry v) => v.filePath;
  static const Field<OrgEntry, String> _f$filePath = Field(
    'filePath',
    _$filePath,
  );
  static String _$fileHash(OrgEntry v) => v.fileHash;
  static const Field<OrgEntry, String> _f$fileHash = Field(
    'fileHash',
    _$fileHash,
  );

  @override
  final MappableFields<OrgEntry> fields = const {
    #locator: _f$locator,
    #todoKeyword: _f$todoKeyword,
    #containsTimestampInHeadline: _f$containsTimestampInHeadline,
    #title: _f$title,
    #tags: _f$tags,
    #timestamps: _f$timestamps,
    #scheduled: _f$scheduled,
    #deadline: _f$deadline,
    #filePath: _f$filePath,
    #fileHash: _f$fileHash,
  };

  static OrgEntry _instantiate(DecodingData data) {
    return OrgEntry(
      locator: data.dec(_f$locator),
      todoKeyword: data.dec(_f$todoKeyword),
      containsTimestampInHeadline: data.dec(_f$containsTimestampInHeadline),
      title: data.dec(_f$title),
      tags: data.dec(_f$tags),
      timestamps: data.dec(_f$timestamps),
      scheduled: data.dec(_f$scheduled),
      deadline: data.dec(_f$deadline),
      filePath: data.dec(_f$filePath),
      fileHash: data.dec(_f$fileHash),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrgEntry fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrgEntry>(map);
  }

  static OrgEntry fromJson(String json) {
    return ensureInitialized().decodeJson<OrgEntry>(json);
  }
}

mixin OrgEntryMappable {
  String toJson() {
    return OrgEntryMapper.ensureInitialized().encodeJson<OrgEntry>(
      this as OrgEntry,
    );
  }

  Map<String, dynamic> toMap() {
    return OrgEntryMapper.ensureInitialized().encodeMap<OrgEntry>(
      this as OrgEntry,
    );
  }

  OrgEntryCopyWith<OrgEntry, OrgEntry, OrgEntry> get copyWith =>
      _OrgEntryCopyWithImpl<OrgEntry, OrgEntry>(
        this as OrgEntry,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrgEntryMapper.ensureInitialized().stringifyValue(this as OrgEntry);
  }

  @override
  bool operator ==(Object other) {
    return OrgEntryMapper.ensureInitialized().equalsValue(
      this as OrgEntry,
      other,
    );
  }

  @override
  int get hashCode {
    return OrgEntryMapper.ensureInitialized().hashValue(this as OrgEntry);
  }
}

extension OrgEntryValueCopy<$R, $Out> on ObjectCopyWith<$R, OrgEntry, $Out> {
  OrgEntryCopyWith<$R, OrgEntry, $Out> get $asOrgEntry =>
      $base.as((v, t, t2) => _OrgEntryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrgEntryCopyWith<$R, $In extends OrgEntry, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  OrgEntryLocatorCopyWith<$R, OrgEntryLocator, OrgEntryLocator> get locator;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags;
  ListCopyWith<$R, OrgTimestamp, ObjectCopyWith<$R, OrgTimestamp, OrgTimestamp>>
  get timestamps;
  $R call({
    OrgEntryLocator? locator,
    String? todoKeyword,
    bool? containsTimestampInHeadline,
    String? title,
    List<String>? tags,
    List<OrgTimestamp>? timestamps,
    OrgPlanningEntry? scheduled,
    OrgPlanningEntry? deadline,
    String? filePath,
    String? fileHash,
  });
  OrgEntryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrgEntryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrgEntry, $Out>
    implements OrgEntryCopyWith<$R, OrgEntry, $Out> {
  _OrgEntryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrgEntry> $mapper =
      OrgEntryMapper.ensureInitialized();
  @override
  OrgEntryLocatorCopyWith<$R, OrgEntryLocator, OrgEntryLocator> get locator =>
      $value.locator.copyWith.$chain((v) => call(locator: v));
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags =>
      ListCopyWith(
        $value.tags,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(tags: v),
      );
  @override
  ListCopyWith<$R, OrgTimestamp, ObjectCopyWith<$R, OrgTimestamp, OrgTimestamp>>
  get timestamps => ListCopyWith(
    $value.timestamps,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(timestamps: v),
  );
  @override
  $R call({
    OrgEntryLocator? locator,
    Object? todoKeyword = $none,
    bool? containsTimestampInHeadline,
    String? title,
    List<String>? tags,
    List<OrgTimestamp>? timestamps,
    Object? scheduled = $none,
    Object? deadline = $none,
    String? filePath,
    String? fileHash,
  }) => $apply(
    FieldCopyWithData({
      if (locator != null) #locator: locator,
      if (todoKeyword != $none) #todoKeyword: todoKeyword,
      if (containsTimestampInHeadline != null)
        #containsTimestampInHeadline: containsTimestampInHeadline,
      if (title != null) #title: title,
      if (tags != null) #tags: tags,
      if (timestamps != null) #timestamps: timestamps,
      if (scheduled != $none) #scheduled: scheduled,
      if (deadline != $none) #deadline: deadline,
      if (filePath != null) #filePath: filePath,
      if (fileHash != null) #fileHash: fileHash,
    }),
  );
  @override
  OrgEntry $make(CopyWithData data) => OrgEntry(
    locator: data.get(#locator, or: $value.locator),
    todoKeyword: data.get(#todoKeyword, or: $value.todoKeyword),
    containsTimestampInHeadline: data.get(
      #containsTimestampInHeadline,
      or: $value.containsTimestampInHeadline,
    ),
    title: data.get(#title, or: $value.title),
    tags: data.get(#tags, or: $value.tags),
    timestamps: data.get(#timestamps, or: $value.timestamps),
    scheduled: data.get(#scheduled, or: $value.scheduled),
    deadline: data.get(#deadline, or: $value.deadline),
    filePath: data.get(#filePath, or: $value.filePath),
    fileHash: data.get(#fileHash, or: $value.fileHash),
  );

  @override
  OrgEntryCopyWith<$R2, OrgEntry, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrgEntryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

