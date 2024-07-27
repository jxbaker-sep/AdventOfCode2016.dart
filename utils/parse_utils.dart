import 'package:petitparser/petitparser.dart';

extension ParserExtensions<T> on Parser<T> {
  Parser<T> before(String b) => skip(before: string(b).trim());

  Parser<T> after(String a) => skip(after: string(a).trim());

  Parser<T> between(String before, String after) => skip(before: string(before).trim(), after: string(after).trim());

}

final letters = letter().plus().flatten();

final lexical = letter().plus().flatten().trim();

final number = (string("-").optional() & digit().plus()).flatten().trim().map(int.parse);

ChoiceParser<T> choice2<T>(Parser<T> c1, Parser<T> c2) => [c1,c2].toChoiceParser();
ChoiceParser<T> choice3<T>(Parser<T> c1, Parser<T> c2, Parser<T> c3) => [c1,c2,c3].toChoiceParser();
ChoiceParser<T> choice4<T>(Parser<T> c1, Parser<T> c2, Parser<T> c3, Parser<T> c4) => [c1,c2,c3, c4].toChoiceParser();
ChoiceParser<T> choice5<T>(Parser<T> c1, Parser<T> c2, Parser<T> c3, Parser<T> c4) => [c1,c2,c3, c4].toChoiceParser();

ChoiceParser<String> oneOf(List<String> choices) => ChoiceParser(choices.map((s) => string(s).trim()));