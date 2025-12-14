# 📱 Scan Matcher

バーコード/QRコード読み取りアプリ - PC/スマホ完全対応

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🌐 GitHub Pages

**ランディングページ**: https://seyaytua.github.io/Scan_Matcher/

## ✨ 主要機能

### 📁 ファイル管理
- PDF、JPEG、PNG、DOCX、XLSX、XLSM対応
- 複数ファイル選択
- リアルタイム統計表示

### 🎯 範囲指定スキャン
- ドラッグ＆ドロップで範囲選択
- リアルタイムプレビュー
- 一括スキャン実行

### 📷 カメラリアルタイムスキャン
- バーコード/QRコード即座認識
- スキャン履歴リスト
- 重複防止機能
- バーコードタイプ識別

### 📊 結果表示
- 成功/失敗詳細表示
- マッチング判定結果
- サマリー統計

## 🎨 スクリーンショット

*Coming soon...*

## 📦 ダウンロード

### Android (AAB)
- [app-release.aab (49.6MB)](https://www.genspark.ai/api/code_sandbox/download_file_stream?project_id=8d0bd4fa-697a-4501-9f61-e4ae3ff1a8a4&file_path=%2Fhome%2Fuser%2Fflutter_app%2Fbuild%2Fapp%2Foutputs%2Fbundle%2Frelease%2Fapp-release.aab&file_name=app-release.aab)

## 🔧 技術スタック

```yaml
Flutter: 3.35.4
Dart: 3.9.2

主要パッケージ:
- provider: 6.1.5+1        # 状態管理
- mobile_scanner: 5.2.3    # バーコードスキャン
- file_picker: 8.3.7       # ファイル選択
- image: 4.6.0             # 画像処理
- shared_preferences: 2.5.3 # ローカルストレージ
```

## 🚀 セットアップ

### 必要要件
- Flutter 3.35.4
- Dart 3.9.2
- Android SDK (Android開発の場合)

### インストール

```bash
# リポジトリをクローン
git clone https://github.com/seyaytua/Scan_Matcher.git
cd Scan_Matcher

# 依存関係をインストール
flutter pub get

# Webで実行
flutter run -d chrome

# Androidで実行
flutter run
```

## 📱 ビルド

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (AAB)
```bash
flutter build appbundle --release
```

### Web
```bash
flutter build web --release
```

## 📂 プロジェクト構造

```
lib/
├── main.dart                      # メインアプリケーション
├── models/
│   └── scan_file.dart            # データモデル
├── services/
│   ├── file_service.dart         # ファイル選択サービス
│   └── barcode_service.dart      # バーコードスキャンサービス
├── providers/
│   └── scan_provider.dart        # 状態管理
├── screens/
│   ├── file_list_screen.dart     # ファイル一覧画面
│   ├── scan_screen.dart          # 範囲指定スキャン画面
│   ├── camera_scan_screen.dart   # カメラスキャン画面
│   └── results_screen.dart       # 結果表示画面
└── utils/
    ├── responsive_layout.dart    # レスポンシブレイアウト
    └── permission_helper.dart    # 権限ヘルパー
```

## 🎯 対応バーコードタイプ

- QRコード
- EAN-13
- EAN-8
- UPC-A
- UPC-E
- Code 128
- Code 39
- その他多数

## 💻 対応プラットフォーム

- ✅ Android
- ✅ Web (レスポンシブ)
- ✅ PC/タブレット/スマホ

## 🤝 コントリビューション

プルリクエストを歓迎します！大きな変更の場合は、まずissueを開いて変更内容を議論してください。

## 📄 ライセンス

MIT License

## 📧 コンタクト

- GitHub: [@seyaytua](https://github.com/seyaytua)
- Issues: [GitHub Issues](https://github.com/seyaytua/Scan_Matcher/issues)

## 🙏 謝辞

- [Flutter](https://flutter.dev/) - UIフレームワーク
- [mobile_scanner](https://pub.dev/packages/mobile_scanner) - バーコードスキャン
- [Material Design](https://material.io/) - デザインシステム

---

Made with Flutter 💙
