--[[
  macOS Screen Sharing Input Method Sync
  macOS 螢幕共享輸入法同步工具
  macOS 屏幕共享输入法同步工具
  macOS 画面共有入力同期ツール
  macOS 화면 공유 입력기 동기화 도구
  
  Version: 1.0
  Date: 2025.1.11
  
  Copyright (c) 2025 Dajiade Co., Ltd.
  https://www.dajiade.com
  
  Licensed under MIT License
  
  GitHub: https://github.com/taigadit/mac-screen-sharing-input-sync
]]

--------------------------------------------------------------------------------
-- 設定區
--------------------------------------------------------------------------------

-- 版本資訊
local VERSION = "1.0"
local VERSION_DATE = "2025.1.11"
local COPYRIGHT = "© 2025 Dajiade Co., Ltd."
local WEBSITE = "https://www.dajiade.com"
local LICENSE = "MIT License"

local sshCmd = "/usr/bin/ssh"
local lastTrigger = 0
local cooldown = 0.1
local lastLocalInput = nil
local menubar = nil
local enabled = true  -- 同步開關

-- macism 路徑
local macismPaths = {
    "/opt/homebrew/bin/macism",  -- Apple Silicon
    "/usr/local/bin/macism"       -- Intel
}

-- 主機對應表：{ ["主機名"] = { ssh = "user@ip", mode = "toggle" 或 "macism" } }
local hostMap = {}

-- 設定檔路徑
local configDir = os.getenv("HOME") .. "/.hammerspoon"
local hostMapFile = configDir .. "/hostmap.lua"
local langFile = configDir .. "/sync_lang.txt"

-- 多語系支援：螢幕共享 App 名稱
local screenSharingNames = {
    "螢幕共享",           -- 繁體中文
    "屏幕共享",           -- 簡體中文
    "Screen Sharing",    -- English
    "画面共有",           -- 日本語
    "화면 공유",          -- 한국어
    "Partage d'écran",   -- Français
    "Bildschirmfreigabe", -- Deutsch
    "Compartir pantalla", -- Español
    "Condivisione Schermo", -- Italiano
}

-- 多語系支援：「所有連線」視窗標題
local allConnectionsTitles = {
    "所有連線",           -- 繁體中文
    "所有连接",           -- 簡體中文
    "All Connections",   -- English
    "すべての接続",       -- 日本語
    "모든 연결",          -- 한국어
    "Toutes les connexions", -- Français
    "Alle Verbindungen", -- Deutsch
    "Todas las conexiones", -- Español
    "Tutte le connessioni", -- Italiano
}

