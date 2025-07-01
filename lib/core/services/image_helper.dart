import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> pickImage({bool fromCamera = false}) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(
    source: fromCamera ? ImageSource.camera : ImageSource.gallery,
  );
  if (pickedFile != null) {
    return File(pickedFile.path);
  }
  return null;
}
