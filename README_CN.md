# macOS 屏幕共享输入法同步工具

> **适用于：** Apple Mac、MacBook Air、MacBook Pro、Mac mini、iMac、Mac Studio、Mac Pro  
> **关键词：** macOS, 屏幕共享, 输入法, IME, VNC, Hammerspoon

解决 macOS 屏幕共享时，本机与远程输入法不同步的恼人问题。

## ⚠️ 先确认是否需要本工具

新版 macOS 屏幕共享已内置「同步键盘语言」功能。

请先检查：**屏幕共享 App → 设置**，看是否有此选项。

- ✅ **有这个选项** → 直接勾选即可，不需要本工具
- ❌ **找不到这个选项** → 你的 macOS 版本较旧，请使用本工具

**本工具适用于：**
- 本机或远程是旧版 macOS，没有内置同步功能
- 内置功能有问题时的备用方案

## 问题描述

使用 macOS 内置屏幕共享时，输入法会出现以下情况：

| 本机输入法 | 远程输入法 | 实际输出 |
|-----------|-----------|---------|
| 英文 | 拼音 | 英文 ❌ |
| 拼音 | 英文 | 拼音 ❌ |
| 拼音 | 拼音 | 拼音 ✅ |

这是因为屏幕共享传送的是「本机输入法处理过的字符」，而不是原始按键。

## 功能特色

- ✅ **精确同步** — macism 模式直接指定输入法，不会对不齐
- ✅ **每台主机独立设置** — 可选 toggle 或 macism 模式
- ✅ **SSH ControlMaster 加速** — 延迟只有 10-50ms
- ✅ **只在屏幕共享 focus 时触发** — 不影响其他工作
- ✅ **自动询问新主机** — 第一次连接时设置，之后自动记住
- ✅ **菜单栏管理** — 暂停/恢复、新增/编辑/删除主机

## 同步模式

| 模式 | 图标 | 说明 | 远程需求 |
|-----|------|------|---------|
| **Toggle** | 🔄 | 发送 Ctrl+Space 切换 | 只需 SSH + 授权 |
| **macism** | 🎯 | 直接指定输入法 ID，精确同步 | SSH + macism（需 macOS 10.15+） |

**注意：** macism 需要 macOS 10.15 (Catalina) 以上才能安装。旧版请用 Toggle 模式。

## 系统需求

**本机（控制端）：**
- macOS 10.15 或更新版本
- Homebrew
- Hammerspoon

**远程（被控端）：**
- macOS 10.14 或更新版本
- 开启 SSH（远程登录）
- 授权辅助功能权限

---

## 安装步骤

### 步骤一：远程设置（在被控的 Mac 上操作）

#### 1. 开启 SSH（远程登录）

```
系统偏好设置 → 共享 → 勾选「远程登录」
```

记下显示的连接信息，例如 `ssh user@192.168.1.100`

#### 2. 授权辅助功能权限

SSH 执行 AppleScript 需要辅助功能权限：

```
系统偏好设置 → 安全性与隐私 → 隐私 → 辅助功能
```

1. 点左下角 🔒 解锁
2. 点「+」新增 `/usr/bin/osascript`
   - 按 `Cmd+Shift+G` 输入路径 `/usr/bin/`
   - 选择 `osascript`

或者新增「终端」App（/Applications/Utilities/Terminal.app）也可以。

#### 3. 测试辅助功能权限

在远程 Mac 上直接执行：

```bash
osascript -e 'tell application "System Events" to key code 49 using control down'
```

如果输入法有切换，表示权限设置成功。

---

### 步骤二：本机设置（在控制端 Mac 上操作）

#### 1. 安装 Hammerspoon

```bash
brew install --cask hammerspoon
```

#### 2. 下载配置文件

```bash
mkdir -p ~/.hammerspoon
curl -o ~/.hammerspoon/init.lua https://raw.githubusercontent.com/taigadit/mac-screen-sharing-input-sync/main/init.lua
```

#### 3. 设置 Hammerspoon 权限

1. 打开 Hammerspoon
2. 到「系统设置 → 隐私与安全性 → 辅助功能」
3. 允许 Hammerspoon

#### 4. 设置 SSH 免密码登录

```bash
# 生成密钥（如果还没有）
ssh-keygen -t ed25519

# 复制到远程主机（需输入远程密码一次）
ssh-copy-id user@远程IP
```

