class Event {
  DateTime start;
  late DateTime? end;
  String title;
  late String? description;
  String id;
  bool isActive;
  String rawTimestamp;

  Event(this.rawTimestamp, this.isActive, this.start, this.title, this.id,
      this.description, this.end);

  String getOrgHeading(int level) {
    String prefix = '';
    for (int i = 0; i < level; i++) {
      prefix += '*';
    }
    return '$prefix $title';
  }
}
