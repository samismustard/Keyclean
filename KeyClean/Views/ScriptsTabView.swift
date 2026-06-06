import SwiftUI

struct ScriptsTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedScript: Script?
    @State private var editorSource: String = ""
    @State private var isRunning = false

    var body: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: 0) {
                List(selection: $selectedScript) {
                    ForEach(appState.macroStore.scripts) { script in
                        Text(script.name)
                            .tag(script)
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    if selectedScript?.id == script.id {
                                        selectedScript = nil
                                        editorSource = ""
                                    }
                                    appState.macroStore.delete(script: script)
                                }
                            }
                    }
                }
                .listStyle(.sidebar)

                Divider()

                Button("New Script") {
                    let s = Script(id: UUID(), name: "Untitled", source: "// Write JavaScript here\nkeyboard.type('hello')\n", hotkey: nil)
                    appState.macroStore.save(script: s)
                    selectedScript = s
                    editorSource = s.source
                }
                .buttonStyle(.borderless)
                .padding(8)
            }
            .frame(minWidth: 150, maxWidth: 200)

            VStack(spacing: 0) {
                TextEditor(text: $editorSource)
                    .font(.system(.body, design: .monospaced))
                    .onChange(of: editorSource) { _, newValue in
                        if var script = selectedScript {
                            script.source = newValue
                            appState.macroStore.save(script: script)
                            selectedScript = script
                        }
                    }

                Divider()

                ScrollView {
                    Text(appState.scriptOutput.isEmpty ? "// Output appears here" : appState.scriptOutput)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(appState.scriptOutput.hasPrefix("Error") ? .red : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                .frame(height: 120)
                .background(Color(nsColor: .textBackgroundColor).opacity(0.5))

                Divider()

                HStack {
                    Spacer()
                    Button(isRunning ? "Running..." : "Run") {
                        guard let script = selectedScript else { return }
                        isRunning = true
                        DispatchQueue.global(qos: .userInitiated).async {
                            appState.runScript(script.source)
                            DispatchQueue.main.async { isRunning = false }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedScript == nil || isRunning)
                }
                .padding(8)
            }
        }
        .onChange(of: selectedScript) { _, script in
            editorSource = script?.source ?? ""
        }
    }
}
