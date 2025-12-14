import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../models/scan_file.dart';
import '../utils/responsive_layout.dart';

/// スキャン結果画面
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ScanProvider>(
          builder: (context, provider, child) {
            final scannedFiles = provider.files
                .where((f) => f.status != ScanStatus.pending)
                .toList();

            if (scannedFiles.isEmpty) {
              return _buildEmptyState(context);
            }

            return ResponsiveLayout(
              mobile: _buildMobileLayout(context, provider, scannedFiles),
              desktop: _buildDesktopLayout(context, provider, scannedFiles),
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
            Icons.assessment,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'スキャン結果がありません',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          Text(
            '「スキャン」タブからスキャンを実行してください',
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
  Widget _buildMobileLayout(
    BuildContext context,
    ScanProvider provider,
    List<ScanFile> scannedFiles,
  ) {
    return Column(
      children: [
        _buildSummaryCard(context, provider),
        _buildFilterTabs(context),
        Expanded(
          child: _buildResultsList(context, scannedFiles),
        ),
      ],
    );
  }

  /// デスクトップレイアウト
  Widget _buildDesktopLayout(
    BuildContext context,
    ScanProvider provider,
    List<ScanFile> scannedFiles,
  ) {
    return Row(
      children: [
        // 左側: 結果リスト
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildFilterTabs(context),
              Expanded(
                child: _buildResultsList(context, scannedFiles),
              ),
            ],
          ),
        ),
        // 右側: サマリーパネル
        Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: _buildSummaryPanel(context, provider),
        ),
      ],
    );
  }

  /// サマリーカード
  Widget _buildSummaryCard(BuildContext context, ScanProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'スキャン結果サマリー',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  Icons.check_circle,
                  '成功',
                  provider.scannedFiles,
                  Colors.green,
                ),
                _buildSummaryItem(
                  context,
                  Icons.error,
                  '失敗',
                  provider.failedFiles,
                  Colors.red,
                ),
                _buildSummaryItem(
                  context,
                  Icons.done_all,
                  'マッチ',
                  provider.matchedFiles,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: provider.totalFiles > 0
                  ? provider.scannedFiles / provider.totalFiles
                  : 0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${provider.scannedFiles} / ${provider.totalFiles} ファイル完了',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// サマリーアイテム
  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  /// フィルタータブ
  Widget _buildFilterTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('すべて'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('成功'),
                  selected: false,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('失敗'),
                  selected: false,
                  onSelected: (selected) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 結果リスト
  Widget _buildResultsList(BuildContext context, List<ScanFile> files) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        return _buildResultCard(context, files[index]);
      },
    );
  }

  /// 結果カード
  Widget _buildResultCard(BuildContext context, ScanFile file) {
    final isSuccess = file.status == ScanStatus.success;
    final isMatched = file.isMatched == true;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isSuccess && isMatched) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = '✅ マッチング成功';
    } else if (isSuccess && !isMatched) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = '⚠️ コード検出・マッチング失敗';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = '❌ スキャン失敗';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          file.fileName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(statusText),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(context, 'ファイル名', file.fileName),
                _buildDetailRow(
                  context,
                  'ファイルタイプ',
                  file.fileType.toUpperCase(),
                ),
                _buildDetailRow(context, 'ファイルサイズ', file.fileSizeFormatted),
                if (file.scannedCode != null)
                  _buildDetailRow(context, '検出コード', file.scannedCode!),
                if (file.matchResult != null) ...[
                  const Divider(height: 24),
                  Text(
                    'マッチング結果',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      file.matchResult!,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 詳細行
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// サマリーパネル（デスクトップ用）
  Widget _buildSummaryPanel(BuildContext context, ScanProvider provider) {
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
          _buildStatCard(
            context,
            '総ファイル数',
            provider.totalFiles,
            Icons.folder,
            Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            'スキャン成功',
            provider.scannedFiles,
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            'スキャン失敗',
            provider.failedFiles,
            Icons.error,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            'マッチング成功',
            provider.matchedFiles,
            Icons.done_all,
            Colors.blue,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            '未読み取りファイル',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...provider.files
              .where((f) => f.status == ScanStatus.failed || f.status == ScanStatus.error)
              .map((file) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      title: Text(
                        file.fileName,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )),
        ],
      ),
    );
  }

  /// 統計カード
  Widget _buildStatCard(
    BuildContext context,
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
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
                    '$value',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
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
}
