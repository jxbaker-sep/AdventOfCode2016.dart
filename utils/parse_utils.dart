import 'package:petitparser/petitparser.dart';

final word = letter().plus().flatten().trim();

final number = (string("-").optional() & digit().plus()).flatten().trim().map(int.parse);