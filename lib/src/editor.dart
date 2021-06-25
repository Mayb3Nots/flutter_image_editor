import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image_editor/src/channel.dart';
import 'image_handler.dart';
import 'option/edit_options.dart';

class ImageEditor {
  /// [image] Uint8List
  /// [imageEditorOption] option of
  static Future<Uint8List?> editImage({
    required Uint8List image,
    required ImageEditorOption imageEditorOption,
  }) async {
    Uint8List? tmp = image;
    for (final group in imageEditorOption.groupList) {
      if (group.canIgnore) {
        continue;
      }
      final handler = ImageHandler.memory(tmp);
      final editOption = ImageEditorOption();
      for (final option in group) {
        editOption.addOption(option);
      }
      editOption.outputFormat = imageEditorOption.outputFormat;

      tmp = await handler.handleAndGetUint8List(editOption);
    }

    return tmp;
  }

  static Future<Uint8List?> editFileImage({
    required File file,
    required ImageEditorOption imageEditorOption,
  }) async {
    Uint8List? tmp;
    bool isHandle = false;

    for (final group in imageEditorOption.groupList) {
      if (group.canIgnore) {
        continue;
      }
      final handler = ImageHandler.file(file);
      final editOption = ImageEditorOption();
      for (final option in group) {
        editOption.addOption(option);
      }

      editOption.outputFormat = imageEditorOption.outputFormat;

      tmp = await handler.handleAndGetUint8List(editOption);

      isHandle = true;
    }

    if (isHandle) {
      return tmp;
    } else {
      return file.readAsBytesSync();
    }
  }

  static Future<File?> editFileImageAndGetFile(
      {required File file,
      required ImageEditorOption imageEditorOption,
      String? customFileName}) async {
    File? tmp = file;
    for (final group in imageEditorOption.groupList) {
      if (group.canIgnore) {
        continue;
      }
      final handler = ImageHandler.file(tmp);
      final editOption = ImageEditorOption();
      for (final option in group) {
        editOption.addOption(option);
      }

      editOption.outputFormat = imageEditorOption.outputFormat;

      final target = await _createTmpFilePath(customName: customFileName);

      tmp = await handler.handleAndGetFile(editOption, target);
    }
    return tmp;
  }

  static Future<File> editImageAndGetFile(
      {required Uint8List image,
      required ImageEditorOption imageEditorOption,
      String? customFileName}) async {
    Uint8List? tmp = image;

    for (final group in imageEditorOption.groupList) {
      if (group.canIgnore) {
        continue;
      }
      final handler = ImageHandler.memory(tmp);
      final editOption = ImageEditorOption();
      for (final option in group) {
        editOption.addOption(option);
      }

      editOption.outputFormat = imageEditorOption.outputFormat;

      tmp = await handler.handleAndGetUint8List(editOption);
    }

    final file = File(await _createTmpFilePath(customName: customFileName));

    if (tmp != null) {
      await file.writeAsBytes(tmp);
    }

    return file;
  }

  static Future<String> _createTmpFilePath({String? customName}) async {
    final cacheDir = await NativeChannel.getCachePath();
    final name = DateTime.now().millisecondsSinceEpoch;

    return "${cacheDir.path}/$name$customName";
  }
}
