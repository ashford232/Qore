import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void appSnackBar(BuildContext context, String message, {int duration = 2}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      duration: Duration(seconds: duration),
    ),
  );
}

Future showAppDialog(
  BuildContext context,
  String title,
  String content, {
  VoidCallback? onYes,
  String? yesText = "Yes",
  String? noText = "No",
  bool? showNoButton,
  bool? showYesButton,
}) async {
  return await showAdaptiveDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (showNoButton != false)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(noText ?? "No"),
            ),
          if (showYesButton != false)
            TextButton(onPressed: onYes, child: Text(yesText ?? "Yes")),
        ],
      );
    },
  );
}

Future<XFile?> compressImage(File file, String targetPath) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 88,
  );

  return result;
}

Future<List<String>> getMultipleImage({
  ImageSource source = ImageSource.gallery,
  bool multiple = true,
}) async {
  final picker = ImagePicker();

  List<XFile> res;
  if (multiple) {
    res = await picker.pickMultiImage();
  } else {
    final file = await picker.pickImage(source: source);
    if (file != null) {
      res = [file];
    } else {
      res = [];
    }
  }

  if (res.isEmpty) return [];

  final dir = await getApplicationDocumentsDirectory();

  final path = "${dir.path}/images/";

  await Directory(path).create(recursive: true);

  List<String> newImages = [];

  for (int i = 0; i < res.length; i++) {
    final file = File(res[i].path);

    final fileName = "${DateTime.now().millisecondsSinceEpoch}_$i.jpg";

    final targetPath = "$path$fileName";

    final compressed = await compressImage(file, targetPath);

    if (compressed != null) {
      newImages.add(compressed.path);
    }
  }

  return newImages;
}
