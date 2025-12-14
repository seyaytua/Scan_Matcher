import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/scan_file.dart';

/// ファイル選択・管理サービス
class FileService {
  /// ファイルを選択（複数選択可能）
  Future<List<ScanFile>> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'docx', 'xlsx', 'xlsm'],
        allowMultiple: true,
        withData: true, // Web対応のためバイトデータを取得
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      List<ScanFile> scanFiles = [];
      
      for (var file in result.files) {
        if (file.bytes != null) {
          final fileType = file.extension ?? '';
          scanFiles.add(
            ScanFile(
              id: DateTime.now().millisecondsSinceEpoch.toString() + file.name.hashCode.toString(),
              fileName: file.name,
              fileType: fileType,
              fileSize: file.size,
              fileData: file.bytes!,
              uploadedAt: DateTime.now(),
            ),
          );
        }
      }

      return scanFiles;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ファイル選択エラー: $e');
      }
      rethrow;
    }
  }

  /// ファイルタイプが対応しているかチェック
  bool isSupportedFileType(String fileType) {
    const supportedTypes = ['pdf', 'jpg', 'jpeg', 'png', 'docx', 'xlsx', 'xlsm'];
    return supportedTypes.contains(fileType.toLowerCase());
  }

  /// PDFファイルかどうか
  bool isPDF(String fileType) {
    return fileType.toLowerCase() == 'pdf';
  }

  /// 画像ファイルかどうか
  bool isImage(String fileType) {
    return ['jpg', 'jpeg', 'png'].contains(fileType.toLowerCase());
  }

  /// Officeファイルかどうか
  bool isOfficeFile(String fileType) {
    return ['docx', 'xlsx', 'xlsm'].contains(fileType.toLowerCase());
  }
}
