import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

class OrgDocumentCubit extends Cubit<OrgDocument> {
  OrgDocumentCubit(super.initialState);

  void setDocument(OrgDocument document) => emit(document);

  void replaceNode(OrgNode oldNode, OrgNode newNode) {
    if (state.children.contains(oldNode)) return;

    final newDoc = state.edit().find(oldNode)!.replace(newNode).commit();
    emit(OrgDocument.parse(newDoc.toMarkup()));
  }
}
