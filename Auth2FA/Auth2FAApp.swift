//
//  monekoApp.swift
//  moneko
//
//  Created by neko Mo on 2022/12/10.
//

import SwiftUI

@main
struct Auth2FAApp: App {
     @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
     @AppStorage("showMenuBarExtra") var showMenuBarExtra: Bool = false
     @AppStorage("statusMenu") var statusMenu: StatusMenu = .popover
     @AppStorage("locale") var locale: Localication = .unspecified
     
     init() {
          FontRegistering.register()
     }
     var body: some Scene {
          MenuBarExtra("MenuBarExtra", systemImage: "key.horizontal.fill", isInserted: $showMenuBarExtra) {
               AppMain()
                    .frame(width: 300, height: 575)
          }
          .menuBarExtraStyle(.window)
//          #if os(macOS)
//          Settings {
//               SettingsView()
//                    .environmentObject(settingModel)
//                    .blurBackground()
//          }
//          #endif
          WindowGroup {
               if statusMenu == .window {
                    VStack (spacing: 0) {
                         Text("Two Factor Authentication")
                              .foregroundColor(.secondary)
                              .font(.system(size: 13, weight: .bold))
                              .frame(width: 300)
                              .padding(.top, 34 )
                              .blurBackground()
                         AppMain()
                              .frame(width: 300, height: 568)
                              .blurBackground()
                    }
                    .frame(width: 300, height: 560)
                    .ignoresSafeArea()
                    .environment(\.locale, .init(identifier: getLocale(locale: locale)))
               }
          }
          .windowResizability(.contentSize)
          .windowToolbarStyle(.unifiedCompact(showsTitle: false))
          .windowStyle(.hiddenTitleBar)
     }
}

struct AppMain: View {
     let persistenceController = PersistenceController.shared
     let addModel = AddModel()
     let homeModel = HomeModel()
     let settingModel = SettingModel()
     let editModel = EditModel()
     var body: some View {
          HomeView()
               .environment(\.locale, .init(identifier: getLocale(locale: settingModel.locale)))
               .environment(\.managedObjectContext, persistenceController.container.viewContext)
               .environmentObject(homeModel)
               .environmentObject(addModel)
               .environmentObject(settingModel)
               .environmentObject(editModel)
     }
}
// Popover动画方式
class AppDelegate: NSObject,ObservableObject,NSApplicationDelegate {
     var statusItem: NSStatusItem? = nil
     var popover: NSPopover!
     @AppStorage("statusMenu") var statusMenu: StatusMenu = .popover
     func applicationDidFinishLaunching(_ notification: Notification) {
          if self.statusMenu == .popover {
               self.setUpMenu()
          }
     }
     func applicationDidUpdate(_ notification: Notification) {
          if self.statusMenu == .popover {
               if self.statusItem == nil {
                    self.setUpMenu()
               }
          } else {
               if self.popover != nil && self.popover.isShown {
                    self.popover?.close()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                         if self.statusItem != nil && self.statusMenu != .popover {
                              NSStatusBar.system.removeStatusItem(self.statusItem!)
                              self.statusItem = nil
                         }
                    }
               }
          }
          toggleActivationPolicy()
     }
     func toggleActivationPolicy() {
          let activationPolicy = NSApp.activationPolicy()
          if self.statusMenu == .window {
               if (activationPolicy != .regular) {
                    NSApp.setActivationPolicy(.regular)
               }
          } else if activationPolicy != .accessory {
               NSApp.setActivationPolicy(.accessory)
          }
     }
     func setUpPopover() {
          if self.popover == nil {
               self.popover = NSPopover()
               self.popover.animates = true
               self.popover.behavior = .transient
               self.popover.contentSize = NSSize(width: 300, height: 575)
               self.popover.contentViewController = NSHostingController(
                    rootView: AppMain()
               )
               self.popover.contentViewController?.view.window?.makeKey()
          }
     }
     func setUpMenu() {
          self.setUpPopover()
          self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
          if let menuButton = statusItem?.button {
               menuButton.image = .init(systemSymbolName: "key.horizontal.fill", accessibilityDescription: nil)
               menuButton.action = #selector(menuButtonAction(sender: ))
          }
     }
     @objc func menuButtonAction(sender: AnyObject) {
          if self.popover.isShown {
               self.popover.performClose(sender)
          } else {
               if let menuButton = statusItem?.button{
                    self.popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .minY)
               }
          }
     }
}
