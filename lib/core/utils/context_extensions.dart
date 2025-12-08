import 'package:flutter/widgets.dart';

extension ScreenSize on BuildContext {
  double get sw => MediaQuery.of(this).size.width;
  double get sh => MediaQuery.of(this).size.height;
}

///////*****Call it like this******/////
// width: context.sw * 0.8,
// height: context.sh * 0.3,