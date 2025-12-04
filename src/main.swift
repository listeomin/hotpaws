import Cocoa
import WebKit
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    var window: NSWindow!
    var webView: WKWebView!
    var backgroundView: NSView!  // Чёрный фон с регулируемой прозрачностью
    var hotKeyRef: EventHotKeyRef?
    var statusItem: NSStatusItem!
    var toggleMenuItem: NSMenuItem!
    var scaleSlider: NSSlider!
    var scaleLabel: NSTextField!
    var opacitySlider: NSSlider!
    var opacityLabel: NSTextField!
    var currentScale: CGFloat = 1.0
    var currentOpacity: CGFloat = 0.3 // 30% по умолчанию (было ~90%, теперь в 3 раза меньше)
    var selectedTerminal: String = "terminal"
    var shouldExecuteCommand: Bool = true // true = исполнить, false = только отправить
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        ConfigManager.shared.setupConfigDirectory()
        loadSettings()
        checkAccessibilityOnce()
        setupStatusBar()
        setupWindow()
        setupWebView()
        loadHTML()
        registerHotKey()
        
        print("Hotpaws запущен. Нажми F19 для вызова оверлея.")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        unregisterHotKey()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // MARK: - Accessibility Check
    
    private func checkAccessibilityOnce() {
        if AXIsProcessTrusted() {
            print("✅ Accessibility: разрешение получено")
        } else {
            let defaults = UserDefaults.standard
            if !defaults.bool(forKey: "AccessibilityAsked") {
                let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
                AXIsProcessTrustedWithOptions(options as CFDictionary)
                defaults.set(true, forKey: "AccessibilityAsked")
            }
        }
    }
    
    // MARK: - Settings Management
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        
        let savedScale = defaults.double(forKey: "UIScale")
        currentScale = savedScale > 0 ? CGFloat(savedScale) : 1.0
        
        let savedOpacity = defaults.object(forKey: "UIOpacity") as? Double
        currentOpacity = savedOpacity != nil ? CGFloat(savedOpacity!) : 0.3
        
        let savedTerminal = defaults.string(forKey: "SelectedTerminal")
        selectedTerminal = savedTerminal ?? "terminal"
        
        shouldExecuteCommand = defaults.object(forKey: "ShouldExecuteCommand") as? Bool ?? true
    }
    
    private func saveScale() {
        UserDefaults.standard.set(Double(currentScale), forKey: "UIScale")
    }
    
    private func saveOpacity() {
        UserDefaults.standard.set(Double(currentOpacity), forKey: "UIOpacity")
    }
    
    private func saveTerminal() {
        UserDefaults.standard.set(selectedTerminal, forKey: "SelectedTerminal")
    }
    
    private func saveExecuteMode() {
        UserDefaults.standard.set(shouldExecuteCommand, forKey: "ShouldExecuteCommand")
        // Передаём настройку в WebView
        let js = "if (typeof setExecuteMode === 'function') { setExecuteMode(\(shouldExecuteCommand)); }"
        webView?.evaluateJavaScript(js, completionHandler: nil)
    }
    
    private func applyScale() {
        let js = "document.body.style.zoom = '\(currentScale)';"
        webView.evaluateJavaScript(js, completionHandler: nil)
        saveScale()
    }
    
    private func applyOpacity() {
        backgroundView.layer?.backgroundColor = NSColor.black.withAlphaComponent(currentOpacity).cgColor
        saveOpacity()
    }
    
    @objc func scaleChanged(_ sender: NSSlider) {
        currentScale = CGFloat(sender.doubleValue)
        let percent = Int(currentScale * 100)
        scaleLabel.stringValue = "\(percent)%"
        applyScale()
    }
    
    @objc func opacityChanged(_ sender: NSSlider) {
        currentOpacity = CGFloat(sender.doubleValue)
        let percent = Int(currentOpacity * 100)
        opacityLabel.stringValue = "\(percent)%"
        applyOpacity()
    }
    
    @objc func selectTerminalApp(_ sender: NSMenuItem) {
        selectedTerminal = "terminal"
        saveTerminal()
        updateTerminalMenu()
    }
    
    @objc func selectiTerm(_ sender: NSMenuItem) {
        selectedTerminal = "iterm"
        saveTerminal()
        updateTerminalMenu()
    }
    
    @objc func selectExecuteMode() {
        shouldExecuteCommand = true
        saveExecuteMode()
        updateExecuteMenu()
        print("Режим: Исполнить")
    }
    
    @objc func selectSendMode() {
        shouldExecuteCommand = false
        saveExecuteMode()
        updateExecuteMenu()
        print("Режим: Отправить")
    }
    
    var terminalAppItem: NSMenuItem!
    var iTermItem: NSMenuItem!
    var executeItem: NSMenuItem!
    var sendItem: NSMenuItem!
    
    private func updateTerminalMenu() {
        terminalAppItem.state = selectedTerminal == "terminal" ? .on : .off
        iTermItem.state = selectedTerminal == "iterm" ? .on : .off
    }
    
    private func updateExecuteMenu() {
        executeItem.state = shouldExecuteCommand ? .on : .off
        sendItem.state = !shouldExecuteCommand ? .on : .off
    }
    
    // MARK: - Status Bar Menu
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "🐾"
        }
        
        let menu = NSMenu()
        
        // Подсказки (F19)
        toggleMenuItem = NSMenuItem(title: "Подсказки (F19)", action: #selector(toggleOverlayFromMenu), keyEquivalent: "")
        toggleMenuItem.target = self
        menu.addItem(toggleMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // === Настройки ===
        let settingsItem = NSMenuItem(title: "Настройки", action: nil, keyEquivalent: "")
        let settingsSubmenu = NSMenu()
        
        // Редактировать команды
        let editCommandsItem = NSMenuItem(title: "Редактировать команды", action: #selector(enterEditMode), keyEquivalent: "")
        editCommandsItem.target = self
        settingsSubmenu.addItem(editCommandsItem)
        
        settingsSubmenu.addItem(NSMenuItem.separator())
        
        // -- Терминал --
        let terminalItem = NSMenuItem(title: "Терминал", action: nil, keyEquivalent: "")
        let terminalSubmenu = NSMenu()
        
        terminalAppItem = NSMenuItem(title: "Terminal.app", action: #selector(selectTerminalApp(_:)), keyEquivalent: "")
        terminalAppItem.target = self
        terminalSubmenu.addItem(terminalAppItem)
        
        iTermItem = NSMenuItem(title: "iTerm", action: #selector(selectiTerm(_:)), keyEquivalent: "")
        iTermItem.target = self
        terminalSubmenu.addItem(iTermItem)
        
        terminalItem.submenu = terminalSubmenu
        settingsSubmenu.addItem(terminalItem)
        
        // -- Действие --
        let actionItem = NSMenuItem(title: "Действие", action: nil, keyEquivalent: "")
        let actionSubmenu = NSMenu()
        
        executeItem = NSMenuItem(title: "Исполнить", action: #selector(selectExecuteMode), keyEquivalent: "")
        executeItem.target = self
        actionSubmenu.addItem(executeItem)
        
        sendItem = NSMenuItem(title: "Отправить", action: #selector(selectSendMode), keyEquivalent: "")
        sendItem.target = self
        actionSubmenu.addItem(sendItem)
        
        actionItem.submenu = actionSubmenu
        settingsSubmenu.addItem(actionItem)
        
        // -- Масштаб --
        let scaleItem = NSMenuItem(title: "Масштаб", action: nil, keyEquivalent: "")
        let scaleSubmenu = NSMenu()
        
        let scaleSliderView = NSView(frame: NSRect(x: 0, y: 0, width: 180, height: 30))
        
        scaleSlider = NSSlider(frame: NSRect(x: 10, y: 5, width: 110, height: 20))
        scaleSlider.minValue = 0.5
        scaleSlider.maxValue = 2.0
        scaleSlider.doubleValue = Double(currentScale)
        scaleSlider.target = self
        scaleSlider.action = #selector(scaleChanged(_:))
        scaleSlider.isContinuous = true
        scaleSliderView.addSubview(scaleSlider)
        
        let scalePercent = Int(currentScale * 100)
        scaleLabel = NSTextField(frame: NSRect(x: 125, y: 5, width: 45, height: 20))
        scaleLabel.stringValue = "\(scalePercent)%"
        scaleLabel.isEditable = false
        scaleLabel.isBordered = false
        scaleLabel.backgroundColor = .clear
        scaleLabel.alignment = .right
        scaleLabel.font = NSFont.systemFont(ofSize: 12)
        scaleSliderView.addSubview(scaleLabel)
        
        let scaleSliderMenuItem = NSMenuItem()
        scaleSliderMenuItem.view = scaleSliderView
        scaleSubmenu.addItem(scaleSliderMenuItem)
        
        scaleItem.submenu = scaleSubmenu
        settingsSubmenu.addItem(scaleItem)
        
        // -- Прозрачность --
        let opacityItem = NSMenuItem(title: "Прозрачность", action: nil, keyEquivalent: "")
        let opacitySubmenu = NSMenu()
        
        let opacitySliderView = NSView(frame: NSRect(x: 0, y: 0, width: 180, height: 30))
        
        opacitySlider = NSSlider(frame: NSRect(x: 10, y: 5, width: 110, height: 20))
        opacitySlider.minValue = 0.0
        opacitySlider.maxValue = 1.0
        opacitySlider.doubleValue = Double(currentOpacity)
        opacitySlider.target = self
        opacitySlider.action = #selector(opacityChanged(_:))
        opacitySlider.isContinuous = true
        opacitySliderView.addSubview(opacitySlider)
        
        let opacityPercent = Int(currentOpacity * 100)
        opacityLabel = NSTextField(frame: NSRect(x: 125, y: 5, width: 45, height: 20))
        opacityLabel.stringValue = "\(opacityPercent)%"
        opacityLabel.isEditable = false
        opacityLabel.isBordered = false
        opacityLabel.backgroundColor = .clear
        opacityLabel.alignment = .right
        opacityLabel.font = NSFont.systemFont(ofSize: 12)
        opacitySliderView.addSubview(opacityLabel)
        
        let opacitySliderMenuItem = NSMenuItem()
        opacitySliderMenuItem.view = opacitySliderView
        opacitySubmenu.addItem(opacitySliderMenuItem)
        
        opacityItem.submenu = opacitySubmenu
        settingsSubmenu.addItem(opacityItem)
        
        settingsItem.submenu = settingsSubmenu
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Выход
        let quitItem = NSMenuItem(title: "Выход", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        updateTerminalMenu()
        updateExecuteMenu()
    }
    
    @objc func toggleOverlayFromMenu() {
        toggleOverlay()
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Edit Mode
    
    @objc func enterEditMode() {
        // Сначала показать оверлей если скрыт
        if !window.isVisible {
            showOverlay()
            // Небольшая задержка чтобы WebView загрузился
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.sendEnterEditModeToJS()
            }
        } else {
            sendEnterEditModeToJS()
        }
    }
    
    private func sendEnterEditModeToJS() {
        let js = "if (typeof enterEditMode === 'function') { enterEditMode(); }"
        webView?.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("Ошибка входа в режим редактирования: \(error)")
            } else {
                print("Режим редактирования активирован")
            }
        }
    }
    
    // MARK: - Hot Key Registration
    
    private func registerHotKey() {
        let keyCode: UInt32 = 80 // F19
        let modifiers: UInt32 = 0
        
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x48505753)
        hotKeyID.id = 1
        
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Ошибка регистрации горячей клавиши: \(status)")
            return
        }
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }
                let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
                
                DispatchQueue.main.async {
                    appDelegate.toggleOverlay()
                }
                
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
        
        print("Горячая клавиша F19 зарегистрирована")
    }
    
    private func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
    
    // MARK: - Window Setup
    
    private func setupWindow() {
        let screenFrame = NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1920, height: 1080)
        
        window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }
    
    private func setupWebView() {
        let webConfig = WKWebViewConfiguration()
        webConfig.preferences.javaScriptEnabled = true
        
        let contentController = webConfig.userContentController
        contentController.add(self, name: "executeCommand")
        contentController.add(self, name: "closeOverlay")
        contentController.add(self, name: "enterEditMode")
        contentController.add(self, name: "exitEditMode")
        
        let containerView = NSView(frame: window.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        
        // Чёрный фон с регулируемой прозрачностью
        backgroundView = NSView(frame: containerView.bounds)
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor.black.withAlphaComponent(currentOpacity).cgColor
        backgroundView.autoresizingMask = [.width, .height]
        containerView.addSubview(backgroundView)
        
        webView = WKWebView(frame: containerView.bounds, configuration: webConfig)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        webView.setValue(false, forKey: "drawsBackground")
        containerView.addSubview(webView)
        
        window.contentView = containerView
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ WebView загрузка завершена")
        applyScale()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ WebView ошибка: \(error)")
    }
    
    private func loadHTML() {
        let bundlePath = Bundle.main.bundlePath
        let resourcesPath = bundlePath + "/Contents/Resources"
        let htmlPath = resourcesPath + "/index.html"
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: htmlPath) {
            print("✅ index.html найден")
            let htmlURL = URL(fileURLWithPath: htmlPath)
            let resourcesURL = URL(fileURLWithPath: resourcesPath)
            webView.loadFileURL(htmlURL, allowingReadAccessTo: resourcesURL)
        } else {
            print("❌ index.html не найден")
            loadFallbackHTML()
        }
    }
    
    private func loadFallbackHTML() {
        let fallbackHTML = """
        <!DOCTYPE html>
        <html>
        <head><meta charset="utf-8">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            html, body { background: transparent !important; height: 100%; }
            body { color: #fff; font-family: -apple-system; display: flex; justify-content: center; align-items: center; height: 100vh; }
            h1 { font-size: 48px; }
        </style>
        </head>
        <body><h1>🔥 Hotpaws</h1></body>
        </html>
        """
        webView.loadHTMLString(fallbackHTML, baseURL: nil)
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "executeCommand":
            if let body = message.body as? [String: Any],
               let command = body["command"] as? String {
                executeInTerminal(command: command)
            }
            
        case "closeOverlay":
            hideOverlay()
            
        case "enterEditMode":
            print("JS запросил режим редактирования")
            // Уже в режиме редактирования, ничего дополнительного не делаем
            
        case "exitEditMode":
            print("JS вышел из режима редактирования")
            // Можно добавить дополнительную логику если нужно
            
        default:
            break
        }
    }
    
    // MARK: - Terminal Integration
    
    private func executeInTerminal(command: String) {
        let escapedCommand = command.replacingOccurrences(of: "\\", with: "\\\\")
                                    .replacingOccurrences(of: "\"", with: "\\\"")
        
        let appleScript: String
        
        if selectedTerminal == "iterm" {
            if shouldExecuteCommand {
                // Исполнить команду
                appleScript = """
                tell application "iTerm"
                    activate
                    if (count of windows) = 0 then
                        create window with default profile
                    end if
                    tell current session of current window
                        write text "\(escapedCommand)"
                    end tell
                end tell
                """
            } else {
                // Только отправить (без Enter)
                appleScript = """
                tell application "iTerm"
                    activate
                    if (count of windows) = 0 then
                        create window with default profile
                    end if
                    tell current session of current window
                        tell application "System Events"
                            keystroke "\(escapedCommand)"
                        end tell
                    end tell
                end tell
                """
            }
        } else {
            if shouldExecuteCommand {
                // Исполнить команду
                appleScript = """
                tell application "Terminal"
                    activate
                    if (count of windows) = 0 then
                        do script "\(escapedCommand)"
                    else
                        do script "\(escapedCommand)" in front window
                    end if
                end tell
                """
            } else {
                // Только отправить (без Enter)
                appleScript = """
                tell application "Terminal"
                    activate
                    if (count of windows) = 0 then
                        do script ""
                    end if
                    tell application "System Events"
                        tell process "Terminal"
                            keystroke "\(escapedCommand)"
                        end tell
                    end tell
                end tell
                """
            }
        }
        
        var error: NSDictionary?
        if let script = NSAppleScript(source: appleScript) {
            script.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideOverlay()
        }
    }
    
    // MARK: - Overlay Control
    
    func showOverlay() {
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }
    
    func hideOverlay() {
        window.orderOut(nil)
    }
    
    func toggleOverlay() {
        if window.isVisible {
            hideOverlay()
        } else {
            showOverlay()
        }
    }
}

// MARK: - Main Entry Point

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
