import Cocoa

class OverlayWindow: NSWindow {
    
    private var commandLabel: NSTextField!
    private var clickableArea: NSView!
    
    init() {
        guard let screen = NSScreen.main else {
            super.init(contentRect: .zero, styleMask: [], backing: .buffered, defer: false)
            return
        }
        
        let screenRect = screen.frame
        
        super.init(
            contentRect: screenRect,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Настройки окна для overlay
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        self.isOpaque = false
        self.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.6)
        self.hasShadow = false
        self.ignoresMouseEvents = false
        
        setupUI()
        setupKeyMonitor()
    }
    
    private func setupUI() {
        guard let contentView = self.contentView else { return }
        
        // Кликабельная область (кнопка)
        clickableArea = NSView()
        clickableArea.wantsLayer = true
        clickableArea.layer?.backgroundColor = NSColor(white: 1.0, alpha: 0.25).cgColor
        clickableArea.layer?.cornerRadius = 8
        clickableArea.layer?.borderWidth = 0
        clickableArea.layer?.borderColor = NSColor.clear.cgColor
        clickableArea.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clickableArea)
        
        // Label с текстом Inter 24pt
        commandLabel = NSTextField(labelWithString: "hotpaws")
        commandLabel.font = NSFont(name: "Inter", size: 24) ?? NSFont.systemFont(ofSize: 24, weight: .regular)
        commandLabel.textColor = NSColor.white
        commandLabel.alignment = .center
        commandLabel.isBezeled = false
        commandLabel.drawsBackground = false
        commandLabel.isEditable = false
        commandLabel.isSelectable = false
        commandLabel.translatesAutoresizingMaskIntoConstraints = false
        clickableArea.addSubview(commandLabel)
        
        // Constraints (padding: 24px horizontal, 16px vertical)
        NSLayoutConstraint.activate([
            clickableArea.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            clickableArea.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            commandLabel.topAnchor.constraint(equalTo: clickableArea.topAnchor, constant: 16),
            commandLabel.bottomAnchor.constraint(equalTo: clickableArea.bottomAnchor, constant: -16),
            commandLabel.leadingAnchor.constraint(equalTo: clickableArea.leadingAnchor, constant: 24),
            commandLabel.trailingAnchor.constraint(equalTo: clickableArea.trailingAnchor, constant: -24),
        ])
        
        // Gesture recognizer для клика
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(commandClicked))
        clickableArea.addGestureRecognizer(clickGesture)
        
        // Hover эффект
        let trackingArea = NSTrackingArea(
            rect: clickableArea.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        clickableArea.addTrackingArea(trackingArea)
    }
    
    private func setupKeyMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC
                self?.hideOverlay()
                return nil
            }
            return event
        }
    }
    
    @objc private func commandClicked() {
        TerminalInjector.insertCommand("printf '\\nhotpaws\\n'")
        hideOverlay()
    }
    
    func showOverlay() {
        self.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hideOverlay() {
        self.orderOut(nil)
    }
    
    override func mouseEntered(with event: NSEvent) {
        // Hover: жёлтая обводка 2px с анимацией 0.3s
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            clickableArea.layer?.borderWidth = 2
            clickableArea.layer?.borderColor = NSColor(red: 1.0, green: 0.867, blue: 0.0, alpha: 1.0).cgColor // #FFDD00
        })
        NSCursor.pointingHand.set()
    }
    
    override func mouseExited(with event: NSEvent) {
        // Убираем обводку с анимацией
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            clickableArea.layer?.borderWidth = 0
            clickableArea.layer?.borderColor = NSColor.clear.cgColor
        })
        NSCursor.arrow.set()
    }
}
