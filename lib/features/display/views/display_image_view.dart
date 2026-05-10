import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:study/data/db/db_providers.dart';
import 'package:study/data/extensions.dart';
import 'package:study/data/models/qore_model.dart';
import 'package:study/features/library/widgets/library_widgets.dart';
import 'package:uuid/uuid.dart';

class DisplayImageView extends ConsumerStatefulWidget {
  final String qoreId;
  const DisplayImageView({super.key, required this.qoreId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DisplayImageViewState();
}

class _DisplayImageViewState extends ConsumerState<DisplayImageView> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(dbRepositoryProvider);
    final uuid = const Uuid();
    final imagesAsync = ref.watch(qoreImagesProvider(widget.qoreId));

    return imagesAsync.when(
      data: (myImage) {
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

          body: myImage.isEmpty
              ? Center(
                  child: EmptyLibraryView(
                    text: "No images yet",
                    subText: "Tap on the button below to add images",
                    icon: FluentIcons.image_24_filled,
                  ),
                )
              : MasonryGridView.builder(
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                  itemCount: myImage.length,
                  itemBuilder: (context, index) {
                    final item = myImage[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewer(image: item),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(item.filePath),
                            fit: BoxFit.cover,
                          ),
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
                String uid = uuid.v4();
                final image = ImageModel(
                  id: uid,
                  filePath: newImage[i],
                  createdAt: DateTime.now(),
                  qoreId: widget.qoreId,
                  text: '',
                  tags: [],
                );
                await repo.saveImage(image: image);
                refreshAll(ref);
              }
            },
            child: Icon(
              Icons.add,
              size: 25,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        );
      },

      error: (error, st) => Text("Error: $error"),
      loading: () => Text("Loading..."),
    );
  }
}

class ImageViewer extends ConsumerWidget {
  final ImageModel image;
  final bool isDefault;

  const ImageViewer({super.key, required this.image,  this.isDefault = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(dbRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close),
        ),

        actions: [
        if(!isDefault)  IconButton(
            onPressed: () async {
              await repo.deleteImage(id: image.id);
              refreshAll(ref);
              if (context.mounted) {
                appSnackBar(context, "Image deleted");
                Navigator.pop(context);
              }
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
            child: Image.file(File(image.filePath), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
