# macOS 画面共有 入力ソース同期ツール

> **対応機種:** Apple Mac、MacBook Air、MacBook Pro、Mac mini、iMac、Mac Studio、Mac Pro  
> **キーワード:** macOS, 画面共有, 入力ソース, IME, VNC, Hammerspoon

画面共有使用時にローカルとリモートMac間で入力ソースを同期します。

## ⚠️ このツールが必要か確認してください

新しい macOS の画面共有には「キーボード言語を同期」機能が内蔵されています。

確認方法：**画面共有 App → 設定**で、このオプションがあるか確認してください。

- ✅ **オプションがある** → 有効にするだけで、このツールは不要です
- ❌ **オプションがない** → macOS バージョンが古いため、このツールをご使用ください

**このツールの対象：**
- ローカルまたはリモートの Mac が古い macOS で、内蔵同期機能がない場合
- 内蔵機能に問題がある場合のバックアップ

## 問題

macOS内蔵の画面共有を使用すると、入力ソースは以下のように動作します：

| ローカル入力 | リモート入力 | 実際の出力 |
|-------------|-------------|-----------|
| 英語 | 日本語 | 英語 ❌ |
| 日本語 | 英語 | 日本語 ❌ |
| 日本語 | 日本語 | 日本語 ✅ |

これは画面共有が「処理済みの文字」を送信し、生のキーストロークを送信しないためです。

## 機能

- ✅ **正確な同期** — macismモードで入力ソースを直接指定、ズレなし
- ✅ **ホストごとの設定** — 各ホストでtoggleまたはmacismモードを選択
- ✅ **SSH ControlMaster高速化** — 10-50msの遅延のみ
- ✅ **フォーカス認識** — 画面共有ウィンドウがフォーカスされている時のみ動作
- ✅ **新規ホスト自動検出** — 初回接続時に設定、以降は記憶
- ✅ **メニューバー制御** — 一時停止/再開、ホストの追加/編集/削除

## 同期モード

| モード | アイコン | 説明 | リモート要件 |
|-------|---------|------|-------------|
| **Toggle** | 🔄 | Ctrl+Spaceを送信して切り替え | SSH + アクセシビリティ権限 |
| **macism** | 🎯 | 入力ソースIDを直接指定 | SSH + macism（macOS 10.15+必要） |

**注意：** macismはmacOS 10.15（Catalina）以降が必要です。古いバージョンはToggleモードを使用してください。

## システム要件

**ローカル（制御Mac）：**
- macOS 10.15以降
- Homebrew
- Hammerspoon

**リモート（被制御Mac）：**
- macOS 10.14以降
- SSH（リモートログイン）有効
- アクセシビリティ権限付与

---

## インストール

### ステップ1：リモート設定（被制御Macで操作）

#### 1. SSH（リモートログイン）を有効化

```
システム環境設定 → 共有 → 「リモートログイン」にチェック
```

接続情報をメモ（例：`ssh user@192.168.1.100`）

#### 2. アクセシビリティ権限を付与

SSH経由のAppleScriptにはアクセシビリティ権限が必要：

```
システム環境設定 → セキュリティとプライバシー → プライバシー → アクセシビリティ
```

1. 🔒をクリックして解除
2. 「+」をクリックして `/usr/bin/osascript` を追加
   - `Cmd+Shift+G` を押して `/usr/bin/` を入力
   - `osascript` を選択

または「ターミナル」アプリを追加することも可能。

#### 3. アクセシビリティ権限をテスト

リモートMacで実行：

```bash
osascript -e 'tell application "System Events" to key code 49 using control down'
```

入力ソースが切り替われば、権限設定は成功です。

---

### ステップ2：ローカル設定（制御Macで操作）

#### 1. Hammerspoonをインストール

```bash
brew install --cask hammerspoon
```

#### 2. 設定ファイルをダウンロード

```bash
mkdir -p ~/.hammerspoon
curl -o ~/.hammerspoon/init.lua https://raw.githubusercontent.com/taigadit/mac-screen-sharing-input-sync/main/init.lua
```

#### 3. Hammerspoonに権限を付与

1. Hammerspoonを開く
2. 「システム設定 → プライバシーとセキュリティ → アクセシビリティ」へ
3. Hammerspoonを許可

#### 4. SSHパスワードなしログインを設定

```bash
# キーを生成（まだの場合）
ssh-keygen -t ed25519

# リモートにコピー（パスワードを1回入力）
ssh-copy-id user@リモートIP
```

パスワードなしログインを確認：

```bash
ssh user@リモートIP "echo ok"
```

パスワードなしで `ok` と表示されれば成功です。

#### 5. リモート入力切り替えをテスト

```bash
ssh user@リモートIP "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
```

リモートの入力ソースが切り替われば、設定完了です！

#### 6. SSH ControlMasterを設定（推奨）

```bash
mkdir -p ~/.ssh/sockets
```

`~/.ssh/config` を編集して追加：

```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
```

権限を設定：

```bash
chmod 600 ~/.ssh/config
```

これで遅延が200-500msから10-50msに減少します。

#### 7. Hammerspoon設定を読み込み

メニューバーのHammerspoonアイコン（🔨）をクリック → Reload Config

---

## 使い方

1. **画面共有を開いて**リモートMacに接続
2. **画面共有ウィンドウをクリック**（フォーカスさせる）
3. **ローカルの入力ソースを切り替え**
4. リモートが自動的に同期されます！

### 初回接続

初回はダイアログが表示されます：
1. SSH接続情報を入力（例：`user@192.168.1.100`）
2. 同期モードを選択（ToggleまたはMacism）
3. 設定は自動保存されます

### Toggleモードの注意

Toggleモードは Ctrl+Space を使用し、入力ソースを切り替えるだけです。

**重要：** 使用前に両方の入力ソースを手動で揃えてください（両方英語または両方日本語）。その後は同期が維持されます。

---

## ライセンス

MIT License

---

**Developed by [Dajiade Co., Ltd.](https://www.dajiade.com)** (taigadit)
