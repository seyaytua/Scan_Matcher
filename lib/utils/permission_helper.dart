import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// カメラ権限のヘルパークラス
class PermissionHelper {
  /// カメラ権限をリクエスト
  static Future<bool> requestCameraPermission(BuildContext context) async {
    try {
      // mobile_scannerは自動的に権限をリクエストします
      // ここでは権限の説明ダイアログを表示します
      
      if (!context.mounted) return false;
      
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.blue),
              SizedBox(width: 12),
              Text('カメラ権限が必要です'),
            ],
          ),
          content: const Text(
            'バーコード/QRコードをスキャンするためにカメラへのアクセスが必要です。\n\n'
            '次の画面で「許可」を選択してください。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('続ける'),
            ),
          ],
        ),
      );
      
      return result ?? false;
    } catch (e) {
      debugPrint('カメラ権限リクエストエラー: $e');
      return false;
    }
  }

  /// 権限が拒否された場合のダイアログ
  static void showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('カメラ権限が必要です'),
          ],
        ),
        content: const Text(
          'バーコード/QRコードスキャン機能を使用するには、カメラへのアクセスを許可する必要があります。\n\n'
          '設定からアプリの権限を変更してください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: アプリ設定画面を開く
              // openAppSettings();
            },
            child: const Text('設定を開く'),
          ),
        ],
      ),
    );
  }
}
