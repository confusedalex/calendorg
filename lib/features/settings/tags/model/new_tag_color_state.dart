import 'package:flutter/material.dart';

final class NewTagColorState {
  final Color color;
  final String text;

  NewTagColorState({required this.color, required this.text});

  NewTagColorState copyWith({Color? color, String? text}) {
    return NewTagColorState(
      color: color ?? this.color,
      text: text ?? this.text,
    );
  }
}
