import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_project/features/main_widget.dart';

void main() {
  runApp(ProviderScope(child: const MainWidget()));
}
