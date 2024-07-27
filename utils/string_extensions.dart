extension MyStringExtensions on String {
  List<String> lines() {
    return split("\n").map((l) => l.trim()).where((t) => t.isNotEmpty).toList();
  }

  List<List<String>> paragraphs() {
    final List<List<String>> result = [];
    var paragraph = <String>[];
    for (final line in split('\n').map((s) => s.trim())) {
      if (line.isEmpty) {
        if (paragraph.isNotEmpty) result.add(paragraph);
        paragraph = [];
      } else {
        paragraph.add(line);
      }
    }
    if (paragraph.isNotEmpty) result.add(paragraph);
    return result;
  }

  String chomp(String snack) {
    if (endsWith(snack)) return substring(0, length - snack.length);
    return this;
  }

  String substringOfLength(int start, int length) {
    return substring(start, start + length);
  }
}
