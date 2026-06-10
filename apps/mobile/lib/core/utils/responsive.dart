import 'package:flutter/widgets.dart';

class Responsive {
  const Responsive._();

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 390;
  }
}
