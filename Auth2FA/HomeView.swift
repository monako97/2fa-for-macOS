//
//  HomeView.swift
//  moneko
//
//  Created by neko Mo on 2022/12/10.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: AppModel
    @EnvironmentObject private var setting: SettingModel
    @EnvironmentObject private var time: TimeModel
    @State private var showSetting: Bool = false
    @State private var showExit: Bool = false
    @State private var dragOver = false
    
    var body: some View {
        VStack (spacing: 0){
            SegmentedControlView(homeTabs, $app.currentTab)
                .padding(.horizontal, 15)
                .padding(.top, 15)
                .padding(.bottom, 0)
                .onChange(of: app.currentTab, perform: { v in
                    v == .list ? time.start() : time.timerCancel.cancelAll()
                })
            if app.currentTab == .list {
                ListView()
            } else {
                QRCodeScannerView(dragOver: $dragOver)
            }
            HStack {
                IconButton<Image>("gear", { self.showSetting = true })
                    .popover(isPresented: $showSetting, content: {
                        SettingsView()
                            .font(.system(size: 13))
                    })
                    .font(.system(size: 15))
                    .padding(.vertical, 5)
                Spacer()
                if app.url != "" || app.currentTab == .add {
                    Button(action: {
                        if app.addText == "add" {
                            withAnimation {
                                app.currentTab = .list
                                Auth2FAManaged.add(app.addItem)
                                app.addText = "addSuccess"
                            }
                        }
                    }, label: {
                        Text(LocalizedStringKey(app.addText))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 5)
                            .background(Color(.controlAccentColor))
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .onHoverStyle(radius: 50)
                    })
                    .disabled(app.addItem.secret == "" || app.addItem.remark == "")
                }
                Spacer()
                IconButton<Image>("xmark.circle", "xmark.circle.fill", {
                    self.showExit = true
                })
                .popover(isPresented: $showExit, content: {
                    ModalView(
                        Text("quitAppMessage").padding(20),
                        okText: "quit",
                        destructive: {
                            NSApplication.shared.terminate(self)
                        }
                    )
                    .font(.system(size: 13))
                })
                .font(.system(size: 15))
                .padding(.vertical, 5)
            }
            .padding(.horizontal, 15)
            .padding(.top, 5)
            .padding(.bottom, 10)
        }
        .onDrop(of: [.fileURL], isTargeted: $dragOver) { providers -> Bool in
            if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                    if let url = object {
                        DispatchQueue.main.sync {
                            app.setDropImageData(url)
                        }
                    }
                }
                return true
            }
            return false
        }
        .buttonStyle(.plain)
        .frame(
            maxHeight: NSScreen.main?.visibleFrame.height
        )
        .preferredColorScheme(getColorSchema(theme: setting.theme))
        .environment(\.locale, .init(identifier: getLocale(locale: setting.locale)))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
