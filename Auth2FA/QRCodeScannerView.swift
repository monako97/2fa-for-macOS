//
//  QRCodeScannerView.swift
//  moneko
//
//  Created by neko Mo on 2022/12/29.
//

import SwiftUI
import _PhotosUI_SwiftUI


struct QRCodeScannerView: View {
    @EnvironmentObject private var addModel: AddModel
    @EnvironmentObject private var settingModel: SettingModel
    @State private var image = NSImage(named: "image")
    @Binding var dragOver: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            PhotosPicker(
                selection: $addModel.imageSelection,
                matching: .images,
                photoLibrary: .shared()
            ) {
                if addModel.imageData != nil {
                    Image(nsImage: NSImage(data: addModel.imageData!)!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(20)
                } else {
                    ZStack{
                        Image(systemName: "qrcode.viewfinder")
                            .font(Font.system(size: 200, weight: .ultraLight))
                            .foregroundColor(dragOver ? .accentColor : .secondary)
                        Text("readQRCode")
                            .offset(y: 70)
                            .foregroundColor(dragOver ? .accentColor : .secondary)
                    }
                    .frame(width: 200, height: 200)
                    .opacity(0.6)
                }
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .shadow(color: dragOver ? Color.accentColor : Color.clear, radius: 4)
            Spacer()
            VStack (spacing: 10) {
                TextField("otpauthUrl", text: $addModel.url)
                Divider()
                TextField("remark", text: $addModel.remark)
                Divider()
                TextField("secret", text: $addModel.secret)
                Divider()
                HStack {
                    Picker("factor", selection: $addModel.factor, content: {
                        Text("TOTP")
                            .font(.system(size: 12, weight: .light))
                            .tag(Factor.totp)
                        Text("HOTP")
                            .font(.system(size: 12, weight: .light))
                            .tag(Factor.hotp)
                    })
                    .labelsHidden()
                    .frame(width: 33)
                    Divider().frame(height: 14)
                    TextField("digits", value: $addModel.digits, formatter: NumberFormatter())
                        .frame(width: 30)
                    Divider().frame(height: 14)
                    if addModel.factor == .totp {
                        TextField("period", value: $addModel.period, formatter: NumberFormatter())
                            .frame(width: 30)
                    } else {
                        TextField("counter", value: $addModel.counter, formatter: NumberFormatter())
                            .frame(width: 30)
                    }
                    Divider().frame(height: 14)
                    TextField("issuer", text: $addModel.issuer)
                    Text(Iconfont(rawValue: addModel.issuer.lowercased())?.icon ?? Iconfont.gitlab.icon)
                        .font(.iconfont(size: 18))
                }
                Divider()
                SegmentedControlView(tabs: addModel.algorithmOption, currentTab: $addModel.algorithm)
            }
            .font(.system(size: 12))
            .fontWeight(.light)
            .padding(15)
            .textFieldStyle(.plain)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(15)
        .environment(\.locale, .init(identifier: getLocale(locale: settingModel.locale)))
    }
}

struct QRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerView(dragOver: .constant(false))
    }
}
