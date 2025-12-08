import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global Navigator Key
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
      (ref) => GlobalKey<NavigatorState>(),
);

/// Navigation helpers
extension NavigationExtension on WidgetRef {
  Future<void> pushReplacement(String routeName) {
    return read(navigatorKeyProvider).currentState!
        .pushReplacementNamed(routeName);
  }

  Future<void> push(String routeName) {
    return read(navigatorKeyProvider).currentState!
        .pushNamed(routeName);
  }

  void pop() {
    return read(navigatorKeyProvider).currentState!.pop();
  }
}
