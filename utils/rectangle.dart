
import 'dart:math';

class Rectangle {
  final int left;
  final int top;
  final int right;
  final int bottom;
  Rectangle(this.left, this.top, this.right, this.bottom);
  @override
  String toString() {
    return "($left, $top, $right, $bottom)";
  }
}

extension RectangleOperations on Rectangle {
  int size() {
    return (right - left + 1) * (bottom - top + 1);
  }

  Rectangle? overlap(Rectangle r2) {
    // print(this);
    // print(r2);
    if (right < r2.left) return null;
    if (left > r2.right) return null;
    if (top > r2.bottom) return null;
    if (bottom < r2.top) return null;
    
    final l = max(left, r2.left);
    final r = min(right, r2.right);
    final t = max(top, r2.top);
    final b = min(bottom, r2.bottom);

    return Rectangle(l, t, r, b);
  }

  List<Rectangle> exclude(Rectangle r2) {
    final overlapped = overlap(r2);
    // print(overlapped);
    if (overlapped == null) return [this];

    final List<Rectangle> result = [];
    var l = left;
    if (left < overlapped.left) {
      result.add(Rectangle(left, top, overlapped.left - 1, bottom));
      l = overlapped.left;
    }
    // print(result);
    var t = top;
    if (top < overlapped.top) {
      result.add(Rectangle(l, top, right, overlapped.top - 1));
      t = overlapped.top;
    }
    // print(result);

    var r = right;
    if (right > overlapped.right) {
      result.add(Rectangle(overlapped.right + 1, t, right, bottom));
      r = overlapped.right;
    }

    // print(result);

    if (bottom > overlapped.bottom) {
      result.add(Rectangle(l, overlapped.bottom +1, r, bottom));
    }
    // print(result);

    return result;
  }
}