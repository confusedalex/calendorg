
import 'package:org_parser/org_parser.dart';

class Documentsingelton {
  static final Documentsingelton _instance = Documentsingelton._internal();

  factory Documentsingelton() {
    return _instance;
  }

  Documentsingelton._internal();

  OrgDocument? document;

  void setDocument(OrgDocument document) {
    this.document = document;
  }

  OrgDocument? getDocument() {
    return document;
  }
}


