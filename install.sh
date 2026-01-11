#!/bin/bash

#
# macOS Screen Sharing Input Sync - Install Script
# macOS 螢幕共享輸入法同步工具 - 安裝腳本
# 
# Usage / 使用方式：
# curl -fsSL https://raw.githubusercontent.com/taigadit/mac-screen-sharing-input-sync/main/install.sh | bash
#

set -e

# Detect system language / 偵測系統語言
LANG_CODE=$(defaults read -g AppleLocale 2>/dev/null | cut -d'_' -f1)

# i18n messages / 多國語言訊息
case "$LANG_CODE" in
    zh)
        # Check if Traditional or Simplified
        LOCALE=$(defaults read -g AppleLocale 2>/dev/null)
        if [[ "$LOCALE" == *"TW"* ]] || [[ "$LOCALE" == *"HK"* ]] || [[ "$LOCALE" == *"Hant"* ]]; then
            # 繁體中文
            MSG_TITLE="macOS 螢幕共享輸入法同步工具"
            MSG_MACOS_ONLY="❌ 此工具僅支援 macOS"
            MSG_NEED_BREW="❌ 需要 Homebrew，請先安裝："
            MSG_BREW_FOUND="✅ 檢測到 Homebrew"
            MSG_HS_INSTALLED="✅ Hammerspoon 已安裝"
            MSG_HS_INSTALLING="📦 安裝 Hammerspoon..."
            MSG_HS_DONE="✅ Hammerspoon 安裝完成"
            MSG_CREATE_DIR="📁 建立設定目錄..."
            MSG_BACKUP="📋 備份現有設定..."
            MSG_DOWNLOAD="⬇️  下載設定檔..."
            MSG_SSH_SETUP="⚡ 設定 SSH ControlMaster 加速連線..."
            MSG_SSH_DONE="✅ SSH ControlMaster 已設定（延遲 200ms → 10ms）"
            MSG_SSH_EXISTS="✅ SSH ControlMaster 已存在"
            MSG_COMPLETE="✅ 安裝完成！"
            MSG_NEXT_STEPS="接下來請手動完成以下步驟："
            MSG_STEP1="1️⃣  打開 Hammerspoon"
            MSG_STEP2="2️⃣  授權輔助使用權限"
            MSG_STEP2_DESC="    系統設定 → 隱私權與安全性 → 輔助使用"
            MSG_STEP2_DESC2="    允許 Hammerspoon"
            MSG_STEP3="3️⃣  設定 SSH 免密碼登入（每台遠端主機）"
            MSG_STEP4="4️⃣  遠端授權輔助使用（每台遠端主機）"
            MSG_STEP4_DESC="    系統偏好設定 → 安全性與隱私 → 輔助使用"
            MSG_STEP4_DESC2="    新增 /usr/bin/osascript"
            MSG_STEP5="5️⃣  開始使用！"
            MSG_STEP5_DESC="    開啟螢幕共享 → 點進視窗 → 切換輸入法"
            MSG_STEP5_DESC2="    第一次會詢問 SSH 設定，之後自動記住"
            MSG_OPEN_HS="是否立即打開 Hammerspoon？(y/n) "
            MSG_REMINDER="🔔 請記得到「系統設定 → 隱私權與安全性 → 輔助使用」允許 Hammerspoon"
            MSG_FOUND_EXISTING="⚠️  發現已存在的 init.lua"
            MSG_OVERWRITE_PROMPT="是否覆蓋為新版本？(y/n) "
            MSG_SKIP_DOWNLOAD="⏭️  跳過下載，保留現有設定"
        else
            # 简体中文
            MSG_TITLE="macOS 屏幕共享输入法同步工具"
            MSG_MACOS_ONLY="❌ 此工具仅支持 macOS"
            MSG_NEED_BREW="❌ 需要 Homebrew，请先安装："
            MSG_BREW_FOUND="✅ 检测到 Homebrew"
            MSG_HS_INSTALLED="✅ Hammerspoon 已安装"
            MSG_HS_INSTALLING="📦 安装 Hammerspoon..."
            MSG_HS_DONE="✅ Hammerspoon 安装完成"
            MSG_CREATE_DIR="📁 创建设置目录..."
            MSG_BACKUP="📋 备份现有设置..."
            MSG_DOWNLOAD="⬇️  下载配置文件..."
            MSG_SSH_SETUP="⚡ 设置 SSH ControlMaster 加速连接..."
            MSG_SSH_DONE="✅ SSH ControlMaster 已设置（延迟 200ms → 10ms）"
            MSG_SSH_EXISTS="✅ SSH ControlMaster 已存在"
            MSG_COMPLETE="✅ 安装完成！"
            MSG_NEXT_STEPS="接下来请手动完成以下步骤："
            MSG_STEP1="1️⃣  打开 Hammerspoon"
            MSG_STEP2="2️⃣  授权辅助使用权限"
            MSG_STEP2_DESC="    系统设置 → 隐私与安全性 → 辅助功能"
            MSG_STEP2_DESC2="    允许 Hammerspoon"
            MSG_STEP3="3️⃣  设置 SSH 免密码登录（每台远程主机）"
            MSG_STEP4="4️⃣  远程授权辅助使用（每台远程主机）"
            MSG_STEP4_DESC="    系统偏好设置 → 安全性与隐私 → 辅助功能"
            MSG_STEP4_DESC2="    添加 /usr/bin/osascript"
            MSG_STEP5="5️⃣  开始使用！"
            MSG_STEP5_DESC="    打开屏幕共享 → 点击窗口 → 切换输入法"
            MSG_STEP5_DESC2="    第一次会询问 SSH 设置，之后自动记住"
            MSG_OPEN_HS="是否立即打开 Hammerspoon？(y/n) "
            MSG_REMINDER="🔔 请记得到「系统设置 → 隐私与安全性 → 辅助功能」允许 Hammerspoon"
            MSG_FOUND_EXISTING="⚠️  发现已存在的 init.lua"
            MSG_OVERWRITE_PROMPT="是否覆盖为新版本？(y/n) "
            MSG_SKIP_DOWNLOAD="⏭️  跳过下载，保留现有设置"
        fi
        ;;
    ja)
        # 日本語
        MSG_TITLE="macOS 画面共有 入力ソース同期ツール"
        MSG_MACOS_ONLY="❌ このツールはmacOS専用です"
        MSG_NEED_BREW="❌ Homebrewが必要です。先にインストールしてください："
        MSG_BREW_FOUND="✅ Homebrewを検出しました"
        MSG_HS_INSTALLED="✅ Hammerspoonはインストール済みです"
        MSG_HS_INSTALLING="📦 Hammerspoonをインストール中..."
        MSG_HS_DONE="✅ Hammerspoonのインストール完了"
        MSG_CREATE_DIR="📁 設定ディレクトリを作成中..."
        MSG_BACKUP="📋 既存の設定をバックアップ中..."
        MSG_DOWNLOAD="⬇️  設定ファイルをダウンロード中..."
        MSG_SSH_SETUP="⚡ SSH ControlMasterを設定中..."
        MSG_SSH_DONE="✅ SSH ControlMasterを設定しました（遅延 200ms → 10ms）"
        MSG_SSH_EXISTS="✅ SSH ControlMasterは既に設定されています"
        MSG_COMPLETE="✅ インストール完了！"
        MSG_NEXT_STEPS="次の手順を手動で完了してください："
        MSG_STEP1="1️⃣  Hammerspoonを開く"
        MSG_STEP2="2️⃣  アクセシビリティ権限を付与"
        MSG_STEP2_DESC="    システム設定 → プライバシーとセキュリティ → アクセシビリティ"
        MSG_STEP2_DESC2="    Hammerspoonを許可"
        MSG_STEP3="3️⃣  SSHパスワードなしログインを設定（各リモートホスト）"
        MSG_STEP4="4️⃣  リモートでアクセシビリティ権限を付与（各リモートホスト）"
        MSG_STEP4_DESC="    システム環境設定 → セキュリティとプライバシー → アクセシビリティ"
        MSG_STEP4_DESC2="    /usr/bin/osascript を追加"
        MSG_STEP5="5️⃣  使用開始！"
        MSG_STEP5_DESC="    画面共有を開く → ウィンドウをクリック → 入力ソースを切替"
        MSG_STEP5_DESC2="    初回はSSH設定を確認、以降は自動記憶"
        MSG_OPEN_HS="今すぐHammerspoonを開きますか？(y/n) "
        MSG_REMINDER="🔔 「システム設定 → プライバシーとセキュリティ → アクセシビリティ」でHammerspoonを許可してください"
        MSG_FOUND_EXISTING="⚠️  既存の init.lua が見つかりました"
        MSG_OVERWRITE_PROMPT="新しいバージョンで上書きしますか？(y/n) "
        MSG_SKIP_DOWNLOAD="⏭️  ダウンロードをスキップ、既存の設定を保持"
        ;;
    ko)
        # 한국어
        MSG_TITLE="macOS 화면 공유 입력 소스 동기화 도구"
        MSG_MACOS_ONLY="❌ 이 도구는 macOS만 지원합니다"
        MSG_NEED_BREW="❌ Homebrew가 필요합니다. 먼저 설치하세요:"
        MSG_BREW_FOUND="✅ Homebrew 감지됨"
        MSG_HS_INSTALLED="✅ Hammerspoon이 이미 설치되어 있습니다"
        MSG_HS_INSTALLING="📦 Hammerspoon 설치 중..."
        MSG_HS_DONE="✅ Hammerspoon 설치 완료"
        MSG_CREATE_DIR="📁 설정 디렉토리 생성 중..."
        MSG_BACKUP="📋 기존 설정 백업 중..."
        MSG_DOWNLOAD="⬇️  설정 파일 다운로드 중..."
        MSG_SSH_SETUP="⚡ SSH ControlMaster 설정 중..."
        MSG_SSH_DONE="✅ SSH ControlMaster 설정됨 (지연 200ms → 10ms)"
        MSG_SSH_EXISTS="✅ SSH ControlMaster가 이미 존재합니다"
        MSG_COMPLETE="✅ 설치 완료!"
        MSG_NEXT_STEPS="다음 단계를 수동으로 완료하세요:"
        MSG_STEP1="1️⃣  Hammerspoon 열기"
        MSG_STEP2="2️⃣  손쉬운 사용 권한 부여"
        MSG_STEP2_DESC="    시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용"
        MSG_STEP2_DESC2="    Hammerspoon 허용"
        MSG_STEP3="3️⃣  SSH 비밀번호 없는 로그인 설정 (각 원격 호스트)"
        MSG_STEP4="4️⃣  원격에서 손쉬운 사용 권한 부여 (각 원격 호스트)"
        MSG_STEP4_DESC="    시스템 환경설정 → 보안 및 개인정보 → 손쉬운 사용"
        MSG_STEP4_DESC2="    /usr/bin/osascript 추가"
        MSG_STEP5="5️⃣  사용 시작!"
        MSG_STEP5_DESC="    화면 공유 열기 → 창 클릭 → 입력 소스 전환"
        MSG_STEP5_DESC2="    처음에는 SSH 설정을 묻고, 이후 자동 기억"
        MSG_OPEN_HS="지금 Hammerspoon을 열까요? (y/n) "
        MSG_REMINDER="🔔 「시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용」에서 Hammerspoon을 허용하세요"
        MSG_FOUND_EXISTING="⚠️  기존 init.lua 발견"
        MSG_OVERWRITE_PROMPT="새 버전으로 덮어쓰시겠습니까? (y/n) "
        MSG_SKIP_DOWNLOAD="⏭️  다운로드 건너뜀, 기존 설정 유지"
        ;;
    *)
        # English (default)
        MSG_TITLE="macOS Screen Sharing Input Sync"
        MSG_MACOS_ONLY="❌ This tool only supports macOS"
        MSG_NEED_BREW="❌ Homebrew is required. Please install it first:"
        MSG_BREW_FOUND="✅ Homebrew detected"
        MSG_HS_INSTALLED="✅ Hammerspoon is already installed"
        MSG_HS_INSTALLING="📦 Installing Hammerspoon..."
        MSG_HS_DONE="✅ Hammerspoon installation complete"
        MSG_CREATE_DIR="📁 Creating config directory..."
        MSG_BACKUP="📋 Backing up existing config..."
        MSG_DOWNLOAD="⬇️  Downloading config file..."
        MSG_SSH_SETUP="⚡ Setting up SSH ControlMaster..."
        MSG_SSH_DONE="✅ SSH ControlMaster configured (latency 200ms → 10ms)"
        MSG_SSH_EXISTS="✅ SSH ControlMaster already exists"
        MSG_COMPLETE="✅ Installation complete!"
        MSG_NEXT_STEPS="Please complete the following steps manually:"
        MSG_STEP1="1️⃣  Open Hammerspoon"
        MSG_STEP2="2️⃣  Grant Accessibility permission"
        MSG_STEP2_DESC="    System Settings → Privacy & Security → Accessibility"
        MSG_STEP2_DESC2="    Allow Hammerspoon"
        MSG_STEP3="3️⃣  Setup SSH passwordless login (for each remote host)"
        MSG_STEP4="4️⃣  Grant Accessibility on remote (for each remote host)"
        MSG_STEP4_DESC="    System Preferences → Security & Privacy → Accessibility"
        MSG_STEP4_DESC2="    Add /usr/bin/osascript"
        MSG_STEP5="5️⃣  Start using!"
        MSG_STEP5_DESC="    Open Screen Sharing → Click window → Switch input method"
        MSG_STEP5_DESC2="    First time will ask for SSH config, then auto-remembers"
        MSG_OPEN_HS="Open Hammerspoon now? (y/n) "
        MSG_REMINDER="🔔 Remember to allow Hammerspoon in System Settings → Privacy & Security → Accessibility"
        MSG_FOUND_EXISTING="⚠️  Found existing init.lua"
        MSG_OVERWRITE_PROMPT="Overwrite with new version? (y/n) "
        MSG_SKIP_DOWNLOAD="⏭️  Skipped download, keeping existing config"
        ;;
