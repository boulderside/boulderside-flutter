import 'package:flutter/widgets.dart';

// 요소 간의 간격을 설정해주는 함수
extension DivideExtension on List<Widget> {
  List<Widget> divide(Widget separator) {
    if (length <= 1) return this;

    final divided = <Widget>[];
    for (int i = 0; i < length; i++) {
      divided.add(this[i]);
      if (i != length - 1) divided.add(separator);
    }
    return divided;
  }
}
