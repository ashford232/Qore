import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:study/data/db/db_providers.dart';
import 'package:study/data/extensions.dart';
import 'package:study/data/models/qore_model.dart';
import 'package:study/features/display/views/display_image_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  bool isEditing = false;
  TextEditingController nameController = TextEditingController();
  FocusNode focusNode = FocusNode();

  Future<void> update(
    UserModel? user,
    String name,
    String avater, {
    bool isTyping = false,
  }) async {
    if (user == null) {
      final uuid = const Uuid();
      final user = UserModel(
        id: uuid.v4(),
        name: name,
        avater: avater,
        streak: "1",
      );
      await ref.read(dbRepositoryProvider).saveUser(user: user);
      if (!mounted) return;

      if (!isTyping) appSnackBar(context, "User created");
      refreshUser(ref);
    } else {
      await ref
          .read(dbRepositoryProvider)
          .updateUser(
            user: user.copyWith(name: name, avater: avater),
          );
    }

    if (!mounted) return;
    if (!isTyping) appSnackBar(context, "User updated");
    refreshUser(ref);
  }

  Future<void> openWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/231880421012');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> openGitHub() async {
    final Uri url = Uri.parse('https://github.com/ashford232');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(FluentIcons.chevron_left_24_filled),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 5),
                Text("Qore", style: TextStyle(fontSize: 28)),
              ],
            ),

            userAsync.when(
              data: (user) {
                return Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              buildImage(context, user, theme),

                              const SizedBox(height: 20),

                              isEditing
                                  ? Column(
                                      children: [
                                        IntrinsicWidth(
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.surfaceContainer,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),

                                            child: TextField(
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              controller: nameController,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.zero,
                                                isDense: true,
                                                isCollapsed: true,
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                ),
                                                hintText: user?.name ?? "User",
                                              ),
                                              focusNode: focusNode,
                                              onChanged: (value) {
                                                setState(() {
                                                  update(
                                                    user,
                                                    value.isNotEmpty
                                                        ? value
                                                        : user?.name ?? "",
                                                    user?.avater ?? "",
                                                    isTyping: true,
                                                  );
                                                });
                                              },

                                              onSubmitted: (value) {
                                                setState(() {
                                                  update(
                                                    user,
                                                    value.isNotEmpty
                                                        ? value
                                                        : user?.name ?? "",
                                                    user?.avater ?? "",
                                                  );
                                                  isEditing = false;
                                                  focusNode.unfocus();
                                                });
                                              },
                                              onTapOutside: (e) {
                                                setState(() {
                                                  update(
                                                    user,
                                                    nameController
                                                            .text
                                                            .isNotEmpty
                                                        ? nameController.text
                                                        : user?.name ?? "",
                                                    user?.avater ?? "",
                                                  );
                                                  isEditing = false;
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
                                          isEditing = true;
                                          focusNode.requestFocus();
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          user?.name != null &&
                                                  user!.name.isNotEmpty
                                              ? user.name
                                              : "User",
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

                              const SizedBox(height: 20),
                              Column(
                                children: [
                                  ListTile(
                                    title: Text("Report a Problem"),
                                    leading: Icon(
                                      FluentIcons.warning_24_filled,
                                    ),
                                    subtitle: Text(
                                      "Report any issues you encounter",
                                    ),
                                    onTap: () async {
                                      await openWhatsApp();
                                    },
                                  ),
                                  ListTile(
                                    title: Text("Support Us"),
                                    leading: Icon(FluentIcons.heart_24_filled),
                                    subtitle: Text(
                                      "Get in touch with us for help",
                                    ),
                                    onTap: () async {
                                      await openGitHub();
                                    },
                                  ),
                                  ListTile(
                                    title: Text("Source code"),
                                    leading: Icon(FluentIcons.code_24_filled),
                                    subtitle: Text("View the source code"),
                                    onTap: () async {},
                                  ),
                                  ListTile(
                                    title: Text("View licenses"),
                                    leading: Icon(
                                      FluentIcons.document_24_filled,
                                    ),
                                    subtitle: Text("View all licenses"),
                                    onTap: () {
                                      showLicensePage(context: context);
                                    },
                                  ),
                                  ListTile(
                                    title: Text(
                                      "Delete all Data",
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                    leading: Icon(
                                      FluentIcons.delete_24_filled,
                                      color: theme.colorScheme.error,
                                    ),
                                    subtitle: Text(
                                      "Permanently delete all your data",
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Delete all Data"),
                                        content: Text(
                                          "Are you sure you want to delete all your data?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await ref
                                                  .read(dbRepositoryProvider)
                                                  .deleteAll();

                                              if (context.mounted) {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              }
                                              refreshAll(ref);
                                              refreshUser(ref);
                                            },
                                            child: Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Column(),
                    ],
                  ),
                );
              },
              error: (error, stack) {
                return Center(child: Text(error.toString()));
              },
              loading: () {
                return Center(
                  child: Skeletonizer(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundColor: theme.colorScheme.surfaceContainer,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Center buildImage(BuildContext context, UserModel? user, ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          showModalBottomSheet(
            showDragHandle: true,
            context: context,
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user != null)
                      ListTile(
                        leading: Icon(FluentIcons.eye_24_filled),
                        title: Text("See image"),
                        onTap: () async {
                          if (user.avater.isEmpty) {
                            return;
                          }

                          final img = ImageModel(
                            id: "",
                            qoreId: "",
                            filePath: user.avater,
                            text: '',
                            createdAt: DateTime.now(),
                            tags: ["Profile"],
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ImageViewer(image: img, isDefault: true),
                            ),
                          );
                        },
                      ),
                    ListTile(
                      leading: Icon(FluentIcons.image_24_filled),
                      title: Text(
                        user == null ? "Upload image" : "Change image",
                      ),
                      onTap: () async {
                        final image = await getMultipleImage(multiple: false);
                        if (image.isNotEmpty) {
                          update(
                            user,
                            nameController.text.isNotEmpty
                                ? nameController.text
                                : user?.name ?? "",
                            image[0],
                          );
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: SizedBox(
          width: 130,
          height: 130,
          child: CircleAvatar(
            radius: 65,
            backgroundColor: theme.colorScheme.surfaceContainer,
            child: user?.avater != null && user!.avater.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Image.file(File(user.avater), fit: BoxFit.cover),
                    ),
                  )
                : Text("🤪", style: TextStyle(fontSize: 80)),
          ),
        ),
      ),
    );
  }
}
