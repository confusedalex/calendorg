import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class TagColor {
  String tag;
  Color color;

  TagColor(this.tag, this.color);

  TagColor.fromJson(Map<String, dynamic> json)
      : tag = json['tag'] as String,
        color = Color(json['color'] as int);

  Map<String, dynamic> toJson() {
    return {"tag": tag, "color": color.value32bit};
  }

  @override
  int get hashCode => Object.hash(tag, color.value32bit);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TagColor) return false;
    return tag == other.tag && color.value32bit == other.color.value32bit;
  }
}
