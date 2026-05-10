import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:study/data/extensions.dart';
import 'package:study/features/create/data/create_draft.dart';

class ImageCollectionWidget extends ConsumerWidget {
  const ImageCollectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftNotifier = ref.watch(createDraftProvider.notifier);
    final images = ref.watch(createDraftProvider).images;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
        ),
        actions: [],
      ),

      body: MasonryGridView.builder(
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final item = images[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageView(image: item),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(File(item), fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: CircleBorder(),
        onPressed: () async {
          final newImage = await getMultipleImage();
          for (int i = 0; i < newImage.length; i++) {
            draftNotifier.addImage(newImage[i]);
          }
        },
        child: Icon(
          Icons.add,
          size: 25,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class ImageView extends ConsumerWidget {
  final String image;
  const ImageView({super.key, required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close),
        ),

        actions: [
          IconButton(
            onPressed: () {
              final draftNotifier = ref.watch(createDraftProvider.notifier);
              draftNotifier.removeImage(image);
              Navigator.pop(context);
            },
            icon: Icon(FluentIcons.delete_24_regular),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(8),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.file(File(image), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
