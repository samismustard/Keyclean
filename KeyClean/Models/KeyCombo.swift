import CoreGraphics

struct KeyCombo: Codable, Equatable {
    let keyCode: Int
    let modifierFlags: UInt64 // CGEventFlags.rawValue

    var cgEventFlags: CGEventFlags { CGEventFlags(rawValue: modifierFlags) }
}

extension KeyCombo {
    static func parse(_ string: String) -> KeyCombo? {
        let parts = string.lowercased().components(separatedBy: "+")
        guard let keyName = parts.last else { return nil }
        let modNames = Set(parts.dropLast())

        var flags: CGEventFlags = []
        if modNames.contains("cmd") || modNames.contains("command") { flags.insert(.maskCommand) }
        if modNames.contains("shift") { flags.insert(.maskShift) }
        if modNames.contains("opt") || modNames.contains("alt") { flags.insert(.maskAlternate) }
        if modNames.contains("ctrl") || modNames.contains("control") { flags.insert(.maskControl) }

        let keyMap: [String: Int] = [
            "a":0,"s":1,"d":2,"f":3,"h":4,"g":5,"z":6,"x":7,"c":8,"v":9,
            "b":11,"q":12,"w":13,"e":14,"r":15,"y":16,"t":17,
            "1":18,"2":19,"3":20,"4":21,"6":22,"5":23,"=":24,"9":25,"7":26,
            "-":27,"8":28,"0":29,"]":30,"o":31,"u":32,"[":33,"i":34,"p":35,
            "return":36,"l":37,"j":38,"'":39,"k":40,";":41,"\\\":42,",":43,
            "/":44,"n":45,"m":46,".":47,"tab":48,"space":49,"delete":51,
            "escape":53,"left":123,"right":124,"down":125,"up":126
        ]

        guard let keyCode = keyMap[keyName] else { return nil }
        return KeyCombo(keyCode: keyCode, modifierFlags: flags.rawValue)
    }
}

