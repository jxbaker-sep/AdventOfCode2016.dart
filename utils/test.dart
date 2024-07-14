void test<T extends T2, T2>(T actual, T2 expected) {
  if (actual != expected) throw Exception("Expected $expected, received $actual");
}