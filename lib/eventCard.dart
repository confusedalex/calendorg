import 'package:calendorg/event.dart';
import 'package:flutter/material.dart';

Widget eventCard(Event event) => Card(
        child: ListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(event.title),
      subtitle: Text(event.rawTimestamp),
    ));
