import SwiftUI
import ServiceManagement

struct SettingsTabView: View {
    @State private var hasAccessibility = PermissionChecker.hasAccessibility
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
            Section("Permissions") {
                HStack {
                    Label("Input Monitoring (Accessibility)",
                          systemImage: hasAccessibility ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(hasAccessibility ? .green : .red)
                    Spacer()
                    if !hasAccessibility {
                        Button("Open System Settings") {
                            PermissionChecker.openSystemSettings()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .onAppear { hasAccessibility = PermissionChecker.hasAccessibility }
            }

            Section("Startup") {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, enabled in
                        do {
                            if enabled {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            launchAtLogin = !enabled
                        }
                    }
            }

            Section("Keyboard Lock") {
                Text("Default unlock hotkey: ⌘⌥L")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
