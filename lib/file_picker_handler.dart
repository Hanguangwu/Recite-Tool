import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// 文件选择处理器
class FilePickerHandler {
  /// 选择文本文件并返回内容
  static Future<String?> pickTextFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        return String.fromCharCodes(file.bytes!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('文件选择错误: $e')),
      );
    }
    return null;
  }
}