-- UI 文字（多國語言）
local i18n = {
    ["zh-Hant"] = {
        hostList = "📋 主機列表",
        noHosts = "（尚無主機）",
        addHost = "➕ 新增主機",
        reload = "🔄 重新載入",
        reloaded = "已重新載入",
        editSsh = "✏️ 編輯 SSH",
        delete = "🗑️ 刪除",
        added = "已新增",
        updated = "已更新",
        deleted = "已刪除",
        saved = "已儲存",
        addHostTitle = "新增主機",
        addHostMsg = "輸入主機名稱（螢幕共享視窗標題）:",
        addHostSshMsg = "輸入 SSH 連線資訊:",
        editHostTitle = "編輯主機",
        deleteHostTitle = "刪除主機",
        deleteHostMsg = "確定要刪除嗎？",
        notFoundTitle = "找不到主機對應",
        notFoundMsg = "請輸入 SSH 連線資訊\n格式：user@ip",
        selectModeTitle = "選擇同步模式",
        selectModeDesc = "Toggle：送 Ctrl+Space（簡單，但只能切換）\nmacism：精確同步（遠端需裝 macism）",
        next = "下一步",
        save = "儲存",
        cancel = "取消",
        delete_btn = "刪除",
        useToggle = "Toggle（Ctrl+Space）",
        useMacism = "macism（精確同步）",
        switchToToggle = "🔄 切換為 Toggle",
        switchToMacism = "🎯 切換為 macism",
        syncing = "同步中",
        paused = "已暫停",
        pauseSync = "⏸️ 暫停同步",
        resumeSync = "▶️ 開始同步",
        syncEnabled = "同步已開啟",
        syncDisabled = "同步已暫停",
        loaded = "螢幕共享輸入法同步工具已載入",
        mode = "模式：SSH（搭配 ControlMaster 更快）",
        clickMenubar = "點選單列 ⌨️ 圖示管理設定",
    },
    ["zh-Hans"] = {
        hostList = "📋 主机列表",
        noHosts = "（暂无主机）",
        addHost = "➕ 新增主机",
        reload = "🔄 重新加载",
        reloaded = "已重新加载",
        editSsh = "✏️ 编辑 SSH",
        delete = "🗑️ 删除",
        added = "已新增",
        updated = "已更新",
        deleted = "已删除",
        saved = "已保存",
        addHostTitle = "新增主机",
        addHostMsg = "输入主机名称（屏幕共享窗口标题）:",
        addHostSshMsg = "输入 SSH 连接信息:",
        editHostTitle = "编辑主机",
        deleteHostTitle = "删除主机",
        deleteHostMsg = "确定要删除吗？",
        notFoundTitle = "找不到主机对应",
        notFoundMsg = "请输入 SSH 连接信息\n格式：user@ip",
        selectModeTitle = "选择同步模式",
        selectModeDesc = "Toggle：发送 Ctrl+Space（简单，但只能切换）\nmacism：精确同步（远端需装 macism）",
        next = "下一步",
        save = "保存",
        cancel = "取消",
        delete_btn = "删除",
        useToggle = "Toggle（Ctrl+Space）",
        useMacism = "macism（精确同步）",
        switchToToggle = "🔄 切换为 Toggle",
        switchToMacism = "🎯 切换为 macism",
        syncing = "同步中",
        paused = "已暂停",
        pauseSync = "⏸️ 暂停同步",
        resumeSync = "▶️ 开始同步",
        syncEnabled = "同步已开启",
        syncDisabled = "同步已暂停",
        loaded = "屏幕共享输入法同步工具已加载",
        mode = "模式：SSH（搭配 ControlMaster 更快）",
        clickMenubar = "点击菜单栏 ⌨️ 图标管理设置",
    },
    ["en"] = {
        hostList = "📋 Host List",
        noHosts = "(No hosts)",
        addHost = "➕ Add Host",
        reload = "🔄 Reload",
        reloaded = "Reloaded",
        editSsh = "✏️ Edit SSH",
        delete = "🗑️ Delete",
        added = "Added",
        updated = "Updated",
        deleted = "Deleted",
        saved = "Saved",
        addHostTitle = "Add Host",
        addHostMsg = "Enter host name (Screen Sharing window title):",
        addHostSshMsg = "Enter SSH connection info:",
        editHostTitle = "Edit Host",
        deleteHostTitle = "Delete Host",
        deleteHostMsg = "Are you sure you want to delete?",
        notFoundTitle = "Host Not Found",
        notFoundMsg = "Please enter SSH connection info\nFormat: user@ip",
        selectModeTitle = "Select Sync Mode",
        selectModeDesc = "Toggle: Send Ctrl+Space (simple, but only toggles)\nmacism: Exact sync (requires macism on remote)",
        next = "Next",
        save = "Save",
        cancel = "Cancel",
        delete_btn = "Delete",
        useToggle = "Toggle (Ctrl+Space)",
        useMacism = "macism (Exact Sync)",
        switchToToggle = "🔄 Switch to Toggle",
        switchToMacism = "🎯 Switch to macism",
        syncing = "Syncing",
        paused = "Paused",
        pauseSync = "⏸️ Pause Sync",
        resumeSync = "▶️ Resume Sync",
        syncEnabled = "Sync enabled",
        syncDisabled = "Sync paused",
        loaded = "Screen Sharing Input Sync loaded",
        mode = "Mode: SSH (faster with ControlMaster)",
        clickMenubar = "Click menubar ⌨️ icon to manage settings",
    },
    ["ja"] = {
        hostList = "📋 ホスト一覧",
        noHosts = "（ホストなし）",
        addHost = "➕ ホスト追加",
        reload = "🔄 再読み込み",
        reloaded = "再読み込み完了",
        editSsh = "✏️ SSH編集",
        delete = "🗑️ 削除",
        added = "追加しました",
        updated = "更新しました",
        deleted = "削除しました",
        saved = "保存しました",
        addHostTitle = "ホスト追加",
        addHostMsg = "ホスト名を入力（画面共有ウィンドウのタイトル）:",
        addHostSshMsg = "SSH接続情報を入力:",
        editHostTitle = "ホスト編集",
        deleteHostTitle = "ホスト削除",
        deleteHostMsg = "本当に削除しますか？",
        notFoundTitle = "ホストが見つかりません",
        notFoundMsg = "SSH接続情報を入力してください\n形式: user@ip",
        selectModeTitle = "同期モードを選択",
        selectModeDesc = "Toggle：Ctrl+Spaceを送信（シンプル、切り替えのみ）\nmacism：正確な同期（リモートにmacismが必要）",
        next = "次へ",
        save = "保存",
        cancel = "キャンセル",
        delete_btn = "削除",
        useToggle = "Toggle（Ctrl+Space）",
        useMacism = "macism（正確な同期）",
        switchToToggle = "🔄 Toggleに切替",
        switchToMacism = "🎯 macismに切替",
        syncing = "同期中",
        paused = "一時停止",
        pauseSync = "⏸️ 同期を一時停止",
        resumeSync = "▶️ 同期を再開",
        syncEnabled = "同期が有効になりました",
        syncDisabled = "同期が一時停止されました",
        loaded = "画面共有入力同期ツールが読み込まれました",
        mode = "モード：SSH（ControlMaster使用で高速化）",
        clickMenubar = "メニューバーの ⌨️ をクリックして設定",
    },
    ["ko"] = {
        hostList = "📋 호스트 목록",
        noHosts = "（호스트 없음）",
        addHost = "➕ 호스트 추가",
        reload = "🔄 새로고침",
        reloaded = "새로고침됨",
        editSsh = "✏️ SSH 편집",
        delete = "🗑️ 삭제",
        added = "추가됨",
        updated = "업데이트됨",
        deleted = "삭제됨",
        saved = "저장됨",
        addHostTitle = "호스트 추가",
        addHostMsg = "호스트 이름 입력 (화면 공유 창 제목):",
        addHostSshMsg = "SSH 연결 정보 입력:",
        editHostTitle = "호스트 편집",
        deleteHostTitle = "호스트 삭제",
        deleteHostMsg = "정말 삭제하시겠습니까?",
        notFoundTitle = "호스트를 찾을 수 없음",
        notFoundMsg = "SSH 연결 정보를 입력하세요\n형식: user@ip",
        selectModeTitle = "동기화 모드 선택",
        selectModeDesc = "Toggle: Ctrl+Space 전송 (간단, 토글만 가능)\nmacism: 정확한 동기화 (원격에 macism 필요)",
        next = "다음",
        save = "저장",
        cancel = "취소",
        delete_btn = "삭제",
        useToggle = "Toggle (Ctrl+Space)",
        useMacism = "macism (정확한 동기화)",
        switchToToggle = "🔄 Toggle로 전환",
        switchToMacism = "🎯 macism으로 전환",
        syncing = "동기화 중",
        paused = "일시정지",
        pauseSync = "⏸️ 동기화 일시정지",
        resumeSync = "▶️ 동기화 재개",
        syncEnabled = "동기화 활성화됨",
        syncDisabled = "동기화 일시정지됨",
        loaded = "화면 공유 입력 동기화 도구 로드됨",
        mode = "모드: SSH (ControlMaster로 더 빠르게)",
        clickMenubar = "메뉴바 ⌨️ 아이콘을 클릭하여 설정",
    },
}

