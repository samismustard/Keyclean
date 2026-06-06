import SwiftUI

struct MacrosTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var isNamingMacro = false
    @State private var newMacroName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                ForEach(appState.macroStore.macros) { macro in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(macro.name).font(.body)
                            Text("\(macro.events.count) events")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Play") { appState.playback(macro: macro) }
                            .buttonStyle(.bordered)
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            appState.macroStore.delete(macro: macro)
                        }
                    }
                }
            }
            .listStyle(.inset)

            Divider()

            HStack(spacing: 12) {
                if appState.recorder.isRecording {
                    Button("Stop Recording") {
                        isNamingMacro = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                    Text("Recording...")
                        .foregroundStyle(.red)
                        .font(.caption)
                } else {
                    Button("Record Macro") {
                        appState.startRecording()
                    }
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
            }
            .padding(12)
        }
        .sheet(isPresented: $isNamingMacro) {
            VStack(spacing: 16) {
                Text("Name this macro").font(.headline)
                TextField("Macro name", text: $newMacroName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 220)
                HStack {
                    Button("Cancel") {
                        _ = appState.recorder.stopRecording()
                        isNamingMacro = false
                    }
                    Button("Save") {
                        appState.stopRecordingAndSave(name: newMacroName.isEmpty ? "Untitled" : newMacroName)
                        newMacroName = ""
                        isNamingMacro = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(24)
        }
    }
}
