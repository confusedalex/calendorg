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
}