-- 偵測系統語言
local function detectSystemLanguage()
    -- 優先使用偏好語言
    local langs = hs.host.locale.preferredLanguages() or {}
    local lang = langs[1] or ""
    local locale = hs.host.locale.current() or ""
    
    -- 檢查繁體中文（支援 zh-Hant, zh-Hant-TW, zh-TW, zh_Hant, zh_TW 等格式）
    if lang:find("zh%-Hant") or lang:find("zh%-TW") or lang:find("zh%-HK")
       or locale:find("zh_Hant") or locale:find("zh_TW") or locale:find("zh_HK") then
        return "zh-Hant"
    -- 檢查簡體中文
    elseif lang:find("zh%-Hans") or lang:find("zh%-CN")
       or locale:find("zh_Hans") or locale:find("zh_CN") then
        return "zh-Hans"
    -- 檢查日文
    elseif lang:find("^ja") or locale:find("ja") then
        return "ja"
    -- 檢查韓文
    elseif lang:find("^ko") or locale:find("ko") then
        return "ko"
    else
        return "en"
    end
end

-- 讀取使用者語言設定
local function loadLanguage()
    local f = io.open(langFile, "r")
    if f then
        local lang = f:read("*l")
        f:close()
        if lang and i18n[lang] then
            return lang
        end
    end
    return detectSystemLanguage()
