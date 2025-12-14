import 'dart:typed_data';

/// スキャン対象のファイル情報を保持するモデル
class ScanFile {
  final String id;
  final String fileName;
  final String fileType;
  final int fileSize;
  final Uint8List fileData;
  final DateTime uploadedAt;
  
  // スキャン結果
  String? scannedCode;
  bool? isMatched;
  String? matchResult;
  ScanStatus status;

  ScanFile({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.fileData,
    required this.uploadedAt,
    this.scannedCode,
    this.isMatched,
    this.matchResult,
    this.status = ScanStatus.pending,
  });

  /// ファイルサイズを人間が読みやすい形式で取得
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// ファイルタイプのアイコン名を取得
  String get fileIcon {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      case 'docx':
      case 'doc':
        return 'description';
      case 'xlsx':
      case 'xlsm':
      case 'xls':
        return 'table_chart';
      default:
        return 'insert_drive_file';
    }
  }

  ScanFile copyWith({
    String? id,
    String? fileName,
    String? fileType,
    int? fileSize,
    Uint8List? fileData,
    DateTime? uploadedAt,
    String? scannedCode,
    bool? isMatched,
    String? matchResult,
    ScanStatus? status,
  }) {
    return ScanFile(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      fileData: fileData ?? this.fileData,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      scannedCode: scannedCode ?? this.scannedCode,
      isMatched: isMatched ?? this.isMatched,
      matchResult: matchResult ?? this.matchResult,
      status: status ?? this.status,
    );
  }
}

/// スキャンステータス
enum ScanStatus {
  pending,    // 未スキャン
  scanning,   // スキャン中
  success,    // スキャン成功
  failed,     // スキャン失敗（コードが見つからない）
  error,      // エラー発生
}

/// スキャン範囲を表すモデル
class ScanRegion {
  final double x;
  final double y;
  final double width;
  final double height;

  ScanRegion({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  bool get isValid => width > 0 && height > 0;
}
