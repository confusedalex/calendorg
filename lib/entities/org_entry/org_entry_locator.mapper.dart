// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'org_entry_locator.dart';

class OrgEntryLocatorMapper extends ClassMapperBase<OrgEntryLocator> {
  OrgEntryLocatorMapper._();

  static OrgEntryLocatorMapper? _instance;
  static OrgEntryLocatorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrgEntryLocatorMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OrgEntryLocator';

  static List<String> _$titlePath(OrgEntryLocator v) => v.titlePath;
  static const Field<OrgEntryLocator, List<String>> _f$titlePath = Field(
    'titlePath',
    _$titlePath,
  );
  static int _$occurrence(OrgEntryLocator v) => v.occurrence;
  static const Field<OrgEntryLocator, int> _f$occurrence = Field(
    'occurrence',
    _$occurrence,
  );

  @override
  final MappableFields<OrgEntryLocator> fields = const {
    #titlePath: _f$titlePath,
    #occurrence: _f$occurrence,
  };

  static OrgEntryLocator _instantiate(DecodingData data) {
    return OrgEntryLocator(
      titlePath: data.dec(_f$titlePath),
      occurrence: data.dec(_f$occurrence),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrgEntryLocator fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrgEntryLocator>(map);
  }

  static OrgEntryLocator fromJson(String json) {
    return ensureInitialized().decodeJson<OrgEntryLocator>(json);
  }
}

mixin OrgEntryLocatorMappable {
  String toJson() {
    return OrgEntryLocatorMapper.ensureInitialized()
        .encodeJson<OrgEntryLocator>(this as OrgEntryLocator);
  }

  Map<String, dynamic> toMap() {
    return OrgEntryLocatorMapper.ensureInitialized().encodeMap<OrgEntryLocator>(
      this as OrgEntryLocator,
    );
  }

  OrgEntryLocatorCopyWith<OrgEntryLocator, OrgEntryLocator, OrgEntryLocator>
  get copyWith =>
      _OrgEntryLocatorCopyWithImpl<OrgEntryLocator, OrgEntryLocator>(
        this as OrgEntryLocator,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrgEntryLocatorMapper.ensureInitialized().stringifyValue(
      this as OrgEntryLocator,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrgEntryLocatorMapper.ensureInitialized().equalsValue(
      this as OrgEntryLocator,
      other,
    );
  }

  @override
  int get hashCode {
    return OrgEntryLocatorMapper.ensureInitialized().hashValue(
      this as OrgEntryLocator,
    );
  }
}

extension OrgEntryLocatorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrgEntryLocator, $Out> {
  OrgEntryLocatorCopyWith<$R, OrgEntryLocator, $Out> get $asOrgEntryLocator =>
      $base.as((v, t, t2) => _OrgEntryLocatorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrgEntryLocatorCopyWith<$R, $In extends OrgEntryLocator, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get titlePath;
  $R call({List<String>? titlePath, int? occurrence});
  OrgEntryLocatorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrgEntryLocatorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrgEntryLocator, $Out>
    implements OrgEntryLocatorCopyWith<$R, OrgEntryLocator, $Out> {
  _OrgEntryLocatorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrgEntryLocator> $mapper =
      OrgEntryLocatorMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get titlePath =>
      ListCopyWith(
        $value.titlePath,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(titlePath: v),
      );
  @override
  $R call({List<String>? titlePath, int? occurrence}) => $apply(
    FieldCopyWithData({
      if (titlePath != null) #titlePath: titlePath,
      if (occurrence != null) #occurrence: occurrence,
    }),
  );
  @override
  OrgEntryLocator $make(CopyWithData data) => OrgEntryLocator(
    titlePath: data.get(#titlePath, or: $value.titlePath),
    occurrence: data.get(#occurrence, or: $value.occurrence),
  );

  @override
  OrgEntryLocatorCopyWith<$R2, OrgEntryLocator, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrgEntryLocatorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

