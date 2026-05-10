import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study/core/utils.dart';
import 'package:study/data/db/db_providers.dart';
import 'package:study/data/extensions.dart';
import 'package:study/data/models/qore_model.dart';
import 'package:uuid/uuid.dart';

class AddNoteView extends ConsumerStatefulWidget {
  const AddNoteView({
    super.key,
    required this.qore,
    this.isQoreNew = true,
    this.text,
  });
  final QoreModel qore;
  final bool isQoreNew;
  final TextModel? text;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends ConsumerState<AddNoteView> {
  TextEditingController contentController = TextEditingController();
  FocusNode contentNode = FocusNode();
  UndoHistoryController undoController = UndoHistoryController();
  int currentBgIndex = 0;
  @override
  void initState() {
    super.initState();
    contentNode.requestFocus();
    if (!widget.isQoreNew) {
      contentController.text = widget.text?.text ?? "";
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    contentNode.dispose();
    undoController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uuid = Uuid();
    final repo = ref.watch(dbRepositoryProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (contentController.text.trim().isEmpty) {
            Navigator.pop(context);
            return;
          }
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: theme.brightness == Brightness.light
            ? bgForBlackText(context)[currentBgIndex]
            : bgForWhiteText(context)[currentBgIndex],
        appBar: AppBar(
          backgroundColor: theme.brightness == Brightness.light
              ? bgForBlackText(context)[currentBgIndex]
              : bgForWhiteText(context)[currentBgIndex],
          leading: IconButton(
            icon: Icon(FluentIcons.chevron_left_24_filled),
            onPressed: () {
              if (contentController.text.trim().isEmpty) {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: () async {
                if (contentController.text.trim().isNotEmpty) {
                  contentNode.unfocus();

                  final TextModel text = TextModel(
                    id: widget.text?.id ?? uuid.v4(),
                    text: contentController.text,
                    createdAt: widget.text?.createdAt ?? DateTime.now(),
                    tags: [],
                    qoreId: widget.qore.id,
                  );

                  try {
                    setState(() {
                      isLoading = true;
                    });
                    await repo.saveText(text: text);
                    if (context.mounted) {
                      appSnackBar(
                        context,
                        widget.isQoreNew ? 'Note added' : 'Note updated',
                      );
                      Navigator.pop(context);
                    }

                    refreshAll(ref);
                  } catch (e) {
                    debugPrint(e.toString());
                    if (context.mounted) {
                      appSnackBar(context, 'Failed to create Qore');
                    }
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              child: isLoading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text("Done"),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: TextField(
                  undoController: undoController,
                  focusNode: contentNode,
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (currentBgIndex < bgForWhiteText(context).length - 1) {
                        currentBgIndex++;
                      } else {
                        currentBgIndex = 0;
                      }
                      setState(() {});
                    },
                    icon: Icon(FluentIcons.color_24_regular, size: 25),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      if (contentNode.hasFocus) {
                        contentNode.unfocus();
                      } else {
                        contentNode.requestFocus();
                      }

                      setState(() {});
                    },
                    icon: Icon(
                      !contentNode.hasFocus
                          ? FluentIcons.keyboard_24_regular
                          : FluentIcons.keyboard_dock_24_regular,
                      size: 25,
                    ),
                  ),

                  IconButton(
                    onPressed: undoController.value.canUndo
                        ? () {
                            undoController.undo();
                          }
                        : null,
                    icon: Icon(FluentIcons.arrow_undo_24_regular, size: 25),
                  ),
                  const SizedBox(width: 10),

                  IconButton(
                    onPressed: undoController.value.canRedo
                        ? () {
                            undoController.redo();
                          }
                        : null,
                    icon: Icon(FluentIcons.arrow_redo_24_regular, size: 25),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
