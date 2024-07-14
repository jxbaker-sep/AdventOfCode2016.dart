import 'dart:io';

Future<String> getInput(String section) async {
  final home = Platform.environment['HOME'];
  return File('$home/dev/AdventOfCode2016.Input/$section.input').readAsString();
}

Future<String> getAnswer(String section) async {
  final home = Platform.environment['HOME'];
  return File('$home/dev/AdventOfCode2016.Input/$section.answer').readAsString();
}