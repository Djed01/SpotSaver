import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImage(ImageSource source) async {
  try {
    final xFile = await ImagePicker().pickImage(source: source);
    if (xFile != null) {
      return File(xFile.path);
    }
    return null;
  } catch (e) {
    return null;
  }
}
