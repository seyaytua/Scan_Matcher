import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../models/scan_file.dart';
import '../utils/responsive_layout.dart';

/// スキャン実行画面（範囲指定機能付き）
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  Offset? _startPoint;
  Offset? _endPoint;
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ScanProvider>(
          builder: (context, provider, child) {
            if (provider.files.isEmpty) {
              return _buildEmptyState(context);
            }

            return ResponsiveLayout(
              mobile: _buildMobileLayout(context, provider),
              desktop: _buildDesktopLayout(context, provider),
            );
          },
        ),
      ),
    );
  }

  /// 空の状態のUI
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'スキャンするファイルがありません',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          Text(
            '「ファイル」タブからファイルを追加してください',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  /// モバイルレイアウト
  Widget _buildMobileLayout(BuildContext context, ScanProvider provider) {
    return Column(
      children: [
        _buildInstructionCard(context),
        Expanded(
          child: _buildRegionSelector(context, provider),
        ),
        _buildControlPanel(context, provider),
      ],
    );
  }

  /// デスクトップレイアウト
  Widget _buildDesktopLayout(BuildContext context, ScanProvider provider) {
    return Row(
      children: [
        // 左側: 範囲選択エリア
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildInstructionCard(context),
              Expanded(
                child: _buildRegionSelector(context, provider),
              ),
            ],
          ),
        ),
        // 右側: コントロールパネル
        Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: _buildDetailedControlPanel(context, provider),
        ),
      ],
    );
  }

  /// 操作説明カード
  Widget _buildInstructionCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ResponsiveHelper.isMobile(context)
                    ? '画面をタップ＆ドラッグして読み取り範囲を指定'
                    : 'マウスでドラッグして読み取り範囲を指定してください。範囲を指定しない場合は全体をスキャンします。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 範囲選択エリア
  Widget _buildRegionSelector(BuildContext context, ScanProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!, width: 2),
      ),
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _startPoint = details.localPosition;
            _endPoint = details.localPosition;
            _isDrawing = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _endPoint = details.localPosition;
          });
        },
        onPanEnd: (details) {
          if (_startPoint != null && _endPoint != null) {
            final region = ScanRegion(
              x: _startPoint!.dx < _endPoint!.dx ? _startPoint!.dx : _endPoint!.dx,
              y: _startPoint!.dy < _endPoint!.dy ? _startPoint!.dy : _endPoint!.dy,
              width: (_endPoint!.dx - _startPoint!.dx).abs(),
              height: (_endPoint!.dy - _startPoint!.dy).abs(),
            );
            provider.setRegion(region);
          }
          setState(() {
            _isDrawing = false;
          });
        },
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.crop_free,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.currentRegion != null
                        ? '範囲指定済み\n${provider.currentRegion!.width.toInt()} x ${provider.currentRegion!.height.toInt()}'
                        : _isDrawing
                            ? 'ドラッグ中...'
                            : 'ここをドラッグして範囲を指定',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // 選択中の矩形を描画
            if (_isDrawing && _startPoint != null && _endPoint != null)
              CustomPaint(
                painter: RegionPainter(_startPoint!, _endPoint!),
                child: Container(),
              ),
            // 確定した範囲を描画
            if (!_isDrawing && provider.currentRegion != null)
              Positioned(
                left: provider.currentRegion!.x,
                top: provider.currentRegion!.y,
                child: Container(
                  width: provider.currentRegion!.width,
                  height: provider.currentRegion!.height,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                    ),
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// コントロールパネル（モバイル用）
  Widget _buildControlPanel(BuildContext context, ScanProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: provider.currentRegion != null
                      ? () {
                          provider.setRegion(null);
                          setState(() {
                            _startPoint = null;
                            _endPoint = null;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.clear),
                  label: const Text('範囲クリア'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.isScanning
                      ? null
                      : () async {
                          await provider.scanAllFiles();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('スキャンが完了しました'),
                              ),
                            );
                          }
                        },
                  icon: provider.isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.qr_code_scanner),
                  label: Text(provider.isScanning ? 'スキャン中...' : 'スキャン開始'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '対象: ${provider.files.length}ファイル',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 詳細コントロールパネル（デスクトップ用）
  Widget _buildDetailedControlPanel(
    BuildContext context,
    ScanProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'スキャン設定',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            '対象ファイル数',
            '${provider.files.length}',
            Icons.folder,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            '読み取り範囲',
            provider.currentRegion != null
                ? '${provider.currentRegion!.width.toInt()} x ${provider.currentRegion!.height.toInt()}'
                : '全体',
            Icons.crop_free,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.currentRegion != null
                  ? () {
                      provider.setRegion(null);
                      setState(() {
                        _startPoint = null;
                        _endPoint = null;
                      });
                    }
                  : null,
              icon: const Icon(Icons.clear),
              label: const Text('範囲クリア'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isScanning
                  ? null
                  : () async {
                      await provider.scanAllFiles();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('スキャンが完了しました'),
                          ),
                        );
                      }
                    },
              icon: provider.isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.qr_code_scanner),
              label: Text(provider.isScanning ? 'スキャン中...' : 'スキャン開始'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            '操作ガイド',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildGuideItem(context, '1. マウスでドラッグして範囲を指定'),
          _buildGuideItem(context, '2. 範囲を指定しない場合は全体をスキャン'),
          _buildGuideItem(context, '3. 「スキャン開始」ボタンをクリック'),
          _buildGuideItem(context, '4. 結果は「結果」タブで確認'),
        ],
      ),
    );
  }

  /// 情報カード
  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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

  /// ガイドアイテム
  Widget _buildGuideItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// 矩形描画用のカスタムペインター
class RegionPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  RegionPainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromPoints(start, end);

    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant RegionPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end;
  }
}
