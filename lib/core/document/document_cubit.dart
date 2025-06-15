import 'package:calendorg/event.dart';
import 'package:calendorg/util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

class OrgDocumentCubit extends Cubit<OrgDocument> {
  OrgDocumentCubit(super.initialState);

  List<Event> get eventList => parseEvents(state);

  void setDocument(OrgDocument document) => emit(document);

  void replaceNode(OrgNode oldNode, OrgNode newNode) {
    if (state.children.contains(oldNode)) return;

    final newDoc = state.edit().find(oldNode)!.replace(newNode).commit();
    emit(OrgDocument.parse(newDoc.toMarkup()));
  }

  List<Event> eventsByDate(DateTime date) =>
      eventList.fold([], (acc, cur) {
        final timestampsByDate = cur.timestampsByDateTime(date);
        return timestampsByDate.isEmpty ? acc : [...acc, cur];
      });

  Map<Event, List<OrgTimestamp>> eventsByDateWithTimestamps(DateTime date) =>
      eventList.fold({}, (acc, cur) {
        final timestampsByDate = cur.timestampsByDateTime(date);

        return timestampsByDate.isEmpty ? acc : {...acc, cur: timestampsByDate};
      });
}
