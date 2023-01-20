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
     @AppStorage("sceneMode") var sceneMode: SceneMode = .popover
     @AppStorage("locale") var locale: Localication = .unspecified
     
     init() {
          FontRegistering.register()
     }
     var body: some Scene {
          MenuBarExtra("menuBarExtra", systemImage: "key.horizontal.fill", isInserted: $showMenuBarExtra) {
               HomeView()
                    .frame(width: 300, height: 590)
                    .environment(\.managedObjectContext, delegate.viewContext)
                    .environmentObject(delegate.appModel)
                    .environmentObject(delegate.settingModel)
                    .environmentObject(delegate.timeModel)
          }
          .menuBarExtraStyle(.window)
          WindowGroup {
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
                         .blurBackground()
                         HomeView()
                              .blurBackground()
                    }
                    .frame(minWidth: 300, idealWidth: 300, minHeight: 565)
                    .ignoresSafeArea()
                    .environment(\.locale, .init(identifier: getLocale(locale: locale)))
                    .environment(\.managedObjectContext, delegate.viewContext)
                    .environmentObject(delegate.appModel)
                    .environmentObject(delegate.settingModel)
                    .environmentObject(delegate.timeModel)
               }
          }
          .onChange(of: sceneMode, perform: { newSceneMode in
               NSApp.setActivationPolicy(newSceneMode == .window ? .regular : .accessory)
               if newSceneMode == .popover {
                    if delegate.statusItem == nil {
                         delegate.setUpMenu()
                    } else if let statusItem = delegate.statusItem {
                         statusItem.isVisible = true
                    }
               } else if (delegate.popover != nil && delegate.popover.isShown) {
                    delegate.popover.close()
                    delegate.statusItem?.isVisible = false
               }
          })
          .windowResizability(.contentSize)
          .windowToolbarStyle(.unifiedCompact(showsTitle: false))
          .windowStyle(.hiddenTitleBar)
     }
}

// Popover动画方式
class AppDelegate: NSObject,ObservableObject,NSApplicationDelegate {
     let viewContext = PersistenceController.shared.container.viewContext
     var appModel = AppModel()
     var settingModel = SettingModel()
     var timeModel = TimeModel()
     var statusItem: NSStatusItem?
     var popover: NSPopover!
     
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
               popover.contentSize = NSSize(width: 300, height: 575)
               popover.contentViewController = NSHostingController(
                    rootView: HomeView()
                         .environment(\.managedObjectContext, viewContext)
                         .environmentObject(appModel)
                         .environmentObject(settingModel)
                         .environmentObject(timeModel)
               )
               popover.contentViewController!.view.window?.makeKey()
          }
          if statusItem == nil {
               statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
               if let menuButton = statusItem!.button {
                    menuButton.image = .init(systemSymbolName: "key.horizontal.fill", accessibilityDescription: nil)
                    menuButton.action = #selector(menuButtonAction(sender: ))
                    menuButton.window?.registerForDraggedTypes([.fileURL, .multipleTextSelection, .png])
                    menuButton.window?.delegate = self
               }
               statusItem!.isVisible = true
          }
     }
     func draggingEnded(_ sender: NSDraggingInfo) {
          let board: [String] = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as! [String]
          
          self.appModel.setDropImageData(URL(filePath: board[0]))
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
}

extension AppDelegate: NSWindowDelegate {}
extension AppDelegate: NSDraggingDestination {
     func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation{
          NSApplication.shared.activate(ignoringOtherApps: true )
          return .copy
     }
     func performDragOperation(_ sender: NSDraggingInfo) -> Bool{
          NSApplication.shared.activate(ignoringOtherApps: true )
          return true
     }
}
