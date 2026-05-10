import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:study/core/utils.dart';
import 'package:study/data/main/app_main.dart';
import 'package:study/data/models/qore_model.dart';
import 'package:study/features/display/views/display_view.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget qoreCard(BuildContext context, QoreModel qore, bool isGrid) {
  final theme = Theme.of(context);
  return FadeIn(
    duration: const Duration(milliseconds: 200),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayView(
              qore: QoreDbModel(
                id: qore.id,
                title: qore.title,
                description: qore.description,
                createdAt: qore.createdAt,
              ),
            ),
          ),
        );
      },
      child: Card(
        color: theme.colorScheme.surfaceContainer,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                qore.title.isEmpty ? "Untitled" : qore.title,

                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              isGrid
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMMd().format(qore.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                        if (!isGrid) ...[
                          const SizedBox(width: 5),
                          Text(
                            timeago.format(qore.createdAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMMd().format(qore.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          timeago.format(qore.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 5),

              const Divider(height: 1),

              if (qore.texts.isNotEmpty &&
                  qore.texts.first.text.isNotEmpty) ...[
                const SizedBox(height: 5),

                Text(
                  qore.texts.first.text,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: isGrid ? 4 : 8,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (qore.images.isNotEmpty) ...[
                const SizedBox(height: 5),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: isGrid ? 100 : 200),
                  child: GridView.custom(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverWovenGridDelegate.count(
                      crossAxisCount: 2,
                      pattern: [
                        WovenGridTile(1),
                        WovenGridTile(
                          5 / 7,
                          crossAxisRatio: 0.9,
                          alignment: AlignmentDirectional.centerEnd,
                        ),
                      ],
                    ),
                    childrenDelegate: SliverChildBuilderDelegate((
                      context,
                      index,
                    ) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(qore.images[index].filePath),
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                          height: isGrid ? 100 : 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }, childCount: qore.images.length.clamp(0, 2)),
                  ),
                ),
              ],

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (qore.texts.isNotEmpty &&
                      qore.texts.first.tags.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    BuildTags(tags: qore.texts.first.tags, limit: 2),
                  ],

                  const SizedBox(height: 5),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget contentLayout(
  BuildContext context,
  List<dynamic> items,
  IconData icon,
  String text,
  String subText,
) {
  return Consumer(
    builder: (context, ref, child) {
      final library = ref.watch(libraryProvider);
      return Expanded(
        child: MasonryGridView.builder(
          itemCount: items.length,
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: library.isGrid ? 2 : 1,
          ),
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          itemBuilder: (context, index) {
            final item = items[index];
            if (item is QoreModel) {
              return qoreCard(context, item, library.isGrid);
            } else {
              return EmptyLibraryView(icon: icon, text: text, subText: subText);
            }
          },
        ),
      );
    },
  );
}

class BuildContentLayout extends ConsumerWidget {
  final String text;
  final IconData icon;
  final String subText;
  const BuildContentLayout({
    super.key,
    required this.qores,
    this.text = "Nothing in your library",
    this.icon = FluentIcons.collections_empty_24_filled,
    this.subText = "Create something to get started",
  });

  final List<QoreModel> qores;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return qores.isNotEmpty
        ? Column(children: [contentLayout(context, qores, icon, text, subText)])
        : EmptyLibraryView(icon: icon, text: text, subText: subText);
  }
}

class EmptyLibraryView extends StatelessWidget {
  final String text;
  final IconData icon;
  final String subText;
  const EmptyLibraryView({
    super.key,
    this.text = "Nothing in your library",
    this.icon = FluentIcons.collections_empty_24_filled,
    this.subText = "Create something to get started",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text, style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Text(
                subText,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Icon(icon, size: 100, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }
}
