import 'dart:convert';
import 'package:crypto/crypto.dart';

md5sum(String input) {
  return md5.convert(utf8.encode(input)).toString();
}