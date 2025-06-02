import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:calendorg/tag_color.dart';

void main() {
  group(
    TagColor,
    () {
      test(
        'toString returns string as expected',
        () {
          final TagColor tagColor = TagColor("@home", Colors.green);

          expect(tagColor.toString(),
              "TagColor(tag: @home, color: MaterialColor(primary value: Color(alpha: 1.0000, red: 0.2980, green: 0.6863, blue: 0.3137, colorSpace: ColorSpace.sRGB)))");
        },
      );
      test("Two equal TagColors should be equal", () {
        final TagColor a = TagColor("@home", Colors.green);
        final TagColor b = TagColor("@home", Colors.green);
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });
    },
  );
}
