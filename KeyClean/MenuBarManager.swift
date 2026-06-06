import AppKit
import Combine

@MainActor
final class MenuBarManager {
    private let statusItem: NSStatusItem
    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()

    init(appState: AppState) {
        self.appState = appState
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "KeyClean")

        buildMenu()

        appState.locker.$isLocked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locked in
                self?.updateIcon(locked: locked)
                self?.buildMenu()
            }
            .store(in: &cancellables)
    }

    private func buildMenu() {
        let menu = NSMenu()

        let lockTitle = appState.locker.isLocked ? "Unlock Keyboard" : "Lock Keyboard (Clean)"
        let lockItem = NSMenuItem(title: lockTitle, action: #selector(toggleLock), keyEquivalent: "")
        lockItem.target = self
        menu.addItem(lockItem)

        menu.addItem(.separator())

        if appState.macroStore.macros.isEmpty {
            menu.addItem(NSMenuItem(title: "No macros saved", action: nil, keyEquivalent: ""))
        } else {
            let recentHeader = NSMenuItem(title: "Recent Macros", action: nil, keyEquivalent: "")
            recentHeader.isEnabled = false
            menu.addItem(recentHeader)
            for macro in appState.macroStore.macros.prefix(5) {
                let item = NSMenuItem(title: macro.name, action: #selector(runMacro(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = macro
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())

        let openItem = NSMenuItem(title: "Open KeyClean...", action: #selector(openMainWindow), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit KeyClean", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func updateIcon(locked: Bool) {
        let name = locked ? "lock.fill" : "keyboard"
        statusItem.button?.image = NSImage(systemSymbolName: name, accessibilityDescription: "KeyClean")
    }

    @objc private func toggleLock() {
        appState.locker.toggle()
    }

    @objc private func runMacro(_ sender: NSMenuItem) {
        guard let macro = sender.representedObject as? Macro else { return }
        appState.playback(macro: macro)
    }

    @objc private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        appState.isMainWindowOpen = true
        for window in NSApp.windows {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
