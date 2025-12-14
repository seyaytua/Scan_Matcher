import 'package:flutter/foundation.dart';
import '../models/scan_file.dart';
import '../services/file_service.dart';
import '../services/barcode_service.dart';

/// スキャン管理用のProvider
class ScanProvider with ChangeNotifier {
  final FileService _fileService = FileService();
  final BarcodeService _barcodeService = BarcodeService();

  List<ScanFile> _files = [];
  ScanRegion? _currentRegion;
  bool _isScanning = false;

  List<ScanFile> get files => _files;
  ScanRegion? get currentRegion => _currentRegion;
  bool get isScanning => _isScanning;

  // 統計情報
  int get totalFiles => _files.length;
  int get scannedFiles => _files.where((f) => f.status == ScanStatus.success).length;
  int get failedFiles => _files.where((f) => f.status == ScanStatus.failed).length;
  int get matchedFiles => _files.where((f) => f.isMatched == true).length;

  /// ファイルを追加
  Future<void> addFiles() async {
    try {
      final newFiles = await _fileService.pickFiles();
      if (newFiles.isNotEmpty) {
        _files.addAll(newFiles);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ファイル追加エラー: $e');
      }
      rethrow;
    }
  }

  /// ファイルを削除
  void removeFile(String fileId) {
    _files.removeWhere((file) => file.id == fileId);
    notifyListeners();
  }

  /// すべてのファイルをクリア
  void clearAllFiles() {
    _files.clear();
    _currentRegion = null;
    notifyListeners();
  }

  /// スキャン範囲を設定
  void setRegion(ScanRegion? region) {
    _currentRegion = region;
    notifyListeners();
  }

  /// 指定したファイルをスキャン
  Future<void> scanFile(String fileId) async {
    final fileIndex = _files.indexWhere((f) => f.id == fileId);
    if (fileIndex == -1) return;

    try {
      // ステータスを更新
      _files[fileIndex] = _files[fileIndex].copyWith(status: ScanStatus.scanning);
      notifyListeners();

      // バーコードスキャン実行
      final scannedCode = await _barcodeService.scanBarcode(
        _files[fileIndex].fileData,
        _currentRegion,
      );

      // 結果を更新
      if (scannedCode != null) {
        final isMatched = _barcodeService.matchFileName(
          _files[fileIndex].fileName,
          scannedCode,
        );
        
        _files[fileIndex] = _files[fileIndex].copyWith(
          scannedCode: scannedCode,
          isMatched: isMatched,
          matchResult: _barcodeService.getMatchResultMessage(
            isMatched,
            _files[fileIndex].fileName,
            scannedCode,
          ),
          status: ScanStatus.success,
        );
      } else {
        _files[fileIndex] = _files[fileIndex].copyWith(
          matchResult: '❌ コードが検出されませんでした',
          status: ScanStatus.failed,
        );
      }
    } catch (e) {
      _files[fileIndex] = _files[fileIndex].copyWith(
        matchResult: '❌ エラー: ${e.toString()}',
        status: ScanStatus.error,
      );
      if (kDebugMode) {
        debugPrint('スキャンエラー: $e');
      }
    } finally {
      notifyListeners();
    }
  }

  /// すべてのファイルをスキャン
  Future<void> scanAllFiles() async {
    if (_files.isEmpty || _isScanning) return;

    _isScanning = true;
    notifyListeners();

    try {
      for (final file in _files) {
        if (file.status == ScanStatus.pending) {
          await scanFile(file.id);
        }
      }
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// スキャン結果をリセット
  void resetScanResults() {
    for (int i = 0; i < _files.length; i++) {
      _files[i] = _files[i].copyWith(
        scannedCode: null,
        isMatched: null,
        matchResult: null,
        status: ScanStatus.pending,
      );
    }
    notifyListeners();
  }
}
