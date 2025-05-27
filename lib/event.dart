class Event {
  DateTime start;
  late DateTime? end;
  String title;
  late String? description;
  String id;

  Event(this.start, this.title, this.id, this.description, this.end);

  String getTimeStamp() {
    return "<${start.toIso8601String().split('T').first}>";
  }

  String getOrgHeading(int level) {
    String prefix = '';
    for (int i = 0; i < level; i++) {
      prefix += '*';
    }
    return '$prefix $title';
  }

  String getOrgEvent(int level) {
    return '${getOrgHeading(level)} ${getTimeStamp()}';
  }
}
