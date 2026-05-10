import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study/data/db/db_providers.dart';
import 'package:study/data/main/app_main.dart';
import 'package:study/features/create/view/create_view.dart';
import 'package:study/features/profile/views/profile.dart';
import 'package:study/features/library/views/search.dart';
import 'package:study/features/library/widgets/library_widgets.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    final qores = ref.watch(qoreListProvider);
    final library = ref.watch(libraryProvider);
    final userAsync = ref.watch(userProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Library", style: TextStyle(fontSize: 28)),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(libraryProvider.notifier).toggleGrid();
            },
            icon: Icon(
              library.isGrid
                  ? FluentIcons.list_24_filled
                  : FluentIcons.table_24_regular,
              size: 25,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Search()),
              );
            },
            icon: Icon(FluentIcons.search_sparkle_24_filled, size: 25),
          ),
          userAsync.when(
            data: (user) {
              if (user == null || user.avater.isEmpty) {
                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileView()),
                    );
                  },
                  icon: Icon(
                    FluentIcons.person_circle_24_filled,
                    color: theme.colorScheme.primary,
                    size: 25,
                  ),
                );
              }
              return Row(
                children: [
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileView()),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.file(
                        File(user.avater),
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              );
            },
            error: (error, st) => IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileView()),
                );
              },
              icon: Icon(
                FluentIcons.person_circle_24_filled,
                color: theme.colorScheme.primary,
                size: 25,
              ),
            ),
            loading: () => IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileView()),
                );
              },
              icon: Icon(
                FluentIcons.person_circle_24_filled,
                color: theme.colorScheme.primary,
                size: 25,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateView()),
          );
        },
        child: Icon(
          FluentIcons.add_24_regular,
          size: 24,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 8),

              Expanded(
                child: qores.when(
                  data: (qores) {
                    if (qores.isEmpty) {
                      return FadeIn(child: Center(child: EmptyLibraryView()));
                    }
                    return FadeIn(child: BuildContentLayout(qores: qores));
                  },
                  loading: () => SizedBox.shrink(),

                  error: (error, stack) =>
                      Center(child: Text(error.toString())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
