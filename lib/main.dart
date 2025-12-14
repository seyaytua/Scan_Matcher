import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/scan_provider.dart';
import 'screens/file_list_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/camera_scan_screen.dart';
import 'screens/results_screen.dart';
import 'utils/responsive_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanProvider(),
      child: MaterialApp(
        title: 'Scan Matcher',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: const CardThemeData(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          appBarTheme: const AppBarThemeData(
            centerTitle: true,
            elevation: 2,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FileListScreen(),
    const ScanScreen(),
    const CameraScanScreen(),
    const ResultsScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.folder,
      label: 'ファイル',
      description: 'ファイルを管理',
    ),
    NavigationItem(
      icon: Icons.crop_free,
      label: '範囲指定',
      description: '範囲を指定してスキャン',
    ),
    NavigationItem(
      icon: Icons.camera_alt,
      label: 'カメラ',
      description: 'カメラでスキャン',
    ),
    NavigationItem(
      icon: Icons.assessment,
      label: '結果',
      description: 'スキャン結果を確認',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icon/app_icon.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 12),
            const Text('Scan Matcher'),
          ],
        ),
        actions: [
          if (ResponsiveHelper.isDesktop(context))
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Consumer<ScanProvider>(
                  builder: (context, provider, child) {
                    return Chip(
                      avatar: const Icon(Icons.folder, size: 16),
                      label: Text('${provider.totalFiles} ファイル'),
                    );
                  },
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'アプリについて',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  /// モバイルレイアウト（下部ナビゲーション）
  Widget _buildMobileLayout() {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _navigationItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  /// デスクトップレイアウト（サイドナビゲーション）
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: _navigationItems
              .map(
                (item) => NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.label),
                ),
              )
              .toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: _screens[_currentIndex],
        ),
      ],
    );
  }

  /// アプリ情報ダイアログ
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/icon/app_icon.png',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 12),
            const Text('Scan Matcher'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'バーコード/QRコード読み取りアプリ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('対応ファイル形式:'),
            const SizedBox(height: 8),
            _buildFileTypeChip('PDF'),
            _buildFileTypeChip('JPEG / PNG'),
            _buildFileTypeChip('DOCX'),
            _buildFileTypeChip('XLSX / XLSM'),
            const SizedBox(height: 16),
            const Text(
              '機能:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• 複数ファイルの一括スキャン'),
            const Text('• 読み取り範囲の指定'),
            const Text('• ファイル名とのマッチング'),
            const Text('• PC/スマホ対応'),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// ファイルタイプチップ
  Widget _buildFileTypeChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// ナビゲーションアイテム
class NavigationItem {
  final IconData icon;
  final String label;
  final String description;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.description,
  });
}