end

-- 儲存使用者語言設定
local function saveLanguage(lang)
    local f = io.open(langFile, "w")
    if f then
        f:write(lang)
        f:close()
    end
end

-- 語言名稱對應
local langNames = {
    ["zh-Hant"] = "繁體中文",
    ["zh-Hans"] = "简体中文",
    ["en"] = "English",
    ["ja"] = "日本語",
    ["ko"] = "한국어",
}

local currentLang = loadLanguage()
local texts = i18n[currentLang] or i18n["en"]

-- 語言切換函數（使用前向宣告）
local switchLanguage

-- 顯示關於對話框
local function showAbout()
    local aboutText = [[
macOS Screen Sharing Input Method Sync

Version ]] .. VERSION .. [[ (]] .. VERSION_DATE .. [[)

]] .. COPYRIGHT .. [[
https://www.dajiade.com

]] .. LICENSE .. [[

]]
    
    hs.dialog.blockAlert(
        "About / 關於",
        aboutText,
        "OK"
    )
end

--------------------------------------------------------------------------------
-- 工具函數
--------------------------------------------------------------------------------

-- 找到 macism 路徑
local function findMacism()
    for _, path in ipairs(macismPaths) do
        local f = io.open(path, "r")
        if f then
            f:close()
            return path
        end
    end
    return macismPaths[1]
end

local macismPath = findMacism()

-- 找螢幕共享 App
local function findScreenSharingApp()
    for _, name in ipairs(screenSharingNames) do
        local app = hs.application.find(name)
        if app then return app end
    end
    return nil
end

-- 檢查是否為「所有連線」視窗
local function isAllConnectionsWindow(title)
    for _, t in ipairs(allConnectionsTitles) do
        if title == t then return true end
    end
    return false
end

-- 取得目前 focus 的螢幕共享視窗
local function getFocusedScreenSharingWindow()
    local focusedWindow = hs.window.focusedWindow()
    if not focusedWindow then return nil end
    
    local app = focusedWindow:application()
    if not app then return nil end
    
    local appName = app:name()
    
    -- 檢查是否是螢幕共享 App
    local isScreenSharing = false
    for _, name in ipairs(screenSharingNames) do
        if appName == name then
            isScreenSharing = true
            break
        end
    end
    
    if not isScreenSharing then return nil end
    
    -- 檢查是否是連線視窗（不是「所有連線」）
    local title = focusedWindow:title()
    if isAllConnectionsWindow(title) or title == "" then
        return nil
    end
    
    return focusedWindow
end

-- 取得模式圖示
local function getModeIcon(mode)
    return mode == "macism" and "🎯" or "🔄"
end

--------------------------------------------------------------------------------
-- 設定檔管理
--------------------------------------------------------------------------------