esac

echo ""
echo "=========================================="
echo "  $MSG_TITLE"
echo "=========================================="
echo ""

# Check if macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "$MSG_MACOS_ONLY"
    exit 1
fi

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo "$MSG_NEED_BREW"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "$MSG_BREW_FOUND"

# Install Hammerspoon
if [ -d "/Applications/Hammerspoon.app" ]; then
    echo "$MSG_HS_INSTALLED"
else
    echo "$MSG_HS_INSTALLING"
    brew install --cask hammerspoon
    echo "$MSG_HS_DONE"
fi

# Create config directory
echo "$MSG_CREATE_DIR"
mkdir -p ~/.hammerspoon

# Check existing config and ask user
if [ -f ~/.hammerspoon/init.lua ]; then
    echo "$MSG_FOUND_EXISTING"
    read -p "$MSG_OVERWRITE_PROMPT" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$MSG_BACKUP"
        cp ~/.hammerspoon/init.lua ~/.hammerspoon/init.lua.backup.$(date +%Y%m%d%H%M%S)
        echo "$MSG_DOWNLOAD"
        curl -fsSL -o ~/.hammerspoon/init.lua https://raw.githubusercontent.com/taigadit/mac-screen-sharing-input-sync/main/init.lua
    else
        echo "$MSG_SKIP_DOWNLOAD"
    fi
