# macOS Screen Sharing Input Method Sync

> **For:** Apple Mac, MacBook Air, MacBook Pro, Mac mini, iMac, Mac Studio, Mac Pro  
> **Keywords:** macOS, Screen Sharing, Input Method, IME, VNC, Hammerspoon

Sync input method between local and remote Mac when using Screen Sharing.

## ⚠️ Check if you need this tool

Newer macOS Screen Sharing has a built-in "Sync Keyboard Language" feature.

Please check: **Screen Sharing App → Settings**, see if this option exists.

- ✅ **Option exists** → Just enable it, no need for this tool
- ❌ **Option not found** → Your macOS version is older, please use this tool

**This tool is for:**
- Local or remote Mac running older macOS without built-in sync feature
- Backup solution when built-in feature has issues

## Problem

When using macOS built-in Screen Sharing, input method behaves like this:

| Local Input | Remote Input | Actual Output |
|-------------|--------------|---------------|
| English | Zhuyin | English ❌ |
| Zhuyin | English | Zhuyin ❌ |
| Zhuyin | Zhuyin | Zhuyin ✅ |

This happens because Screen Sharing sends "processed characters" instead of raw keystrokes.

## Features

- ✅ **Exact Sync** — macism mode directly specifies input method, never misaligned
- ✅ **Per-host Settings** — Choose toggle or macism mode for each host
- ✅ **SSH ControlMaster Acceleration** — Only 10-50ms latency
- ✅ **Focus-aware** — Only triggers when Screen Sharing window is focused
- ✅ **Auto-detect New Hosts** — Configure on first connection, remembered afterwards
- ✅ **Menubar Control** — Pause/resume, add/edit/delete hosts

## Sync Modes

| Mode | Icon | Description | Remote Requirement |
|------|------|-------------|-------------------|
| **Toggle** | 🔄 | Send Ctrl+Space to toggle | SSH + Accessibility permission |
| **macism** | 🎯 | Directly specify input method ID | SSH + macism (requires macOS 10.15+) |

**Note:** macism requires macOS 10.15 (Catalina) or later. Use Toggle mode for older versions.

## Requirements

**Local (Control Mac):**
- macOS 10.15 or later
- Homebrew
- Hammerspoon

**Remote (Controlled Mac):**
- macOS 10.14 or later
- SSH (Remote Login) enabled
- Accessibility permission granted

---

## Installation

### Step 1: Remote Setup (On the controlled Mac)

#### 1. Enable SSH (Remote Login)

```
System Preferences → Sharing → Check "Remote Login"
```

Note the connection info, e.g., `ssh user@192.168.1.100`

#### 2. Grant Accessibility Permission

SSH-executed AppleScript needs accessibility permission:

```
System Preferences → Security & Privacy → Privacy → Accessibility
```

1. Click 🔒 to unlock
2. Click "+" and add `/usr/bin/osascript`
   - Press `Cmd+Shift+G` and enter `/usr/bin/`
   - Select `osascript`

Or add "Terminal" app (/Applications/Utilities/Terminal.app).

#### 3. Test Accessibility Permission

Run this on the remote Mac:

```bash
osascript -e 'tell application "System Events" to key code 49 using control down'
```

If input method switches, permission is set correctly.

---

### Step 2: Local Setup (On the control Mac)

#### 1. Install Hammerspoon

```bash
brew install --cask hammerspoon
```

#### 2. Download Configuration

```bash
mkdir -p ~/.hammerspoon
curl -o ~/.hammerspoon/init.lua https://raw.githubusercontent.com/taigadit/mac-screen-sharing-input-sync/main/init.lua
```

#### 3. Grant Hammerspoon Permission

1. Open Hammerspoon
2. Go to "System Settings → Privacy & Security → Accessibility"
3. Allow Hammerspoon

#### 4. Setup SSH Passwordless Login

```bash
# Generate key (if not already done)
ssh-keygen -t ed25519

# Copy to remote (enter password once)
ssh-copy-id user@remote-IP
```

Verify passwordless login:

```bash
ssh user@remote-IP "echo ok"
```

If it shows `ok` without password prompt, it's working.

#### 5. Test Remote Input Switch

```bash
ssh user@remote-IP "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
```

If remote input method switches, everything is set up correctly!

#### 6. Setup SSH ControlMaster (Recommended)

```bash
mkdir -p ~/.ssh/sockets
```

Edit `~/.ssh/config`, add:

```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
```

Set permissions:

```bash
chmod 600 ~/.ssh/config
```

This reduces latency from 200-500ms to 10-50ms.

#### 7. Load Hammerspoon Config

Click Hammerspoon icon (🔨) in menubar → Reload Config

---

### Step 3 (Optional): Install macism on Remote

If remote is macOS 10.15+ and you want exact sync:

```bash
ssh user@remote-IP
brew tap laishulu/homebrew
brew install macism
```

**Note:** macOS 10.14 (Mojave) cannot install macism. Use Toggle mode instead.

---

## Usage

1. **Open Screen Sharing** and connect to remote Mac
2. **Click into the Screen Sharing window** (make it focused)
3. **Switch local input method**
4. Remote will sync automatically!

### First Connection

First time will show a dialog:
1. Enter SSH connection info (e.g., `user@192.168.1.100`)
2. Select sync mode (Toggle or macism)
3. Settings are saved automatically

### Toggle Mode Note

Toggle mode uses Ctrl+Space, which only toggles between inputs.

**Important:** Manually align both sides first (both English or both Zhuyin), then they'll stay synced.

### Menubar Control

⌨️ icon appears in menubar. Click to:
- ✅ View sync status
- ⏸️ Pause/resume sync
- 📋 Manage host list
- ➕ Add host
- 🔄/🎯 Switch sync mode

---

## FAQ

### Q: Remote not responding?

1. Check SSH passwordless login:
   ```bash
   ssh user@remote-IP "echo ok"
   ```

2. Check accessibility permission on remote:
   ```bash
   ssh user@remote-IP "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
   ```

3. Make sure Screen Sharing window is focused

### Q: Input methods misaligned?

- **macism mode**: Directly specifies input method, won't misalign
- **Toggle mode**: Manually align first, then they'll stay synced

### Q: macism installation failed?

macism requires macOS 10.15 (Catalina) or later. Use Toggle mode for Mojave (10.14).

### Q: High latency?

Setup SSH ControlMaster (see installation steps) to reduce latency from 200-500ms to 10-50ms.

---

## License

MIT License

---

**Developed by [Dajiade Co., Ltd.](https://www.dajiade.com)** (taigadit)