local function saveHostMap()
    local file = io.open(hostMapFile, "w")
    if file then
        file:write("return {\n")
        for name, config in pairs(hostMap) do
            file:write(string.format('    [%q] = { ssh = %q, mode = %q },\n', 
                name, config.ssh, config.mode or "toggle"))
        end
        file:write("}\n")
        file:close()
    end
end

local function loadHostMap()
    local f = io.open(hostMapFile, "r")
    if f then
        f:close()
        local ok, loaded = pcall(dofile, hostMapFile)
        if ok and loaded then
            -- 相容舊格式
            for name, value in pairs(loaded) do
                if type(value) == "string" then
                    hostMap[name] = { ssh = value, mode = "toggle" }
                else
                    hostMap[name] = value
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- UI 功能
--------------------------------------------------------------------------------

local function selectMode(callback)
    local btn = hs.dialog.blockAlert(
        texts.selectModeTitle,
        texts.selectModeDesc,
        texts.useToggle, texts.useMacism, texts.cancel
    )
    if btn == texts.useToggle then
        callback("toggle")
    elseif btn == texts.useMacism then
        callback("macism")
    end
end

local function addHost()
    local btn1, name = hs.dialog.textPrompt(
        texts.addHostTitle,
        texts.addHostMsg,
        "",
        texts.next, texts.cancel
    )
    if btn1 ~= texts.next or name == "" then return end
    
    local btn2, ssh = hs.dialog.textPrompt(
        texts.addHostTitle,
        texts.addHostSshMsg,
        "user@192.168.1.",
        texts.next, texts.cancel
    )
    if btn2 ~= texts.next or ssh == "" then return end
    
    selectMode(function(mode)
        hostMap[name] = { ssh = ssh, mode = mode }
        saveHostMap()
        updateMenu()
        hs.alert.show(texts.added .. ": " .. name .. " " .. getModeIcon(mode))
    end)
end

local function editHostSsh(name)
    local config = hostMap[name]
    local btn, ssh = hs.dialog.textPrompt(
        texts.editHostTitle,
        "「" .. name .. "」",
        config.ssh,
        texts.save, texts.cancel
    )
    if btn == texts.save and ssh ~= "" then
        hostMap[name].ssh = ssh
        saveHostMap()
        updateMenu()
        hs.alert.show(texts.updated .. ": " .. name)
    end
end

local function switchMode(name)
    local config = hostMap[name]
    local newMode = config.mode == "macism" and "toggle" or "macism"
    hostMap[name].mode = newMode
    saveHostMap()
    updateMenu()
    hs.alert.show(name .. " → " .. getModeIcon(newMode) .. " " .. newMode)
end

local function deleteHost(name)
    local btn = hs.dialog.blockAlert(
        texts.deleteHostTitle,
        "「" .. name .. "」\n" .. texts.deleteHostMsg,
        texts.delete_btn, texts.cancel
    )
    if btn == texts.delete_btn then
        hostMap[name] = nil
        saveHostMap()
        updateMenu()
        hs.alert.show(texts.deleted .. ": " .. name)
    end
end

