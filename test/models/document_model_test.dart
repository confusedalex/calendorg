import 'package:calendorg/models/document_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  group(
    'DocumentModel',
    () {
      final markup = """
* Heading 1
** orgmode meetup
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
<2025-05-01>--<2025-05-03>
** School :school:
<2025-05-27>
""";
      late OrgDocument document;
      setUp(() {
        document = OrgDocument.parse(markup);
      });

      test("Cubit will accept and store OrgDocument", () {
        var cubit = OrgDocumentCubit(document);

        expect(cubit.state, equals(document));
      });

      test("Cubit will update document", () {
        var cubit = OrgDocumentCubit(document);
        final newOrgDocument = OrgDocument.parse("* Heading");

        cubit.setDocument(newOrgDocument);

        expect(cubit.state, equals(newOrgDocument));
        expect(cubit.state, isNot(equals(document)));
      });
    },
  );
}
