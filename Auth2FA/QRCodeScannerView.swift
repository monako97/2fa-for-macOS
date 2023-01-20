//
//  QRCodeScannerView.swift
//  moneko
//
//  Created by neko Mo on 2022/12/29.
//

import SwiftUI
import PhotosUI.PHPicker

struct QRCodeScannerView: View {
    @EnvironmentObject private var app: AppModel
    @EnvironmentObject private var setting: SettingModel
    @Binding var dragOver: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            PhotosPicker(
                selection: $app.imageSelection,
                matching: .images,
                photoLibrary: .shared()
            ) {
                if app.dropImage != nil {
                    Image(nsImage: NSImage(data: app.dropImage!)!)
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
            .padding(.bottom, 10)
            Spacer(minLength: 0)
            VStack (spacing: 10) {
                Group {
                    TextField("otpauthUrl", text: $app.url)
                    Divider()
                    TextField("remark", text: $app.addItem.remark)
                    Divider()
                    TextField("secret", text: $app.addItem.secret)
                    Divider()
                }
                HStack {
                    Picker("factor", selection: $app.addItem.factor, content: {
                        Text("TOTP")
                            .font(.system(size: 12, weight: .light))
                            .tag(Factor.totp)
                        Text("HOTP")
                            .font(.system(size: 12, weight: .light))
                            .tag(Factor.hotp)
                    })
                    .labelsHidden()
                    .frame(width: 50)
                    Divider().frame(height: 14)
                    TextField("digits", value: $app.addItem.digits, formatter: NumberFormatter())
                    Divider().frame(height: 14)
                    if app.addItem.factor == .totp {
                        TextField("period", value: app.addItem.factor == .totp ? $app.addItem.period : $app.addItem.counter, formatter: NumberFormatter())
                    } else {
                        TextField("counter", value: $app.addItem.counter, formatter: NumberFormatter())
                    }
                }
                Divider()
                HStack {
                    HStack {
                        let icon = Iconfont(rawValue: app.addItem.issuer.lowercased())?.icon
                        if icon != nil {
                            Text(icon!).font(.iconfont(size: 14))
                        } else {
                            GridPickerView(selection: $app.addItem.icon, size: 14)
                                .labelsHidden()
                        }
                    }
                    .frame(width: 50)
                    Divider().frame(height: 14)
                    TextField("issuer", text: $app.addItem.issuer)
                }
                Divider()
                SegmentedControlView(algorithmOption, $app.addItem.algorithm)
            }
            .font(.system(size: 12))
            .fontWeight(.light)
            .padding(15)
            .textFieldStyle(.plain)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(15)
        .environment(\.locale, .init(identifier: getLocale(locale: setting.locale)))
    }
}

struct QRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerView(dragOver: .constant(false))
    }
}
