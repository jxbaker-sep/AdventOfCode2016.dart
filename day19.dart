import 'dart:collection';

import 'utils/input.dart';
import 'utils/lle.dart';
import 'utils/test.dart';

Future<void> main() async {
  var data = int.parse(await getInput('day19'));
  myTest(do1(5), 3);
  myTest(do1(data), 1834471);

  // test(do2(2), 1);
  // test(do2(3), 3);
  // test(do2(4), 1);
  // test(do2(5), 2);
  // test(do2(7), 5);
  // test(do2(8), 7);
  // test(do2(9), 9);
  // test(do2(10), 1);
  // test(do2(11), 2);
  // test(do2(25), 23);

  myTest(do2(50), 23);
  myTest(do2(100), 19);

  // for(final i in xrange(75)) {
  //   print('${i+2}: ${do2(i+2)}');
  // }


  myTest(do2(data), 1420064); // 611507 too low, 240148 too low

}

int do1(int size) {
  return do1Recursive(size, 1, 1);
}

int do1Recursive(int size, int start, int step) {
  if (size < 1) throw Exception();
  if (size == 1) return start;
  final next = size.isEven ? start : (start + step * 2);
  return do1Recursive(size ~/ 2, next, step * 2);
}

int do2(int size) {
  // return do2Recursive(Iterable.generate(size, (i) => i+1).toList(), 0);
  // return do2LL(Iterable.generate(size, (i) => i+1).toList());
  return do2Iterative(size);
}

int do2Iterative(final int target) {
  int score = 1;
  for(var current = 2; current <= target; current++) {
    final tempScore = (score + 1) * 2 > current ? score + 2 : score + 1;
    score = tempScore > current ? 1 : tempScore;
  }
  return score;
}

int do2BruteForce(List<int> data, int index) {
  if (data.length == 1) return data.first;
  if (index >= data.length) {
    return do2BruteForce(data, 0);
  }
  final b = (index + data.length ~/ 2) % data.length;
  return do2BruteForce(data.sublist(0, b) + data.sublist(b+1), index + (b > index ? 1 : 0));
}

int do2LL(List<int> inputData) {
  final ll = LinkedList<LLE<int>>();
  ll.addAll(inputData.map((item) => LLE(item)));
  var cursor = ll.first;
  LLE<int>? head;
  while (ll.isNotEmpty) {
    if (ll.length == 1) return ll.first.value;
    if (head == null) {
      head = ll.first;
      cursor = ll.elementAt(ll.length ~/ 2);
    }
    var temp = cursor.next ?? ll.first;    
    if (ll.length.isOdd) temp = temp.next ?? ll.first;
    if (cursor == head) throw Exception();
    cursor.unlink();
    head = head.next;
    cursor = temp;
  }
  throw Exception();
}