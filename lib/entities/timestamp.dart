import 'package:dart_mappable/dart_mappable.dart';
import 'package:org_parser/org_parser.dart';

class OrgTimestampMapper extends SimpleMapper<OrgTimestamp> {
  const OrgTimestampMapper();

  @override
  OrgTimestamp decode(Object value) {
    final json = (value as Map).cast<String, dynamic>();
    if (json.containsKey('start')) return dateRangeFromJson(json);
    if (json.containsKey('timeStart')) return timeRangeFromJson(json);
    return fromJson(json);
  }

  @override
  Object? encode(OrgTimestamp self) => self.toJson();
}

extension JsonTimestamp on OrgTimestamp {
  Map<String, dynamic> toJson() => switch (this) {
    final OrgSimpleTimestamp timestamp => timestamp.toJson(),
    final OrgDateRangeTimestamp timestamp => timestamp.toJson(),
    final OrgTimeRangeTimestamp timestamp => timestamp.toJson(),
  };
}

extension JsonSimple on OrgSimpleTimestamp {
  Map<String, dynamic> toJson() => {
    'prefix': prefix,
    'date': _dateToJson(date),
    'time': time == null ? null : _timeToJson(time!),
    'modifiers': modifiers.map(_modifierToJson).toList(),
    'suffix': suffix,
  };
}

OrgSimpleTimestamp fromJson(Map<String, dynamic> json) {
  return OrgSimpleTimestamp(
    json['prefix'] as String,
    _dateFromJson(json['date'] as Map),
    json['time'] == null ? null : _timeFromJson(json['time'] as Map),
    (json['modifiers'] as List)
        .map((modifier) => _modifierFromJson(modifier as Map))
        .toList(),
    json['suffix'] as String,
  );
}

extension JsonDateRange on OrgDateRangeTimestamp {
  Map<String, dynamic> toJson() => {
    'start': start.toJson(),
    'delimiter': delimiter,
    'end': end.toJson(),
  };
}

OrgDateRangeTimestamp dateRangeFromJson(Map<String, dynamic> json) {
  return OrgDateRangeTimestamp(
    fromJson(json['start'] as Map<String, dynamic>),
    json['delimiter'] as String,
    fromJson(json['end'] as Map<String, dynamic>),
  );
}

extension JsonTimeRange on OrgTimeRangeTimestamp {
  Map<String, dynamic> toJson() => {
    'prefix': prefix,
    'date': _dateToJson(date),
    'timeStart': _timeToJson(timeStart),
    'timeEnd': _timeToJson(timeEnd),
    'modifiers': modifiers.map(_modifierToJson).toList(),
    'suffix': suffix,
  };
}

OrgTimeRangeTimestamp timeRangeFromJson(Map<String, dynamic> json) {
  return OrgTimeRangeTimestamp(
    json['prefix'] as String,
    _dateFromJson(json['date'] as Map),
    _timeFromJson(json['timeStart'] as Map),
    _timeFromJson(json['timeEnd'] as Map),
    (json['modifiers'] as List)
        .map((modifier) => _modifierFromJson(modifier as Map))
        .toList(),
    json['suffix'] as String,
  );
}

Map<String, String?> _dateToJson(OrgDate date) => {
  'year': date.year,
  'month': date.month,
  'day': date.day,
  'dayName': date.dayName,
};

OrgDate _dateFromJson(Map date) => (
  year: date['year'] as String,
  month: date['month'] as String,
  day: date['day'] as String,
  dayName: date['dayName'] as String?,
);

Map<String, String> _timeToJson(OrgTime time) => {
  'hour': time.hour,
  'minute': time.minute,
};

OrgTime _timeFromJson(Map time) =>
    (hour: time['hour'] as String, minute: time['minute'] as String);

Map<String, dynamic> _modifierToJson(OrgTimestampModifier modifier) => {
  'prefix': modifier.prefix,
  'value': modifier.value,
  'unit': modifier.unit,
  'suffix': modifier.suffix,
};

OrgTimestampModifier _modifierFromJson(Map modifier) => OrgTimestampModifier(
  modifier['prefix'] as String,
  modifier['value'] as String,
  modifier['unit'] as String,
  modifier['suffix'],
);
