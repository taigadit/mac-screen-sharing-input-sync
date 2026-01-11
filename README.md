# macOS 螢幕共享輸入法同步工具

**🌐 Language / 語言：** [English](README_EN.md) | [日本語](README_JA.md) | [한국어](README_KO.md) | [简体中文](README_CN.md) | 繁體中文

> **適用於：** Apple Mac、MacBook Air、MacBook Pro、Mac mini、iMac、Mac Studio、Mac Pro  
> **Keywords:** macOS, Screen Sharing, Input Method, IME, VNC, Hammerspoon

解決 macOS 螢幕共享時，本機與遠端輸入法不同步的惱人問題。

## ⚠️ 先確認是否需要本工具

新版 macOS 螢幕共享已內建「同步鍵盤語言」功能。

請先檢查：**螢幕共享 App → 設定**，看是否有此選項。

- ✅ **有這個選項** → 直接勾選即可，不需要本工具
- ❌ **找不到這個選項** → 你的 macOS 版本較舊，請使用本工具

**本工具適用於：**
- 本機或遠端是舊版 macOS，沒有內建同步功能
- 內建功能有問題時的備案

## 問題描述

使用 macOS 內建螢幕共享時，輸入法會出現以下情況：

| 本機輸入法 | 遠端輸入法 | 實際輸出 |
|-----------|-----------|---------|
| 英文 | 注音 | 英文 ❌ |
| 注音 | 英文 | 注音 ❌ |
| 注音 | 注音 | 注音 ✅ |

這是因為螢幕共享傳送的是「本機輸入法處理過的字元」，而不是原始按鍵。

## 功能特色

- ✅ **精確同步** — macism 模式直接指定輸入法，不會對不齊
- ✅ **每台主機獨立設定** — 可選 toggle 或 macism 模式
- ✅ **SSH ControlMaster 加速** — 延遲只有 10-50ms
- ✅ **只在螢幕共享 focus 時觸發** — 不影響其他工作
- ✅ **自動詢問新主機** — 第一次連線時設定，之後自動記住
- ✅ **選單列管理** — 暫停/恢復、新增/編輯/刪除主機

## 同步模式

| 模式 | 圖示 | 說明 | 遠端需求 |
|-----|------|------|---------|
| **Toggle** | 🔄 | 送 Ctrl+Space 切換 | 只需 SSH + 授權 |
| **macism** | 🎯 | 直接指定輸入法 ID，精確同步 | SSH + macism（需 macOS 10.15+） |

**注意：** macism 需要 macOS 10.15 (Catalina) 以上才能安裝。舊版請用 Toggle 模式。

## 系統需求

**本機（控制端）：**
- macOS 10.15 或更新版本
- Homebrew
- Hammerspoon

**遠端（被控端）：**
- macOS 10.14 或更新版本
- 開啟 SSH（遠端登入）
- 授權輔助使用權限

---

## 安裝步驟

### 步驟一：遠端設定（在被控的 Mac 上操作）

#### 1. 開啟 SSH（遠端登入）

```
系統偏好設定 → 共享 → 勾選「遠端登入」
```

記下顯示的連線資訊，例如 `ssh user@192.168.1.100`

#### 2. 授權輔助使用權限

SSH 執行 AppleScript 需要輔助使用權限：

```
系統偏好設定 → 安全性與隱私 → 隱私 → 輔助使用
```

1. 點左下角 🔒 解鎖
2. 點「+」新增 `/usr/bin/osascript`
   - 按 `Cmd+Shift+G` 輸入路徑 `/usr/bin/`
   - 選擇 `osascript`

或者新增「終端機」App（/Applications/Utilities/Terminal.app）也可以。

#### 3. 測試輔助使用權限

在遠端 Mac 上直接執行：

```bash
osascript -e 'tell application "System Events" to key code 49 using control down'
```

如果輸入法有切換，表示權限設定成功。

---

### 步驟二：本機設定（在控制端 Mac 上操作）

#### 1. 安裝 Hammerspoon

```bash
brew install --cask hammerspoon
```

#### 2. 下載設定檔

```bash
mkdir -p ~/.hammerspoon
curl -o ~/.hammerspoon/init.lua https://raw.githubusercontent.com/taigadit/mac-screen-sharing-input-sync/main/init.lua
```

#### 3. 設定 Hammerspoon 權限

1. 打開 Hammerspoon
2. 到「系統設定 → 隱私權與安全性 → 輔助使用」
3. 允許 Hammerspoon

#### 4. 設定 SSH 免密碼登入

```bash
# 產生金鑰（如果還沒有）
ssh-keygen -t ed25519

# 複製到遠端主機（需輸入遠端密碼一次）
ssh-copy-id user@遠端IP
```

