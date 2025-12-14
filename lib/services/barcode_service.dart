import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/scan_file.dart';

/// バーコード/QRコード読み取りサービス
class BarcodeService {
  /// 指定された範囲内でバーコード/QRコードを読み取る
  /// 
  /// [fileData] - ファイルのバイトデータ
  /// [region] - 読み取り範囲（null の場合は全体をスキャン）
  Future<String?> scanBarcode(Uint8List fileData, ScanRegion? region) async {
    try {
      // 画像データをデコード
      img.Image? image = img.decodeImage(fileData);
      
      if (image == null) {
        throw Exception('画像のデコードに失敗しました');
      }

      // 指定範囲がある場合は切り取り
      if (region != null && region.isValid) {
        image = img.copyCrop(
          image,
          x: region.x.toInt(),
          y: region.y.toInt(),
          width: region.width.toInt(),
          height: region.height.toInt(),
        );
      }

      // ここでは実際のバーコードスキャンライブラリを使用する想定
      // Web環境では mobile_scanner が制限されるため、
      // 実際の実装では ZXing や別のライブラリを使用する必要があります
      
      // デモ実装: ファイル名から疑似的にコードを生成
      // 実際の実装では、バーコード認識ライブラリを使用してください
      if (kDebugMode) {
        debugPrint('バーコードスキャン実行中...');
      }
      
      // TODO: 実際のバーコード読み取り実装
      // 例: ZXingライブラリを使用した実装
      // final result = await ZXing.scanImage(imageBytes);
      
      return null; // バーコードが見つからない場合
    } catch (e) {
      if (kDebugMode) {
        debugPrint('バーコード読み取りエラー: $e');
      }
      rethrow;
    }
  }

  /// ファイル名とスキャンしたコードをマッチング
  /// 
  /// [fileName] - ファイル名
  /// [scannedCode] - スキャンしたコード
  /// 
  /// 戻り値:
  /// - true: マッチング成功
  /// - false: マッチング失敗
  bool matchFileName(String fileName, String scannedCode) {
    // ファイル名から拡張子を除去
    final nameWithoutExt = fileName.split('.').first;
    
    // 完全一致チェック
    if (nameWithoutExt == scannedCode) {
      return true;
    }
    
    // 部分一致チェック（ファイル名にコードが含まれる）
    if (nameWithoutExt.contains(scannedCode)) {
      return true;
    }
    
    // コードにファイル名が含まれる
    if (scannedCode.contains(nameWithoutExt)) {
      return true;
    }
    
    // 大文字小文字を無視して比較
    if (nameWithoutExt.toLowerCase() == scannedCode.toLowerCase()) {
      return true;
    }
    
    return false;
  }

  /// マッチング結果のメッセージを生成
  String getMatchResultMessage(bool isMatched, String fileName, String? scannedCode) {
    if (scannedCode == null) {
      return '❌ コードが検出されませんでした';
    }
    
    if (isMatched) {
      return '✅ マッチング成功: $scannedCode';
    } else {
      return '⚠️ マッチング失敗: ファイル名と一致しません（検出: $scannedCode）';
    }
  }
}
