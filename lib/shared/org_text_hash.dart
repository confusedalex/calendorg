import 'dart:convert';
import 'package:crypto/crypto.dart';

String orgTextHash(String content) =>
    sha1.convert(utf8.encode(content)).toString();
