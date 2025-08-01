import 'package:flutter/material.dart';

/// Generic push that returns the value passed to pop()
Future<T?> push<T>(BuildContext context, Widget view) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute(builder: (_) => view),
  );
}

/// Generic pushReplacement that returns the value passed to pop()
Future<T?> pushReplacement<T>(BuildContext context, Widget view) {
  return Navigator.of(context).pushReplacement<T, T>(
    MaterialPageRoute(builder: (_) => view),
  );
}

/// Generic pushAndRemoveUntil that returns the value passed to pop()
Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget view) {
  return Navigator.of(context).pushAndRemoveUntil<T>(
    MaterialPageRoute(builder: (_) => view),
    (route) => false,
  );
}
