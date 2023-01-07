//
//  ClipBoard.swift
//  moneko
//
//  Created by neko Mo on 2022/12/30.
//

import AppKit

func copyToClipBoard(textToCopy: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(textToCopy, forType: .string)
}

func quitApp(sender: Any) {
    NSApplication.shared.terminate(sender)
}

func showSettingsWindow() {
    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    NSApp.activate(ignoringOtherApps: true)
}
