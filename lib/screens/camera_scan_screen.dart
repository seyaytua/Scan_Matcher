import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/permission_helper.dart';

/// カメラでリアルタイムスキャンする画面
class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  final List<ScannedCode> _scannedCodes = [];
  bool _isScanning = true;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await PermissionHelper.requestCameraPermission(context);
    setState(() {
      _permissionGranted = granted;
    });
    if (!granted && mounted) {
      PermissionHelper.showPermissionDeniedDialog(context);
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カメラスキャン'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
              });
            },
            tooltip: _isScanning ? '一時停止' : '再開',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => cameraController.switchCamera(),
            tooltip: 'カメラ切替',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // カメラプレビュー
            Expanded(
              flex: 3,
              child: !_permissionGranted
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            size: 100,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'カメラ権限が必要です',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _checkPermission,
                            icon: const Icon(Icons.refresh),
                            label: const Text('再試行'),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                children: [
                  MobileScanner(
                    controller: cameraController,
                    onDetect: _handleBarcode,
                  ),
                  // スキャン範囲のオーバーレイ
                  Center(
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 60,
                            color: Colors.green.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'バーコード/QRコードをここに',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              backgroundColor: Colors.black.withValues(alpha: 0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 一時停止オーバーレイ
                  if (!_isScanning)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pause_circle,
                              size: 100,
                              color: Colors.white,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '一時停止中',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // スキャン済みリスト
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'スキャン済み: ${_scannedCodes.length}件',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.clear_all),
                                onPressed: _scannedCodes.isEmpty
                                    ? null
                                    : () {
                                        setState(() {
                                          _scannedCodes.clear();
                                        });
                                      },
                                tooltip: 'リストクリア',
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _scannedCodes.isEmpty
                                    ? null
                                    : () => _saveScannedCodes(context),
                                icon: const Icon(Icons.save),
                                label: const Text('保存'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _scannedCodes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_2,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'コードをスキャンしてください',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _scannedCodes.length,
                              itemBuilder: (context, index) {
                                final scanned = _scannedCodes[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getTypeColor(scanned.type).withValues(alpha: 0.2),
                                      child: Icon(
                                        _getTypeIcon(scanned.type),
                                        color: _getTypeColor(scanned.type),
                                      ),
                                    ),
                                    title: Text(
                                      scanned.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${_getTypeName(scanned.type)} · ${scanned.time}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _scannedCodes.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// バーコード検出時の処理
  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        // 重複チェック
        if (!_scannedCodes.any((s) => s.code == code)) {
          setState(() {
            _scannedCodes.insert(
              0,
              ScannedCode(
                code: code,
                type: barcode.format,
                time: _formatTime(DateTime.now()),
              ),
            );
          });

          // 振動フィードバック（オプション）
          // HapticFeedback.vibrate();
        }
      }
    }
  }

  /// スキャン結果を保存
  void _saveScannedCodes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スキャン結果を保存'),
        content: Text('${_scannedCodes.length}件のコードをファイルリストに追加しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: スキャン結果をScanFileとして保存
              // 現在はデモ実装のため、実際のファイルデータは生成しない
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_scannedCodes.length}件のコードを保存しました'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                _scannedCodes.clear();
              });
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// バーコードタイプのアイコン取得
  IconData _getTypeIcon(BarcodeFormat type) {
    switch (type) {
      case BarcodeFormat.qrCode:
        return Icons.qr_code;
      case BarcodeFormat.ean13:
      case BarcodeFormat.ean8:
      case BarcodeFormat.upcA:
      case BarcodeFormat.upcE:
        return Icons.barcode_reader;
      default:
        return Icons.qr_code_scanner;
    }
  }

  /// バーコードタイプの色取得
  Color _getTypeColor(BarcodeFormat type) {
    switch (type) {
      case BarcodeFormat.qrCode:
        return Colors.blue;
      case BarcodeFormat.ean13:
      case BarcodeFormat.ean8:
        return Colors.green;
      case BarcodeFormat.upcA:
      case BarcodeFormat.upcE:
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  /// バーコードタイプ名取得
  String _getTypeName(BarcodeFormat type) {
    switch (type) {
      case BarcodeFormat.qrCode:
        return 'QRコード';
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.upcA:
        return 'UPC-A';
      case BarcodeFormat.upcE:
        return 'UPC-E';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      default:
        return type.name.toUpperCase();
    }
  }

  /// 時刻フォーマット
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

/// スキャンしたコードの情報
class ScannedCode {
  final String code;
  final BarcodeFormat type;
  final String time;

  ScannedCode({
    required this.code,
    required this.type,
    required this.time,
  });
}
