import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:study/core/utils.dart';
import 'package:study/data/db/db_providers.dart';
import 'package:study/data/extensions.dart';
import 'package:study/data/models/qore_model.dart';
import 'package:study/features/display/views/add_note_view.dart';
import 'package:study/features/display/views/display_image_view.dart';

class DisplayView extends ConsumerStatefulWidget {
  final QoreDbModel qore;
  const DisplayView({super.key, required this.qore});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DisplayViewState();
}

class _DisplayViewState extends ConsumerState<DisplayView> {
  bool isEditingTitle = false;
  FocusNode focusNode = FocusNode();
  late TextEditingController _titleController;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.qore.title);
    super.initState();
  }

  void updateQore(QoreModel qore) {
    final repo = ref.watch(dbRepositoryProvider);
    repo.saveQore(
      qore: QoreDbModel(
        id: qore.id,
        title: _titleController.text,
        description: qore.description,
        createdAt: qore.createdAt,
      ),
      texts: qore.texts,
      audios: qore.audios,
      images: qore.images,
    );

    refreshAll(ref);
  }

  @override
  Widget build(BuildContext context) {
    final qoreAsync = ref.watch(qoreByIdProvider(widget.qore.id));
    final repo = ref.watch(dbRepositoryProvider);
    return Scaffold(
      body: qoreAsync.when(
        data: (qore) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                scrolledUnderElevation: 0,
                floating: true,
                snap: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Theme.of(context).colorScheme.surface,
                actions: [
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        showDragHandle: true,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showAppDialog(
                                      context,
                                      "Delete",
                                      "Are you sure you want to delete ?",
                                      onYes: () async {
                                        repo.deleteQore(widget.qore.id);

                                        refreshAll(ref);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        }
                                      },
                                    );
                                  },
                                  child: Card(
                                    elevation: 0,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHigh,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                Text(
                                                  "This action cannot be undone",
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(FluentIcons.delete_16_filled),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 50),
                              ],
                            ),
                          );
                        },
                      );
                    },

                    icon: Icon(
                      FluentIcons.more_horizontal_24_regular,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            DateFormat.yMMMMd().format(widget.qore.createdAt),
                          ),
                          const SizedBox(height: 8),

                          isEditingTitle
                              ? Column(
                                  children: [
                                    IntrinsicWidth(
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainer,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),

                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          controller: _titleController,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                            isCollapsed: true,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            hintText: "Untitled",
                                          ),
                                          focusNode: focusNode,
                                          onChanged: (value) {
                                            updateQore(qore);
                                          },

                                          onSubmitted: (value) {
                                            updateQore(qore);
                                            setState(() {
                                              isEditingTitle = false;
                                              focusNode.unfocus();
                                            });
                                          },
                                          onTapOutside: (e) {
                                            updateQore(qore);

                                            setState(() {
                                              isEditingTitle = false;
                                              focusNode.unfocus();
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: () {
                                    // edit title
                                    setState(() {
                                      isEditingTitle = true;
                                      focusNode.requestFocus();
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      qore.title.isNotEmpty
                                          ? qore.title
                                          : "Untitled",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                          if (qore.images.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Images",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainer,
                                  ),
                                  iconAlignment: IconAlignment.end,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DisplayImageView(qoreId: qore.id),
                                      ),
                                    );
                                  },
                                  label: Text(
                                    "See All (${qore.images.length})",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                  icon: const Icon(
                                    FluentIcons.chevron_right_20_regular,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,

                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: qore.images.length,
                                itemBuilder: (context, index) {
                                  final image = qore.images[index];
                                  return Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ImageViewer(image: image),
                                            ),
                                          );
                                        },
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 300,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              File(image.filePath),
                                              fit: BoxFit.fitHeight,
                                              height: 200,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],

                          if (qore.texts.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Column(
                              children: List.generate(qore.texts.length, (
                                index,
                              ) {
                                final text = qore.texts[index];
                                int colorIndex = index % (qore.texts.length);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => AddNoteView(
                                            qore: qore,
                                            isQoreNew: false,
                                            text: text,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),

                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? bgForWhiteText(
                                                context,
                                                showFirstColor: false,
                                              )[colorIndex]
                                            : bgForBlackText(
                                                context,
                                                showFirstColor: false,
                                              )[colorIndex],
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat.jm().format(
                                              text.createdAt,
                                            ),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            text.text,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Material(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  onTap: () {
                                                    Clipboard.setData(
                                                      ClipboardData(
                                                        text: text.text,
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          4.0,
                                                        ),
                                                    child: Icon(
                                                      FluentIcons
                                                          .copy_20_regular,
                                                      size: 25,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Material(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  onTap: () {
                                                    SharePlus.instance.share(
                                                      ShareParams(
                                                        text: text.text,
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          4.0,
                                                        ),
                                                    child: Icon(
                                                      FluentIcons
                                                          .share_20_regular,
                                                      size: 25,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Material(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  onTap: () async {
                                                    await repo.deleteText(
                                                      text: text,
                                                    );
                                                    refreshAll(ref);
                                                    if (context.mounted) {
                                                      appSnackBar(
                                                        context,
                                                        'Note deleted',
                                                      );
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          4.0,
                                                        ),
                                                    child: Icon(
                                                      FluentIcons
                                                          .delete_20_regular,
                                                      size: 25,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Actions",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              // TextButton.icon(
                              //   icon: Icon(
                              //     FluentIcons.settings_20_regular,
                              //     size: 20,
                              //   ),
                              //   style: TextButton.styleFrom(
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(20),
                              //     ),
                              //     foregroundColor: Theme.of(
                              //       context,
                              //     ).colorScheme.onSurface,
                              //     backgroundColor: Theme.of(
                              //       context,
                              //     ).colorScheme.surfaceContainer,
                              //   ),
                              //   onPressed: () {},
                              //   label: Text(
                              //     "Config",
                              //     style: TextStyle(fontSize: 13),
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          MasonryGridView(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            children: [
                              _buildBoxButton(
                                context,
                                "📝",
                                "Notes",
                                "Add notes",
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddNoteView(qore: qore),
                                    ),
                                  );
                                },
                              ),

                              // _buildBoxButton(
                              //   context,
                              //   "📋",
                              //   "Tasks",
                              //   "Create tasks",
                              //   () {},
                              // ),
                              _buildBoxButton(
                                context,
                                "📷",
                                "Images",
                                "Add images",
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DisplayImageView(qoreId: qore.id),
                                    ),
                                  );
                                },
                              ),

                              // _buildBoxButton(
                              //   context,
                              //   "🗂️",
                              //   "Flashcards",
                              //   "Create flashcards",
                              //   () {},
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(child: const SizedBox(height: 100)),
            ],
          );
        },
        error: (error, stack) {
          return Center(child: Text(error.toString()));
        },
        loading: () {
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

Widget _buildBoxButton(
  BuildContext context,
  String icon,
  String text,
  String subtext,
  VoidCallback onTap,
) {
  final theme = Theme.of(context);
  return InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 5),
          Text(text, style: Theme.of(context).textTheme.titleMedium),
          //  const SizedBox(height: 5),
          //Text(subtext, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}
