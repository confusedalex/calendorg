import 'package:org_parser/org_parser.dart';

class EntryEdit {
  final String? newTitle;
  final OrgTimestamp? oldTimestamp;
  final OrgTimestamp? newTimestamp;

  const EntryEdit({this.newTitle, this.oldTimestamp, this.newTimestamp});

  bool get isEmpty => newTitle == null && newTimestamp == null;
}
