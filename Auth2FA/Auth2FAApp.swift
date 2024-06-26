//
//  monekoApp.swift
//  moneko
//
//  Created by neko Mo on 2022/12/10.
//

import SwiftUI
import WebKit

@main
struct Auth2FAApp: App {
     @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
     @AppStorage("showMenuBarExtra") private var showMenuBarExtra: Bool = false
     @AppStorage("sceneMode") private var sceneMode: SceneMode = .popover
     @AppStorage("locale") private var locale: Localication = .unspecified
     
     init() {
          FontRegistering.register()
     }
     var body: some Scene {
          MenuBarExtra("menuBarExtra", image: "two.factor.authentication", isInserted: $showMenuBarExtra) {
               delegate.renderView().frame(width: 300, height: 575)
          }
          .menuBarExtraStyle(.window)
          WindowGroup(id: "main") {
               self.renderWindow()
          }
          .commandsRemoved()
          .onChange(of: sceneMode) { (prev, next) in
               NSApp.setActivationPolicy(next == .window ? .regular : .accessory)
               if prev != .popover {
                    NSApplication.shared.hide(self)
               }
               if next == .popover {
                    if delegate.statusItem == nil {
                         delegate.setUpMenu()
                    } else if let _statusItem = delegate.statusItem {
                         _statusItem.isVisible = true
                    }
               } else if (delegate.popover != nil && delegate.popover.isShown) {
                    delegate.popover.close()
                    delegate.statusItem?.isVisible = false
               }
          }
          .windowToolbarStyle(.unifiedCompact(showsTitle: false))
          .windowResizability(.contentSize)
          .windowStyle(.hiddenTitleBar)
     }
     
     @ViewBuilder
     func renderWindow() -> some View {
          if sceneMode == .window {
               VStack (spacing: 0) {
                    HStack {
                         Spacer()
                         Text("Two Factor Authentication")
                         Spacer()
                    }
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .bold))
                    .padding(.top, 5 )
                    delegate.renderView()
               }
               .frame(minWidth: 300, maxWidth: 300, minHeight: 565, idealHeight: 565)
               .blurBackground()
               .ignoresSafeArea()
               .environment(\.locale, .init(identifier: getLocale(locale: locale)))
          }
     }
}

// Popover动画方式
class AppDelegate: NSObject,ObservableObject,NSApplicationDelegate {
     @Environment(\.openWindow) private var openWindow
     private let viewContext = PersistenceController.shared.container.viewContext
     private var appModel = AppModel()
     private var settingModel = SettingModel()
     private var timeModel = TimeModel()
     private var batteryModel = BatteryModel()
     var statusItem: NSStatusItem?
     var popover: NSPopover!
     
     @ViewBuilder
     func renderView() -> some View {
          HomeView()
               .environment(\.managedObjectContext, viewContext)
               .environmentObject(appModel)
               .environmentObject(settingModel)
               .environmentObject(timeModel)
               .environmentObject(batteryModel)
     }
     
     func applicationDidFinishLaunching(_ notification: Notification) {
          if settingModel.sceneMode == .popover {
               setUpMenu()
          } else if settingModel.sceneMode == .window {
               NSApp.setActivationPolicy(.regular)
          }
     }
     func setUpMenu() {
          if popover == nil {
               popover = NSPopover()
               popover.animates = true
               popover.behavior = .transient
               popover.contentSize = NSSize(width: 300, height: 570)
               popover.contentViewController = NSHostingController(
                    rootView: self.renderView()
               )
          }
          if statusItem == nil {
               statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
               if let menuButton = statusItem!.button {
                    menuButton.image = .init(named: "two.factor.authentication")
                    menuButton.action = #selector(menuButtonAction(sender: ))
                    menuButton.window?.registerForDraggedTypes([.fileURL, .multipleTextSelection, .png])
                    menuButton.window?.delegate = self
               }
               statusItem!.isVisible = true
          }
     }
     func draggingEnded(_ sender: NSDraggingInfo) {
          let propertyList = sender.draggingPasteboard.propertyList
          if  let board = propertyList(NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] {
               self.appModel.setDropImageData(URL(filePath: board[0]))
          } else if let urls = propertyList(.init(rawValue: "WebURLsWithTitlesPboardType")) as? [[String]] {
               self.appModel.setDropImageData(URL(string: urls[0][0])!)
          }
     }
     
     func openPopover() {
          if settingModel.sceneMode == .popover {
               if let menuButton = statusItem?.button {
                    popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .minY)
               }
          }
     }
     @objc func menuButtonAction(sender: AnyObject) {
          popover.isShown ? popover.performClose(sender) : openPopover()
     }
     func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
          if !flag {
               openWindow(id: "main")
          }
          return false
     }
}

extension AppDelegate: NSWindowDelegate {}
extension AppDelegate: NSDraggingDestination {
     func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation{
          return .copy
     }
     func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
          return true
     }
}
