import SwiftUI

private final class AppObjects: ObservableObject {
    let appState = AppState()
    var menuBarManager: MenuBarManager?
}

@main
struct KeyCleanApp: App {
    @StateObject private var objects = AppObjects()

    init() {
        PermissionChecker.requestIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(objects.appState)
                .onAppear {
                    if objects.menuBarManager == nil {
                        objects.menuBarManager = MenuBarManager(appState: objects.appState)
                    }
                }
        }
        .windowStyle(.titleBar)
    }
}
