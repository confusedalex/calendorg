import 'package:flutter/material.dart';

Widget eventListPage(String display) => Center(
  child: SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Text(display),
  ),
);
