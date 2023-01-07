//
//  HomeView.swift
//  moneko
//
//  Created by neko Mo on 2022/12/10.
//

import SwiftUI
import CoreData
import CryptoKit
struct Route: Identifiable {
    let id = UUID()
    let label: String
    let key: String
}

struct HomeView: View {
    @EnvironmentObject private var addModel: AddModel
    @EnvironmentObject private var homeModel: HomeModel
    @EnvironmentObject private var settingModel: SettingModel
    @State private var showSetting: Bool = false
    @State private var showExit: Bool = false
    @State private var dragOver = false
    
    var body: some View {
        VStack (spacing: 0){
            SegmentedControlView(tabs: homeModel.tabs, currentTab: $homeModel.currentTab)
                .padding(.horizontal, 15)
                .padding(.top, 15)
                .padding(.bottom, 0)
            if homeModel.currentTab == .list {
                ListView()
            } else {
                QRCodeScannerView(dragOver: $dragOver)
            }
            HStack {
                IconButton(
                    icon: Image(systemName: "gear"),
                    action: {
                        self.showSetting = true
                    })
                .popover(isPresented: $showSetting, content: {
                    SettingsView()
                        .font(.system(size: 13))
                })
                .font(.system(size: 15))
                .padding(.vertical, 5)
                Spacer()
                if addModel.url != "" || homeModel.currentTab == .add {
                    Button(action: {
                        if self.addModel.addText == "add" {
                            withAnimation {
                                homeModel.currentTab = .list
                                Auth2FAManaged.add(
                                    factor: addModel.factor,
                                    secret: addModel.secret,
                                    remark: addModel.remark,
                                    issuer: addModel.issuer,
                                    period: addModel.period,
                                    algorithm: addModel.algorithm,
                                    digits: addModel.digits,
                                    counter: addModel.counter
                                )
                                self.addModel.addText = "addSuccessfully"
                            }
                        }
                    }, label: {
                        Text(LocalizedStringKey(addModel.addText))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 5)
                            .background(Color(.controlAccentColor))
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .onHoverStyle(radius: 50)
                    })
                    .disabled(addModel.secret == "" || addModel.remark == "")
                }
                Spacer()
                IconButton(
                    icon: Image(systemName: "power"),
                    action: {
                        self.showExit = true
                    })
                .popover(isPresented: $showExit, content: {
                    ModalView(message: {
                        Text("quitAppMessage")
                            .padding(20)
                    }, destructive: {
                        quitApp(sender: self)
                    }, okText: "quit")
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
                            do {
                                let data = try Data(contentsOf: url)
                                self.addModel.imageData = data
                            } catch {
                                withAnimation {
                                    self.addModel.addText = "failedToReadFile"
                                }
                            }
                        }
                    }
                }
                return true
            }
            return false
        }
        .onChange(of: dragOver, perform: { d in
            if dragOver == true && self.homeModel.currentTab == .list {
                withAnimation {
                    self.homeModel.currentTab = .add
                }
            }
        })
        .buttonStyle(.plain)
        .frame(
            maxHeight: NSScreen.main?.visibleFrame.height
        )
        .preferredColorScheme(getColorSchema(theme: settingModel.theme))
        .environment(\.locale, .init(identifier: getLocale(locale: settingModel.locale)))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