function updateMenu()
    local statusIcon = enabled and "✅" or "⏸️"
    local statusText = enabled and texts.syncing or texts.paused
    local toggleText = enabled and texts.pauseSync or texts.resumeSync
    
    local menuItems = {
        { title = statusIcon .. " " .. statusText, disabled = true },
        { title = toggleText, fn = function()
            enabled = not enabled
            updateMenu()
            hs.alert.show(enabled and texts.syncEnabled or texts.syncDisabled)
        end },
        { title = "-" },
        { title = texts.hostList, disabled = true },
    }
    
    -- 主機列表
    if next(hostMap) == nil then
        table.insert(menuItems, { title = texts.noHosts, disabled = true })
    else
        for name, config in pairs(hostMap) do
            local modeIcon = getModeIcon(config.mode)
            local switchText = config.mode == "macism" and texts.switchToToggle or texts.switchToMacism
            
            table.insert(menuItems, {
                title = modeIcon .. " " .. name .. " → " .. config.ssh,
                menu = {
                    { title = switchText, fn = function() switchMode(name) end },
                    { title = "-" },
                    { title = texts.editSsh, fn = function() editHostSsh(name) end },
                    { title = texts.delete, fn = function() deleteHost(name) end }
                }
            })
        end
    end
    
    table.insert(menuItems, { title = "-" })
    table.insert(menuItems, { title = texts.addHost, fn = addHost })
    table.insert(menuItems, { title = "-" })
    table.insert(menuItems, {
        title = texts.reload,
        fn = function()
            loadHostMap()
            updateMenu()
            hs.alert.show(texts.reloaded)
        end
    })
    
    -- 語言切換子選單
    local langMenu = {}
    for langCode, langName in pairs(langNames) do
        local check = (langCode == currentLang) and "✓ " or "   "
        table.insert(langMenu, {
            title = check .. langName,
            fn = function() switchLanguage(langCode) end
        })
    end
    table.insert(menuItems, { title = "-" })
    table.insert(menuItems, { title = "🌐 Language / 語言", menu = langMenu })
    table.insert(menuItems, { title = "-" })
    table.insert(menuItems, { title = "ℹ️ About / 關於", fn = showAbout })
    
    menubar:setMenu(menuItems)
    menubar:setTitle(enabled and "⌨️" or "⌨️💤")
end

-- 切換語言（賦值給前向宣告的變數）
switchLanguage = function(lang)
    currentLang = lang
    texts = i18n[lang] or i18n["en"]
    saveLanguage(lang)
    updateMenu()
    hs.alert.show(langNames[lang])
end

local function askForHost(hostName)
    local button, ssh = hs.dialog.textPrompt(
        texts.notFoundTitle,
        "「" .. hostName .. "」\n" .. texts.notFoundMsg,
        "user@192.168.1.",
        texts.next, texts.cancel
    )
    
    if button == texts.next and ssh ~= "" then
        selectMode(function(mode)
            hostMap[hostName] = { ssh = ssh, mode = mode }
            saveHostMap()
            updateMenu()
            hs.alert.show(texts.saved .. ": " .. hostName .. " " .. getModeIcon(mode))
        end)
        return hostMap[hostName]
    end
    return nil
end

--------------------------------------------------------------------------------
-- 輸入法同步
--------------------------------------------------------------------------------

hs.keycodes.inputSourceChanged(function()
    -- 檢查是否啟用
    if not enabled then return end
    
    -- 取得目前輸入法
    local current = hs.keycodes.currentSourceID()
    
    -- 跟上次一樣就跳過
    if current == lastLocalInput then return end
    lastLocalInput = current
    
    -- 只在螢幕共享視窗 focus 時才同步
    local focusedWindow = getFocusedScreenSharingWindow()
    if not focusedWindow then return end
    
    -- 從視窗標題取得主機名稱
    local title = focusedWindow:title()
    local hostName = title:match("^(.-)%s*–") or title
    
    -- 找對應的設定
    local hostConfig = hostMap[hostName]
    
    -- 找不到就詢問
    if not hostConfig then
        hostConfig = askForHost(hostName)
    end
    
    if not hostConfig then return end
    
    -- Toggle 模式需要防抖動
    if hostConfig.mode == "toggle" then
        local now = hs.timer.secondsSinceEpoch()
        if now - lastTrigger < cooldown then return end
        lastTrigger = now
    end
    
    -- 根據主機的同步模式執行
    local cmd
    if hostConfig.mode == "macism" then
        cmd = macismPath .. " " .. current
    else
        cmd = "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
    end
    
    hs.task.new(sshCmd, nil, {hostConfig.ssh, cmd}):start()
    print("同步 [" .. hostConfig.mode .. "] " .. hostName .. ": " .. current)
end)

--------------------------------------------------------------------------------
-- 初始化
--------------------------------------------------------------------------------

loadHostMap()
menubar = hs.menubar.new()
updateMenu()

print("===========================================")
print("  " .. texts.loaded)
print("  " .. texts.mode)
print("  " .. texts.clickMenubar)
print("===========================================")