驗證免密碼登入：

```bash
ssh user@遠端IP "echo ok"
```

如果直接顯示 `ok` 不用輸入密碼，就成功了。

#### 5. 測試遠端切換輸入法

```bash
ssh user@遠端IP "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
```

如果遠端輸入法有切換，表示一切正常！

#### 6. 設定 SSH ControlMaster 加速（建議）

```bash
mkdir -p ~/.ssh/sockets
```

編輯 `~/.ssh/config`，加入：

```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
```

設定權限：

```bash
chmod 600 ~/.ssh/config
```

這可以把延遲從 200-500ms 降到 10-50ms。

#### 7. 載入 Hammerspoon 設定

點選單列 Hammerspoon 圖示（🔨）→ Reload Config

---

### 步驟三（可選）：遠端安裝 macism

如果遠端是 macOS 10.15+ 且想要精確同步：

```bash
ssh user@遠端IP
brew tap laishulu/homebrew
brew install macism
```

**注意：** macOS 10.14 (Mojave) 無法安裝 macism，請用 Toggle 模式。

---

## 使用方式

1. **開啟螢幕共享**連到遠端 Mac
2. **點進螢幕共享視窗**（讓它 focus）
3. **切換本機輸入法**
4. 遠端會自動同步！

### 第一次連線

第一次會跳出對話框：
1. 輸入 SSH 連線資訊（例如 `user@192.168.1.100`）
2. 選擇同步模式（Toggle 或 macism）
3. 設定會自動儲存，下次不用再輸入

### Toggle 模式注意事項

Toggle 模式是用 Ctrl+Space 切換，只能來回 toggle。

**重要：** 使用前請先手動對齊兩邊輸入法（都切到英文或都切到注音），之後就會保持同步。

### 選單列控制

選單列會出現 ⌨️ 圖示，點開可以：
- ✅ 查看同步狀態
- ⏸️ 暫停/恢復同步
- 📋 管理主機列表
- ➕ 新增主機
- 🔄/🎯 切換同步模式

---

## 設定檔位置

- 主程式：`~/.hammerspoon/init.lua`
- 主機對應表：`~/.hammerspoon/hostmap.lua`

主機對應表格式：

```lua
return {
    ["Akane的Mac mini"] = { ssh = "user@192.168.100.4", mode = "macism" },
    ["辦公室 iMac"] = { ssh = "user@192.168.1.100", mode = "toggle" },
}
```

---

## 常見問題

### Q: 遠端沒有反應？

1. 確認 SSH 免密碼登入正常：
   ```bash
   ssh user@遠端IP "echo ok"
   ```

2. 確認遠端已授權輔助使用：
   ```bash
   ssh user@遠端IP "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
   ```
   
   如果出現權限錯誤，請到遠端的「系統偏好設定 → 安全性與隱私 → 輔助使用」新增 `osascript`。

3. 確認螢幕共享視窗是 focus 的（點進去）

### Q: 輸入法對不齊？

- **macism 模式**：會直接指定輸入法，不會對不齊
- **Toggle 模式**：使用前先手動對齊，之後就會同步

### Q: macism 安裝失敗？

macism 需要 macOS 10.15 (Catalina) 以上。如果遠端是 Mojave (10.14)，只能用 Toggle 模式。

### Q: 延遲很長？

設定 SSH ControlMaster（見安裝步驟），可以把延遲從 200-500ms 降到 10-50ms。

### Q: 如何暫時停用？

點選單列 ⌨️ 圖示 → 暫停同步

### Q: 遠端的輸入法切換快捷鍵不是 Ctrl+Space？

編輯 `~/.hammerspoon/init.lua`，找到這行：

```lua
cmd = "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
```

修改 key code 和 modifier：
- `49` = Space
- `50` = 反引號 `` ` ``
- `control down` 可改成 `{control down, option down}` 等

---

## 原理說明

### 為什麼螢幕共享會有這個問題？

macOS 螢幕共享的鍵盤事件處理流程：

```
按下按鍵 → 本機輸入法處理 → 傳送處理結果到遠端
```

遠端收到的已經是處理過的字元，遠端的輸入法根本沒機會處理。

### 解決方案

讓兩邊輸入法保持同步：

```
本機切換輸入法
      ↓
Hammerspoon 偵測到
      ↓
SSH 到遠端執行切換指令
      ↓
遠端輸入法同步
      ↓
兩邊一致 ✅
```

---

## 授權條款

MIT License

---

**Developed by [Dajiade Co., Ltd.](https://www.dajiade.com)** (taigadit)
