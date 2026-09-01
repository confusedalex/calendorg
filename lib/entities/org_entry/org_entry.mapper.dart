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
      OrgEntryCachedMapper.ensureInitialized();
      OrgEntryLoadedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrgEntry';

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

  @override
  final MappableFields<OrgEntry> fields = const {
    #todoKeyword: _f$todoKeyword,
    #containsTimestampInHeadline: _f$containsTimestampInHeadline,
    #title: _f$title,
    #tags: _f$tags,
    #timestamps: _f$timestamps,
    #scheduled: _f$scheduled,
    #deadline: _f$deadline,
  };

  static OrgEntry _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'OrgEntry',
      'type',
      '${data.value['type']}',
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
  String toJson();
  Map<String, dynamic> toMap();
  OrgEntryCopyWith<OrgEntry, OrgEntry, OrgEntry> get copyWith;
}

abstract class OrgEntryCopyWith<$R, $In extends OrgEntry, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags;
  ListCopyWith<$R, OrgTimestamp, ObjectCopyWith<$R, OrgTimestamp, OrgTimestamp>>
  get timestamps;
  $R call({
    String? todoKeyword,
    bool? containsTimestampInHeadline,
    String? title,
    List<String>? tags,
    List<OrgTimestamp>? timestamps,
    OrgPlanningEntry? scheduled,
    OrgPlanningEntry? deadline,
  });
  OrgEntryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class OrgEntryCachedMapper extends SubClassMapperBase<OrgEntryCached> {
  OrgEntryCachedMapper._();

  static OrgEntryCachedMapper? _instance;
  static OrgEntryCachedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrgEntryCachedMapper._());
      OrgEntryMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'OrgEntryCached';

  static String? _$todoKeyword(OrgEntryCached v) => v.todoKeyword;
  static const Field<OrgEntryCached, String> _f$todoKeyword = Field(
    'todoKeyword',
    _$todoKeyword,
  );
  static bool _$containsTimestampInHeadline(OrgEntryCached v) =>
      v.containsTimestampInHeadline;
  static const Field<OrgEntryCached, bool> _f$containsTimestampInHeadline =
      Field('containsTimestampInHeadline', _$containsTimestampInHeadline);
  static String _$title(OrgEntryCached v) => v.title;
  static const Field<OrgEntryCached, String> _f$title = Field('title', _$title);
  static List<String> _$tags(OrgEntryCached v) => v.tags;
  static const Field<OrgEntryCached, List<String>> _f$tags = Field(
    'tags',
    _$tags,
  );
  static List<OrgTimestamp> _$timestamps(OrgEntryCached v) => v.timestamps;
  static const Field<OrgEntryCached, List<OrgTimestamp>> _f$timestamps = Field(
    'timestamps',
    _$timestamps,
  );
  static OrgPlanningEntry? _$deadline(OrgEntryCached v) => v.deadline;
  static const Field<OrgEntryCached, OrgPlanningEntry> _f$deadline = Field(
    'deadline',
    _$deadline,
  );
  static OrgPlanningEntry? _$scheduled(OrgEntryCached v) => v.scheduled;
  static const Field<OrgEntryCached, OrgPlanningEntry> _f$scheduled = Field(
    'scheduled',
    _$scheduled,
  );

  @override
  final MappableFields<OrgEntryCached> fields = const {
    #todoKeyword: _f$todoKeyword,
    #containsTimestampInHeadline: _f$containsTimestampInHeadline,
    #title: _f$title,
    #tags: _f$tags,
    #timestamps: _f$timestamps,
    #deadline: _f$deadline,
    #scheduled: _f$scheduled,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'cached';
  @override
  late final ClassMapperBase superMapper = OrgEntryMapper.ensureInitialized();

  static OrgEntryCached _instantiate(DecodingData data) {
    return OrgEntryCached(
      todoKeyword: data.dec(_f$todoKeyword),
      containsTimestampInHeadline: data.dec(_f$containsTimestampInHeadline),
      title: data.dec(_f$title),
      tags: data.dec(_f$tags),
      timestamps: data.dec(_f$timestamps),
      deadline: data.dec(_f$deadline),
      scheduled: data.dec(_f$scheduled),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrgEntryCached fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrgEntryCached>(map);
  }

  static OrgEntryCached fromJson(String json) {
    return ensureInitialized().decodeJson<OrgEntryCached>(json);
  }
}

mixin OrgEntryCachedMappable {
  String toJson() {
    return OrgEntryCachedMapper.ensureInitialized().encodeJson<OrgEntryCached>(
      this as OrgEntryCached,
    );
  }

  Map<String, dynamic> toMap() {
    return OrgEntryCachedMapper.ensureInitialized().encodeMap<OrgEntryCached>(
      this as OrgEntryCached,
    );
  }

  OrgEntryCachedCopyWith<OrgEntryCached, OrgEntryCached, OrgEntryCached>
  get copyWith => _OrgEntryCachedCopyWithImpl<OrgEntryCached, OrgEntryCached>(
    this as OrgEntryCached,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return OrgEntryCachedMapper.ensureInitialized().stringifyValue(
      this as OrgEntryCached,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrgEntryCachedMapper.ensureInitialized().equalsValue(
      this as OrgEntryCached,
      other,
    );
  }

  @override
  int get hashCode {
    return OrgEntryCachedMapper.ensureInitialized().hashValue(
      this as OrgEntryCached,
    );
  }
}

extension OrgEntryCachedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrgEntryCached, $Out> {
  OrgEntryCachedCopyWith<$R, OrgEntryCached, $Out> get $asOrgEntryCached =>
      $base.as((v, t, t2) => _OrgEntryCachedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrgEntryCachedCopyWith<$R, $In extends OrgEntryCached, $Out>
    implements OrgEntryCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags;
  @override
  ListCopyWith<$R, OrgTimestamp, ObjectCopyWith<$R, OrgTimestamp, OrgTimestamp>>
  get timestamps;
  @override
  $R call({
    String? todoKeyword,
    bool? containsTimestampInHeadline,
    String? title,
    List<String>? tags,
    List<OrgTimestamp>? timestamps,
    OrgPlanningEntry? deadline,
    OrgPlanningEntry? scheduled,
  });
  OrgEntryCachedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrgEntryCachedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrgEntryCached, $Out>
    implements OrgEntryCachedCopyWith<$R, OrgEntryCached, $Out> {
  _OrgEntryCachedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrgEntryCached> $mapper =
      OrgEntryCachedMapper.ensureInitialized();
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
    Object? todoKeyword = $none,
    bool? containsTimestampInHeadline,
    String? title,
    List<String>? tags,
    List<OrgTimestamp>? timestamps,
    Object? deadline = $none,
    Object? scheduled = $none,
  }) => $apply(
    FieldCopyWithData({
      if (todoKeyword != $none) #todoKeyword: todoKeyword,
      if (containsTimestampInHeadline != null)
        #containsTimestampInHeadline: containsTimestampInHeadline,
      if (title != null) #title: title,
      if (tags != null) #tags: tags,
      if (timestamps != null) #timestamps: timestamps,
      if (deadline != $none) #deadline: deadline,
      if (scheduled != $none) #scheduled: scheduled,
    }),
  );
  @override
  OrgEntryCached $make(CopyWithData data) => OrgEntryCached(
    todoKeyword: data.get(#todoKeyword, or: $value.todoKeyword),
    containsTimestampInHeadline: data.get(
      #containsTimestampInHeadline,
      or: $value.containsTimestampInHeadline,
    ),
    title: data.get(#title, or: $value.title),
    tags: data.get(#tags, or: $value.tags),
    timestamps: data.get(#timestamps, or: $value.timestamps),
    deadline: data.get(#deadline, or: $value.deadline),
    scheduled: data.get(#scheduled, or: $value.scheduled),
  );

  @override
  OrgEntryCachedCopyWith<$R2, OrgEntryCached, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrgEntryCachedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OrgEntryLoadedMapper extends SubClassMapperBase<OrgEntryLoaded> {
  OrgEntryLoadedMapper._();

  static OrgEntryLoadedMapper? _instance;
  static OrgEntryLoadedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrgEntryLoadedMapper._());
      OrgEntryMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'OrgEntryLoaded';

  static String? _$todoKeyword(OrgEntryLoaded v) => v.todoKeyword;
  static const Field<OrgEntryLoaded, String> _f$todoKeyword = Field(
    'todoKeyword',
    _$todoKeyword,
  );
  static bool _$containsTimestampInHeadline(OrgEntryLoaded v) =>
      v.containsTimestampInHeadline;
  static const Field<OrgEntryLoaded, bool> _f$containsTimestampInHeadline =
      Field('containsTimestampInHeadline', _$containsTimestampInHeadline);
  static String _$title(OrgEntryLoaded v) => v.title;
  static const Field<OrgEntryLoaded, String> _f$title = Field('title', _$title);
  static List<String> _$tags(OrgEntryLoaded v) => v.tags;
  static const Field<OrgEntryLoaded, List<String>> _f$tags = Field(
    'tags',
    _$tags,
  );
  static List<OrgTimestamp> _$timestamps(OrgEntryLoaded v) => v.timestamps;
  static const Field<OrgEntryLoaded, List<OrgTimestamp>> _f$timestamps = Field(
    'timestamps',
    _$timestamps,
  );
  static OrgPlanningEntry? _$deadline(OrgEntryLoaded v) => v.deadline;
  static const Field<OrgEntryLoaded, OrgPlanningEntry> _f$deadline = Field(
    'deadline',
    _$deadline,
  );
  static OrgPlanningEntry? _$scheduled(OrgEntryLoaded v) => v.scheduled;
  static const Field<OrgEntryLoaded, OrgPlanningEntry> _f$scheduled = Field(
    'scheduled',
    _$scheduled,
  );
  static OrgSection _$section(OrgEntryLoaded v) => v.section;
  static const Field<OrgEntryLoaded, OrgSection> _f$section = Field(
    'section',
    _$section,
  );
  static FileInfo _$fileInfo(OrgEntryLoaded v) => v.fileInfo;
  static const Field<OrgEntryLoaded, FileInfo> _f$fileInfo = Field(
    'fileInfo',
    _$fileInfo,
  );

  @override
  final MappableFields<OrgEntryLoaded> fields = const {
    #todoKeyword: _f$todoKeyword,
    #containsTimestampInHeadline: _f$containsTimestampInHeadline,
    #title: _f$title,
    #tags: _f$tags,
    #timestamps: _f$timestamps,
    #deadline: _f$deadline,
    #scheduled: _f$scheduled,
    #section: _f$section,
    #fileInfo: _f$fileInfo,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'loaded';
  @override
  late final ClassMapperBase superMapper = OrgEntryMapper.ensureInitialized();

  static OrgEntryLoaded _instantiate(DecodingData data) {
    return OrgEntryLoaded(
      todoKeyword: data.dec(_f$todoKeyword),
      containsTimestampInHeadline: data.dec(_f$containsTimestampInHeadline),
      title: data.dec(_f$title),
      tags: data.dec(_f$tags),
      timestamps: data.dec(_f$timestamps),
      deadline: data.dec(_f$deadline),
      scheduled: data.dec(_f$scheduled),
      section: data.dec(_f$section),
      fileInfo: data.dec(_f$fileInfo),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrgEntryLoaded fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrgEntryLoaded>(map);
  }

  static OrgEntryLoaded fromJson(String json) {
    return ensureInitialized().decodeJson<OrgEntryLoaded>(json);
  }
}

mixin OrgEntryLoadedMappable {
  String toJson() {
    return OrgEntryLoadedMapper.ensureInitialized().encodeJson<OrgEntryLoaded>(
      this as OrgEntryLoaded,
    );
  }

  Map<String, dynamic> toMap() {
    return OrgEntryLoadedMapper.ensureInitialized().encodeMap<OrgEntryLoaded>(
      this as OrgEntryLoaded,
    );
  }

  OrgEntryLoadedCopyWith<OrgEntryLoaded, OrgEntryLoaded, OrgEntryLoaded>
  get copyWith => _OrgEntryLoadedCopyWithImpl<OrgEntryLoaded, OrgEntryLoaded>(
    this as OrgEntryLoaded,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return OrgEntryLoadedMapper.ensureInitialized().stringifyValue(
      this as OrgEntryLoaded,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrgEntryLoadedMapper.ensureInitialized().equalsValue(
      this as OrgEntryLoaded,
      other,
    );
  }

  @override
  int get hashCode {
    return OrgEntryLoadedMapper.ensureInitialized().hashValue(
      this as OrgEntryLoaded,
    );
  }
}

extension OrgEntryLoadedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrgEntryLoaded, $Out> {
  OrgEntryLoadedCopyWith<$R, OrgEntryLoaded, $Out> get $asOrgEntryLoaded =>
      $base.as((v, t, t2) => _OrgEntryLoadedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrgEntryLoadedCopyWith<$R, $In extends OrgEntryLoaded, $Out>
    implements OrgEntryCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get tags;
  @override
  ListCopyWith<$R, OrgTimestamp, ObjectCopyWith<$R, OrgTimestamp, OrgTimestamp>>
  get timestamps;
  @override
  $R call({
    String? todoKeyword,
    bool? containsTimestampInHeadline,
    String? title,
    List<String>? tags,
    List<OrgTimestamp>? timestamps,
    OrgPlanningEntry? deadline,
    OrgPlanningEntry? scheduled,
    OrgSection? section,
    FileInfo? fileInfo,
  });
  OrgEntryLoadedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrgEntryLoadedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrgEntryLoaded, $Out>
    implements OrgEntryLoadedCopyWith<$R, OrgEntryLoaded, $Out> {
  _OrgEntryLoadedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrgEntryLoaded> $mapper =
      OrgEntryLoadedMapper.ensureInitialized();
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
    Object? todoKeyword = $none,
    bool? containsTimestampInHeadline,
    String? title,
    List<String>? tags,
    List<OrgTimestamp>? timestamps,
    Object? deadline = $none,
    Object? scheduled = $none,
    OrgSection? section,
    FileInfo? fileInfo,
  }) => $apply(
    FieldCopyWithData({
      if (todoKeyword != $none) #todoKeyword: todoKeyword,
      if (containsTimestampInHeadline != null)
        #containsTimestampInHeadline: containsTimestampInHeadline,
      if (title != null) #title: title,
      if (tags != null) #tags: tags,
      if (timestamps != null) #timestamps: timestamps,
      if (deadline != $none) #deadline: deadline,
      if (scheduled != $none) #scheduled: scheduled,
      if (section != null) #section: section,
      if (fileInfo != null) #fileInfo: fileInfo,
    }),
  );
  @override
  OrgEntryLoaded $make(CopyWithData data) => OrgEntryLoaded(
    todoKeyword: data.get(#todoKeyword, or: $value.todoKeyword),
    containsTimestampInHeadline: data.get(
      #containsTimestampInHeadline,
      or: $value.containsTimestampInHeadline,
    ),
    title: data.get(#title, or: $value.title),
    tags: data.get(#tags, or: $value.tags),
    timestamps: data.get(#timestamps, or: $value.timestamps),
    deadline: data.get(#deadline, or: $value.deadline),
    scheduled: data.get(#scheduled, or: $value.scheduled),
    section: data.get(#section, or: $value.section),
    fileInfo: data.get(#fileInfo, or: $value.fileInfo),
  );

  @override
  OrgEntryLoadedCopyWith<$R2, OrgEntryLoaded, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrgEntryLoadedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

