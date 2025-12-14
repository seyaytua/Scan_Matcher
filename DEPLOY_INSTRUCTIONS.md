# GitHub Pages デプロイ手順

## 🚨 重要：GitHub Pages設定

現在、以下のURLで404エラーが発生しています：
https://seyaytua.github.io/Scan_Matcher/

## ✅ 解決方法

### 1. GitHub Pagesを有効化

1. リポジトリにアクセス： https://github.com/seyaytua/Scan_Matcher
2. 「Settings」タブをクリック
3. 左サイドバーの「Pages」をクリック
4. **「Build and deployment」セクション：**
   - **Source**: `Deploy from a branch` を選択
   - **Branch**: `main` を選択
   - **Folder**: `/ (root)` を選択 ← **重要！**
   - 「Save」をクリック

### 2. 待機

- GitHub Pagesがビルドを開始します（2-5分）
- Actionsタブで進捗確認： https://github.com/seyaytua/Scan_Matcher/actions
- 緑のチェックマーク✅が表示されるまで待つ

### 3. アクセス

以下のURLで WEBアプリにアクセス可能：
**https://seyaytua.github.io/Scan_Matcher/**

## 📁 デプロイ済みファイル

以下のファイルがルートディレクトリに配置されています：

```
/ (root)
├── index.html              ← メインHTML
├── main.dart.js            ← Flutterコンパイル済みJS (2.6MB)
├── flutter.js              ← Flutter起動スクリプト
├── flutter_bootstrap.js    ← Bootstrapスクリプト
├── flutter_service_worker.js ← Service Worker
├── manifest.json           ← PWA設定
├── assets/                 ← アセット
├── canvaskit/              ← CanvasKit (レンダリングエンジン)
└── icons/                  ← アイコン
```

## 🔧 トラブルシューティング

### 404エラーが続く場合

1. **GitHub Pages設定を再確認**
   - Folder が `/ (root)` になっているか確認

2. **ブラウザキャッシュをクリア**
   - Windows: Ctrl + Shift + Delete
   - Mac: Cmd + Shift + Delete

3. **シークレットモードで確認**
   - キャッシュの影響を受けずにテスト可能

4. **デプロイ状況を確認**
   - https://github.com/seyaytua/Scan_Matcher/actions
   - 「pages build and deployment」が成功しているか確認

## 📝 注意事項

- `base href` は `/Scan_Matcher/` に設定済み
- すべての必須ファイルがリポジトリにコミット済み
- GitHub Pagesの設定のみが必要です
