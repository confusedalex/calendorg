import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

class OrgDocumentCubit extends Cubit<OrgDocument> {
  OrgDocumentCubit(super.initialState);

  void setDocument(OrgDocument document) => emit(document);
}
