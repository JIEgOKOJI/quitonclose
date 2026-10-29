import AppKit
import ApplicationServices
import CoreGraphics

private func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else {
        return nil
    }
    return value
}

private func stringAttribute(_ element: AXUIElement, _ name: String) -> String? {
    attribute(element, name) as? String
}

private func isCloseButton(_ element: AXUIElement) -> Bool {
    stringAttribute(element, kAXSubroleAttribute) == "AXCloseButton"
}

private func closeButtonFrame(window: AXUIElement) -> CGRect? {
    guard let closeButton = attribute(window, kAXCloseButtonAttribute) else { return nil }
    let button = closeButton as! AXUIElement

    guard let positionValue = attribute(button, kAXPositionAttribute),
          let sizeValue = attribute(button, kAXSizeAttribute) else { return nil }

    var position = CGPoint.zero
    var size = CGSize.zero
    guard AXValueGetValue(positionValue as! AXValue, .cgPoint, &position),
          AXValueGetValue(sizeValue as! AXValue, .cgSize, &size) else { return nil }

    return CGRect(origin: position, size: size)
}

private func applicationToQuit(at point: CGPoint) -> pid_t? {
    let systemWide = AXUIElementCreateSystemWide()
    var hitElement: AXUIElement?
    guard AXUIElementCopyElementAtPosition(
        systemWide,
        Float(point.x),
        Float(point.y),
        &hitElement
    ) == .success, var element = hitElement else { return nil }

    if isCloseButton(element) {
        var pid: pid_t = 0
        AXUIElementGetPid(element, &pid)
        return pid
    }

    for _ in 0..<12 {
        if stringAttribute(element, kAXRoleAttribute) == kAXWindowRole as String,
           let frame = closeButtonFrame(window: element),
           frame.insetBy(dx: -3, dy: -3).contains(point) {
            var pid: pid_t = 0
            AXUIElementGetPid(element, &pid)
            return pid
        }

        guard let parent = attribute(element, kAXParentAttribute) else { break }
        element = parent as! AXUIElement
    }
    return nil
}

private func sendQuitCommand(to pid: pid_t) {
    let source = CGEventSource(stateID: .hidSystemState)
    guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 12, keyDown: true),
          let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 12, keyDown: false) else { return }

    keyDown.flags = .maskCommand
    keyUp.flags = .maskCommand
    keyDown.postToPid(pid)
    keyUp.postToPid(pid)
}

private let eventCallback: CGEventTapCallBack = { _, type, event, userInfo in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let userInfo {
            Unmanaged<AppDelegate>.fromOpaque(userInfo).takeUnretainedValue().enableTap()
        }
        return Unmanaged.passUnretained(event)
    }

    guard type == .leftMouseDown,
          !event.flags.contains(.maskAlternate) else {
        return Unmanaged.passUnretained(event)
    }

    let point = event.location
    guard let pid = applicationToQuit(at: point),
          pid != ProcessInfo.processInfo.processIdentifier else {
        return Unmanaged.passUnretained(event)
    }

    sendQuitCommand(to: pid)
    return nil
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var toggleItem: NSMenuItem!
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var retainedSelf: Unmanaged<AppDelegate>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenu()
        requestAccessibilityPermission()
        setupEventTap()
    }

    private func setupMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(
            systemSymbolName: "xmark.circle",
            accessibilityDescription: "QuitOnClose"
        )

        let menu = NSMenu()
        toggleItem = NSMenuItem(
            title: "Перехват включён",
            action: #selector(toggleInterception),
            keyEquivalent: ""
        )
        toggleItem.target = self
        toggleItem.state = .on
        menu.addItem(toggleItem)

        let permissionItem = NSMenuItem(
            title: "Настройки разрешений…",
            action: #selector(openAccessibilitySettings),
            keyEquivalent: ""
        )
        permissionItem.target = self
        menu.addItem(permissionItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Выйти из QuitOnClose",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    private func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    private func setupEventTap() {
        let mask = CGEventMask(1 << CGEventType.leftMouseDown.rawValue)
        retainedSelf = Unmanaged.passUnretained(self)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: eventCallback,
            userInfo: retainedSelf!.toOpaque()
        )

        guard let eventTap else {
            showPermissionAlert()
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    func enableTap() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: toggleItem.state == .on)
        }
    }

    @objc private func toggleInterception() {
        toggleItem.state = toggleItem.state == .on ? .off : .on
        toggleItem.title = toggleItem.state == .on ? "Перехват включён" : "Перехват выключен"
        enableTap()
    }

    @objc private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Нужны разрешения macOS"
        alert.informativeText = "Добавьте QuitOnClose в разделы «Универсальный доступ» и «Мониторинг ввода» в Настройках → Конфиденциальность и безопасность, затем перезапустите утилиту."
        alert.addButton(withTitle: "Открыть настройки")
        alert.addButton(withTitle: "Позже")
        if alert.runModal() == .alertFirstButtonReturn {
            openAccessibilitySettings()
        }
    }
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
