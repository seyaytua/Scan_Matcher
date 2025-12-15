import 'package:flutter/material.dart';
import '../models/scan_file.dart';

/// ファイルプレビューダイアログ
class FilePreviewDialog extends StatelessWidget {
  final ScanFile file;

  const FilePreviewDialog({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.fileName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${file.fileType.toUpperCase()} • ${file.fileSizeFormatted}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // コンテンツ
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: Center(
                  child: _buildPreviewContent(context),
                ),
              ),
            ),
            // フッター（範囲情報）
            if (file.scanRegions.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border(
                    top: BorderSide(color: Colors.green[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.crop_free, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '範囲指定: ${file.scanRegions.length}個',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent(BuildContext context) {
    final fileType = file.fileType.toLowerCase();

    // 画像ファイル
    if (fileType == 'jpg' || fileType == 'jpeg' || fileType == 'png') {
      return SingleChildScrollView(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.memory(
            file.fileData,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget(error);
            },
          ),
        ),
      );
    }

    // PDFファイル
    if (fileType == 'pdf') {
      return _buildUnsupportedWidget(
        icon: Icons.picture_as_pdf,
        iconColor: Colors.red,
        title: 'PDFプレビュー',
        message: 'PDFファイルのプレビューは現在サポートされていません',
      );
    }

    // Officeファイル
    if (fileType == 'docx' || fileType == 'xlsx' || fileType == 'xlsm') {
      return _buildUnsupportedWidget(
        icon: fileType == 'docx' ? Icons.description : Icons.table_chart,
        iconColor: Colors.blue,
        title: 'Officeファイル',
        message: 'Office文書のプレビューは現在サポートされていません',
      );
    }

    // その他のファイル
    return _buildUnsupportedWidget(
      icon: Icons.insert_drive_file,
      iconColor: Colors.grey,
      title: 'プレビュー不可',
      message: 'このファイル形式のプレビューはサポートされていません',
    );
  }

  Widget _buildUnsupportedWidget({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            '画像の読み込みに失敗',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'エラー: ${error.toString()}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    switch (file.fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'docx':
      case 'doc':
        return Icons.description;
      case 'xlsx':
      case 'xlsm':
      case 'xls':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  static void show(BuildContext context, ScanFile file) {
    showDialog(
      context: context,
      builder: (context) => FilePreviewDialog(file: file),
    );
  }
}
