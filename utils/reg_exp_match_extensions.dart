extension MyRegExpMatchExtensions on RegExpMatch {
  String stringGroup(String label) => namedGroup(label)!;
  int intGroup(String label) => int.parse(stringGroup(label));
}
