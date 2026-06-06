import SwiftUI

struct MainWindowView: View {
    var body: some View {
        TabView {
            MacrosTabView()
                .tabItem { Label("Macros", systemImage: "record.circle") }
            ScriptsTabView()
                .tabItem { Label("Scripts", systemImage: "chevron.left.forwardslash.chevron.right") }
            SettingsTabView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}
