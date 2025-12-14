import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../models/scan_file.dart';
import '../utils/responsive_layout.dart';

/// ファイル一覧画面
class FileListScreen extends StatelessWidget {
  const FileListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final provider = Provider.of<ScanProvider>(context, listen: false);
          try {
            await provider.addFiles();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ファイル選択エラー: $e')),
              );
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('ファイル追加'),
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
            Icons.folder_open,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'ファイルが選択されていません',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          Text(
            '「ファイル追加」ボタンから\nPDF、画像、Officeファイルを選択してください',
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
        _buildStatsBar(context, provider),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.files.length,
            itemBuilder: (context, index) {
              return _buildFileCard(context, provider.files[index], provider);
            },
          ),
        ),
      ],
    );
  }

  /// デスクトップレイアウト
  Widget _buildDesktopLayout(BuildContext context, ScanProvider provider) {
    return Row(
      children: [
        // 左側: ファイルリスト
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildStatsBar(context, provider),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.getGridColumns(context),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3,
                  ),
                  itemCount: provider.files.length,
                  itemBuilder: (context, index) {
                    return _buildFileCard(
                      context,
                      provider.files[index],
                      provider,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // 右側: 統計情報
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: _buildDetailPanel(context, provider),
        ),
      ],
    );
  }

  /// 統計バー
  Widget _buildStatsBar(BuildContext context, ScanProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.folder,
            '総ファイル数',
            '${provider.totalFiles}',
          ),
          _buildStatItem(
            context,
            Icons.check_circle,
            'スキャン成功',
            '${provider.scannedFiles}',
            Colors.green,
          ),
          _buildStatItem(
            context,
            Icons.error,
            'スキャン失敗',
            '${provider.failedFiles}',
            Colors.red,
          ),
          _buildStatItem(
            context,
            Icons.done_all,
            'マッチング成功',
            '${provider.matchedFiles}',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  /// 統計アイテム
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, [
    Color? color,
  ]) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[700], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// ファイルカード
  Widget _buildFileCard(
    BuildContext context,
    ScanFile file,
    ScanProvider provider,
  ) {
    Color statusColor = _getStatusColor(file.status);
    IconData statusIcon = _getStatusIcon(file.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(_getFileIcon(file.fileType), color: statusColor),
        ),
        title: Text(
          file.fileName,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${file.fileType.toUpperCase()} · ${file.fileSizeFormatted}'),
            if (file.matchResult != null) ...[
              const SizedBox(height: 4),
              Text(
                file.matchResult!,
                style: TextStyle(
                  color: file.isMatched == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  provider.removeFile(file.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('削除'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 詳細パネル（デスクトップ用）
  Widget _buildDetailPanel(BuildContext context, ScanProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'スキャン統計',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildDetailItem(context, '総ファイル数', '${provider.totalFiles}'),
          _buildDetailItem(context, 'スキャン成功', '${provider.scannedFiles}'),
          _buildDetailItem(context, 'スキャン失敗', '${provider.failedFiles}'),
          _buildDetailItem(context, 'マッチング成功', '${provider.matchedFiles}'),
          const SizedBox(height: 24),
          if (provider.files.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.clearAllFiles();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('すべてクリア'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 詳細アイテム
  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// ステータス色を取得
  Color _getStatusColor(ScanStatus status) {
    switch (status) {
      case ScanStatus.pending:
        return Colors.grey;
      case ScanStatus.scanning:
        return Colors.orange;
      case ScanStatus.success:
        return Colors.green;
      case ScanStatus.failed:
        return Colors.red;
      case ScanStatus.error:
        return Colors.red;
    }
  }

  /// ステータスアイコンを取得
  IconData _getStatusIcon(ScanStatus status) {
    switch (status) {
      case ScanStatus.pending:
        return Icons.pending;
      case ScanStatus.scanning:
        return Icons.sync;
      case ScanStatus.success:
        return Icons.check_circle;
      case ScanStatus.failed:
        return Icons.error;
      case ScanStatus.error:
        return Icons.error_outline;
    }
  }

  /// ファイルアイコンを取得
  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
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
}
