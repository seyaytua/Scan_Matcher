import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../providers/scan_provider.dart';
import '../models/scan_file.dart';
import '../utils/responsive_layout.dart';

/// ファイルごとの範囲指定マッピング画面
class RegionMappingScreen extends StatefulWidget {
  const RegionMappingScreen({super.key});

  @override
  State<RegionMappingScreen> createState() => _RegionMappingScreenState();
}

class _RegionMappingScreenState extends State<RegionMappingScreen> {
  String? _selectedFileId;
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
            Icons.crop_free,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'ファイルがありません',
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
          child: _selectedFileId == null
              ? _buildFileSelector(context, provider)
              : _buildRegionEditor(context, provider),
        ),
        if (_selectedFileId != null) _buildControlPanel(context, provider),
      ],
    );
  }

  /// デスクトップレイアウト
  Widget _buildDesktopLayout(BuildContext context, ScanProvider provider) {
    return Row(
      children: [
        // 左側: ファイルリスト
        SizedBox(
          width: 300,
          child: Column(
            children: [
              _buildInstructionCard(context),
              Expanded(
                child: _buildFileSelector(context, provider),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // 右側: 範囲編集エリア
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _selectedFileId == null
                    ? _buildNoFileSelected(context)
                    : _buildRegionEditor(context, provider),
              ),
              if (_selectedFileId != null)
                _buildControlPanel(context, provider),
            ],
          ),
        ),
      ],
    );
  }

  /// 説明カード
  Widget _buildInstructionCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'ファイルを選択し、読み取り範囲をドラッグで指定してください',
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ファイル選択リスト
  Widget _buildFileSelector(BuildContext context, ScanProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.files.length,
      itemBuilder: (context, index) {
        final file = provider.files[index];
        final isSelected = file.id == _selectedFileId;
        final hasRegions = file.scanRegions.isNotEmpty;

        return Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected ? Colors.blue[50] : null,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: hasRegions ? Colors.green : Colors.grey[300],
              child: Icon(
                hasRegions ? Icons.check : Icons.crop_free,
                color: hasRegions ? Colors.white : Colors.grey[600],
              ),
            ),
            title: Text(
              file.fileName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              hasRegions
                  ? '${file.scanRegions.length}個の範囲指定済み'
                  : '範囲未指定',
              style: TextStyle(
                color: hasRegions ? Colors.green[700] : Colors.grey[600],
              ),
            ),
            trailing: Icon(
              isSelected ? Icons.edit : Icons.arrow_forward_ios,
              size: 16,
            ),
            selected: isSelected,
            onTap: () {
              setState(() {
                _selectedFileId = file.id;
                _startPoint = null;
                _endPoint = null;
                _isDrawing = false;
              });
            },
          ),
        );
      },
    );
  }

  /// ファイル未選択時の表示
  Widget _buildNoFileSelected(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            '左のリストからファイルを選択してください',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// 範囲編集エリア
  Widget _buildRegionEditor(BuildContext context, ScanProvider provider) {
    final file = provider.files.firstWhere((f) => f.id == _selectedFileId);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // ファイルプレビュー
            Center(
              child: _buildFilePreview(file),
            ),
            // 保存済み範囲の表示
            ...file.scanRegions.asMap().entries.map((entry) {
              final index = entry.key;
              final region = entry.value;
              return Positioned(
                left: region.x,
                top: region.y,
                width: region.width,
                height: region.height,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    color: Colors.green.withValues(alpha: 0.1),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '範囲${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            provider.removeRegionFromFile(file.id, index);
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // 新しい範囲のドラッグ描画
            if (_isDrawing && _startPoint != null && _endPoint != null)
              Positioned(
                left: _startPoint!.dx < _endPoint!.dx
                    ? _startPoint!.dx
                    : _endPoint!.dx,
                top: _startPoint!.dy < _endPoint!.dy
                    ? _startPoint!.dy
                    : _endPoint!.dy,
                width: (_endPoint!.dx - _startPoint!.dx).abs(),
                height: (_endPoint!.dy - _startPoint!.dy).abs(),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
              ),
            // ジェスチャー検出
            GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDrawing = true;
                  _startPoint = details.localPosition;
                  _endPoint = details.localPosition;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _endPoint = details.localPosition;
                });
              },
              onPanEnd: (details) {
                if (_startPoint != null && _endPoint != null) {
                  final x = _startPoint!.dx < _endPoint!.dx
                      ? _startPoint!.dx
                      : _endPoint!.dx;
                  final y = _startPoint!.dy < _endPoint!.dy
                      ? _startPoint!.dy
                      : _endPoint!.dy;
                  final width = (_endPoint!.dx - _startPoint!.dx).abs();
                  final height = (_endPoint!.dy - _startPoint!.dy).abs();

                  if (width > 20 && height > 20) {
                    final region = ScanRegion(
                      x: x,
                      y: y,
                      width: width,
                      height: height,
                    );
                    provider.addRegionToFile(file.id, region);
                  }
                }

                setState(() {
                  _isDrawing = false;
                  _startPoint = null;
                  _endPoint = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ファイルプレビュー
  Widget _buildFilePreview(ScanFile file) {
    if (file.fileType.toLowerCase() == 'pdf') {
      return Container(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              file.fileName,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'PDFプレビューは未対応',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 画像ファイルの表示
    return Image.memory(
      file.fileData,
      fit: BoxFit.contain,
    );
  }

  /// コントロールパネル
  Widget _buildControlPanel(BuildContext context, ScanProvider provider) {
    final file = provider.files.firstWhere((f) => f.id == _selectedFileId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
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
                  onPressed: () {
                    provider.clearRegionsForFile(file.id);
                    setState(() {});
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('すべてクリア'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: file.scanRegions.isEmpty
                      ? null
                      : () async {
                          await provider.scanFile(file.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  file.scannedCode != null
                                      ? '✅ スキャン完了: ${file.scannedCode}'
                                      : '❌ コードが検出されませんでした',
                                ),
                                backgroundColor: file.scannedCode != null
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('この範囲でスキャン'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '範囲指定: ${file.scanRegions.length}個',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
