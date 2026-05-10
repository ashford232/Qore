import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createDraftProvider = NotifierProvider<CreateDraft, CreateDraftSate>(
  CreateDraft.new,
);

class CreateDraft extends Notifier<CreateDraftSate> {
  @override
  CreateDraftSate build() {
    return CreateDraftSate(
      content: "",
      images: [],
      currentBgIndex: 0,
      contentController: TextEditingController(),
      undoController: UndoHistoryController(),
      contentNode: FocusNode(),
    );
  }

  void changeBgIndex(int index) {
    state = state.copyWith(currentBgIndex: index);
  }

  void addImage(String image) {
    state = state.copyWith(images: [...state.images, image]);
  }

  void removeImage(String image) {
    state = state.copyWith(
      images: state.images.where((e) => e != image).toList(),
    );
  }

  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  void updateUndoController(UndoHistoryController undoController) {
    state = state.copyWith(undoController: undoController);
  }

  void updateContentNode(FocusNode contentNode) {
    state = state.copyWith(contentNode: contentNode);
  }

  void clear() {
    state = CreateDraftSate(
      content: "",
      images: [],
      currentBgIndex: 0,
      contentController: TextEditingController(),
      undoController: UndoHistoryController(),
      contentNode: FocusNode(),
    );
  }
}

class CreateDraftSate {
  final String content;
  final List<String> images;
  final int currentBgIndex;
  final TextEditingController contentController;
  final UndoHistoryController undoController;
  final FocusNode contentNode;

  CreateDraftSate({
    required this.content,
    required this.images,
    required this.currentBgIndex,
    required this.contentController,
    required this.undoController,
    required this.contentNode,
  });

  CreateDraftSate copyWith({
    String? content,
    List<String>? images,
    int? currentBgIndex,
    TextEditingController? contentController,
    UndoHistoryController? undoController,
    FocusNode? contentNode,
  }) {
    return CreateDraftSate(
      content: content ?? this.content,
      images: images ?? this.images,
      currentBgIndex: currentBgIndex ?? this.currentBgIndex,
      contentController: contentController ?? this.contentController,
      undoController: undoController ?? this.undoController,
      contentNode: contentNode ?? this.contentNode,
    );
  }
}