验证免密码登录：

```bash
ssh user@远程IP "echo ok"
```

如果直接显示 `ok` 不用输入密码，就成功了。

#### 5. 测试远程切换输入法

```bash
ssh user@远程IP "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
```

如果远程输入法有切换，表示一切正常！

#### 6. 设置 SSH ControlMaster 加速（建议）

```bash
mkdir -p ~/.ssh/sockets
```

编辑 `~/.ssh/config`，加入：

```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
```

设置权限：

```bash
chmod 600 ~/.ssh/config
```

这可以把延迟从 200-500ms 降到 10-50ms。

#### 7. 加载 Hammerspoon 配置

点菜单栏 Hammerspoon 图标（🔨）→ Reload Config

---

### 步骤三（可选）：远程安装 macism

如果远程是 macOS 10.15+ 且想要精确同步：

```bash
ssh user@远程IP
brew tap laishulu/homebrew
brew install macism
```

**注意：** macOS 10.14 (Mojave) 无法安装 macism，请用 Toggle 模式。

---

## 使用方式

1. **打开屏幕共享**连接到远程 Mac
2. **点击屏幕共享窗口**（让它获得焦点）
3. **切换本机输入法**
4. 远程会自动同步！

### 第一次连接

第一次会弹出对话框：
1. 输入 SSH 连接信息（例如 `user@192.168.1.100`）
2. 选择同步模式（Toggle 或 macism）
3. 设置会自动保存，下次不用再输入

### Toggle 模式注意事项

Toggle 模式是用 Ctrl+Space 切换，只能来回 toggle。

**重要：** 使用前请先手动对齐两边输入法（都切到英文或都切到拼音），之后就会保持同步。

### 菜单栏控制

菜单栏会出现 ⌨️ 图标，点开可以：
- ✅ 查看同步状态
- ⏸️ 暂停/恢复同步
- 📋 管理主机列表
- ➕ 新增主机
- 🔄/🎯 切换同步模式

---

## 配置文件位置

- 主程序：`~/.hammerspoon/init.lua`
- 主机对应表：`~/.hammerspoon/hostmap.lua`

主机对应表格式：

```lua
return {
    ["Akane的Mac mini"] = { ssh = "user@192.168.100.4", mode = "macism" },
    ["办公室 iMac"] = { ssh = "user@192.168.1.100", mode = "toggle" },
}
```

---

## 常见问题

### Q: 远程没有反应？

1. 确认 SSH 免密码登录正常：
   ```bash
   ssh user@远程IP "echo ok"
   ```

2. 确认远程已授权辅助功能：
   ```bash
   ssh user@远程IP "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
   ```
   
   如果出现权限错误，请到远程的「系统偏好设置 → 安全性与隐私 → 辅助功能」新增 `osascript`。

3. 确认屏幕共享窗口是获得焦点的（点进去）

### Q: 输入法对不齐？

- **macism 模式**：会直接指定输入法，不会对不齐
- **Toggle 模式**：使用前先手动对齐，之后就会同步

### Q: macism 安装失败？

macism 需要 macOS 10.15 (Catalina) 以上。如果远程是 Mojave (10.14)，只能用 Toggle 模式。

### Q: 延迟很长？

设置 SSH ControlMaster（见安装步骤），可以把延迟从 200-500ms 降到 10-50ms。

### Q: 如何暂时停用？

点菜单栏 ⌨️ 图标 → 暂停同步

### Q: 远程的输入法切换快捷键不是 Ctrl+Space？

编辑 `~/.hammerspoon/init.lua`，找到这行：

```lua
cmd = "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
```

修改 key code 和 modifier：
- `49` = Space
- `50` = 反引号 `` ` ``
- `control down` 可改成 `{control down, option down}` 等

---

## 原理说明

### 为什么屏幕共享会有这个问题？

macOS 屏幕共享的键盘事件处理流程：

```
按下按键 → 本机输入法处理 → 传送处理结果到远程
```

远程收到的已经是处理过的字符，远程的输入法根本没机会处理。

### 解决方案

让两边输入法保持同步：

```
本机切换输入法
      ↓
Hammerspoon 检测到
      ↓
SSH 到远程执行切换指令
      ↓
远程输入法同步
      ↓
两边一致 ✅
```

---

## 授权条款

MIT License

---

**Developed by [Dajiade Co., Ltd.](https://www.dajiade.com)** (taigadit)
