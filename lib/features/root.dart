import 'package:flutter/material.dart';
import 'package:study/features/library/views/library.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LibraryPage());
  }
}
