import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study/core/utils.dart';
import 'package:study/data/db/db_providers.dart';
import 'package:study/data/extensions.dart';
import 'package:study/data/models/qore_model.dart';
import 'package:study/features/create/data/create_draft.dart';
import 'package:study/features/create/widgets/create_widgets.dart';
import 'package:study/features/display/views/display_view.dart';
import 'package:uuid/uuid.dart';

class CreateView extends ConsumerStatefulWidget {
  const CreateView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateViewState();
}

TextEditingController contentController = TextEditingController();
FocusNode contentNode = FocusNode();
UndoHistoryController undoController = UndoHistoryController();
int currentBgIndex = 0;

class _CreateViewState extends ConsumerState<CreateView> {
  @override
  void initState() {
    super.initState();
    init();
    contentNode.requestFocus();
  }

  List<String> images = [];

  void init() {
    final draft = ref.read(createDraftProvider);
    setState(() {
      contentController.text = draft.content;
      undoController = draft.undoController;
      contentNode = draft.contentNode;
      currentBgIndex = draft.currentBgIndex;
      images = draft.images;
    });
  }

  void setAll() {
    final draftNotifier = ref.watch(createDraftProvider.notifier);
    draftNotifier.updateContent(contentController.text);
    draftNotifier.changeBgIndex(currentBgIndex);
    draftNotifier.updateUndoController(undoController);
    draftNotifier.updateContentNode(contentNode);
  }
  //

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final draft = ref.watch(createDraftProvider);
    final draftNotifier = ref.watch(createDraftProvider.notifier);
    final uuid = Uuid();

    final repo = ref.watch(dbRepositoryProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (contentController.text.trim().isEmpty) {
            draftNotifier.clear();
            Navigator.pop(context);
            return;
          }
          setAll();
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
                draftNotifier.clear();
                Navigator.pop(context);
                return;
              }
              setAll();
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
                if (contentController.text.trim().isNotEmpty ||
                    draft.images.isNotEmpty) {
                  contentNode.unfocus();
                  setAll();

                  final qoreUuid = uuid.v4();

                  final texts = [
                    TextModel(
                      qoreId: qoreUuid,
                      text: contentController.text,
                      createdAt: DateTime.now(),
                      id: qoreUuid,
                      tags: [],
                    ),
                  ];

                  final newImages = draft.images
                      .map(
                        (path) => ImageModel(
                          qoreId: qoreUuid,
                          filePath: path,
                          id: uuid.v4(),
                          tags: [],
                          text: '',
                          createdAt: DateTime.now(),
                        ),
                      )
                      .toList();

                  final newQore = QoreDbModel(
                    id: qoreUuid,
                    title: "",
                    description: '',
                    createdAt: DateTime.now(),
                  );

                  try {
                    setState(() {
                      isLoading = true;
                    });
                    await repo.saveQore(
                      qore: newQore,
                      texts: texts,
                      images: [],
                      audios: [],
                    );

                    for (var image in newImages) {
                      await repo.saveImage(image: image);
                    }

                    if (context.mounted) {
                      appSnackBar(context, 'Qore created successfully');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayView(qore: newQore),
                        ),
                      );
                    }
                    draftNotifier.clear();

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
                  draftNotifier.clear();
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
                    onPressed: () async {
                      if (draft.images.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageCollectionWidget(),
                          ),
                        );
                        return;
                      }

                      List<String> newImages = await getMultipleImage();

                      setState(() {
                        images.addAll(newImages);
                      });
                    },
                    icon: Badge(
                      label: Text(draft.images.length.toString()),
                      isLabelVisible: draft.images.isNotEmpty,
                      child: Icon(FluentIcons.image_24_regular, size: 25),
                    ),
                  ),
                  const SizedBox(width: 10),

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
