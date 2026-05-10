import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryManagement {
  final bool isGrid;
  LibraryManagement({required this.isGrid});

  LibraryManagement copyWith({bool? isGrid}) {
    return LibraryManagement(isGrid: isGrid ?? this.isGrid);
  }
}

class LibraryNotifier extends Notifier<LibraryManagement> {
  @override
  LibraryManagement build() {
    return LibraryManagement(isGrid: true);
  }
  void toggleGrid() {
    state = state.copyWith(isGrid: !state.isGrid);
  }
}

final libraryProvider = NotifierProvider<LibraryNotifier, LibraryManagement>(
  LibraryNotifier.new,
);
