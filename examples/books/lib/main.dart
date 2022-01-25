import 'package:books/books.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  configureEngineAndApp();
  runApp(ProviderScope(child: const BooksExampleApp()));
}