else
    # Download config
    echo "$MSG_DOWNLOAD"
    curl -fsSL -o ~/.hammerspoon/init.lua https://raw.githubusercontent.com/taigadit/mac-screen-sharing-input-sync/main/init.lua
fi

# Setup SSH ControlMaster
echo ""
echo "$MSG_SSH_SETUP"
mkdir -p ~/.ssh/sockets

if ! grep -q "ControlMaster" ~/.ssh/config 2>/dev/null; then
    touch ~/.ssh/config
    cat >> ~/.ssh/config << 'SSHCONFIG'

# SSH ControlMaster - Screen Sharing Input Sync acceleration
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
SSHCONFIG
    chmod 600 ~/.ssh/config
    echo "$MSG_SSH_DONE"
else
    echo "$MSG_SSH_EXISTS"
fi

echo ""
echo "=========================================="
echo "  $MSG_COMPLETE"
echo "=========================================="
echo ""
echo "$MSG_NEXT_STEPS"
echo ""
echo "$MSG_STEP1"
echo "    open -a Hammerspoon"
echo ""
echo "$MSG_STEP2"
echo "$MSG_STEP2_DESC"
echo "$MSG_STEP2_DESC2"
echo ""
echo "$MSG_STEP3"
echo "    ssh-keygen -t ed25519"
echo "    ssh-copy-id user@remote-IP"
echo ""
echo "$MSG_STEP4"
echo "$MSG_STEP4_DESC"
echo "$MSG_STEP4_DESC2"
echo ""
echo "$MSG_STEP5"
echo "$MSG_STEP5_DESC"
echo "$MSG_STEP5_DESC2"
echo ""
echo "=========================================="
echo ""

# Ask to open Hammerspoon
read -p "$MSG_OPEN_HS" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open -a Hammerspoon
    echo ""
    echo "$MSG_REMINDER"
fi
