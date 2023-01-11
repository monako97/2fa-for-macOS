//
//  CodeItemView.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//
import SwiftUI

func getAlgorithm(algorithm: String?) -> Algorithm {
    return Algorithm(rawValue: algorithm?.lowercased() ?? "sha1") ?? .SHA1
}
func getFactor(factor: String?) -> Factor {
    return Factor(rawValue: factor?.lowercased() ?? "totp") ?? .totp
}

func generateCode(item: Item) -> String? {
    return OTP.generateCode(params: parseGenerateParamsOnItem(item))
}

struct CodeItemView: View {
    private var item: Item
    @State private var timeRemaining: Int
    @State private var code: String?
    @State private var toastMessage: String = ""
    @State private var toastType: ToastStatus = .normal
    @State private var showDeleteAlert: Bool = false
    @State private var showToast: Bool = false
    @State private var showQRCode: Bool = false
    @State private var showEdit: Bool = false
    @EnvironmentObject private var settingModel: SettingModel
    @EnvironmentObject private var editModel: EditModel
    private let normalCode: String
    private let timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    
    init(item: Item) {
        self.item = item
        self.timeRemaining = getTimeRemaining(period: Int(self.item.period))
        self.code = generateCode(item: item)
        self.normalCode = String(repeating: "*", count: Int(item.digits))
    }
    
    var body: some View {
        let hasTimer = item.factor == "totp" && settingModel.showTimeRemaining
        HStack (spacing: 10) {
            if settingModel.enableShowQRCode || hasTimer {
                VStack(spacing: 5) {
                    let counterView = Text("\(hasTimer ? timeRemaining : Int(item.counter))")
                        .font(.system(size: 11, weight: .light))
                    let qrcode = Text(Image(systemName: "qrcode"))
                        .font(.system(size: 13, weight: .light))
                    RingView(
                        total: CGFloat(item.period),
                        percent: hasTimer ? CGFloat(timeRemaining) : 0,
                        text: IconButton(
                            icon: hasTimer ? counterView : qrcode,
                            hoverIcon: settingModel.enableShowQRCode ? qrcode : counterView,
                            action: {
                                if settingModel.enableShowQRCode {
                                    self.showQRCode = true
                                }
                            }
                        )
                    )
                    .frame(width: 20)
                    .popover(isPresented: $showQRCode) {
                        Image(nsImage: generateQRCode(from: OTP.generateURL(parseURLParamsOnItem(item)), size: 168))
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                    Text(item.factor?.uppercased() ?? "TOTP")
                        .font(Font.system(size: 8, weight: .light))
                        .opacity(0.6)
                }
            }
            HStack(spacing: 0) {
                VStack (alignment: .listRowSeparatorLeading, spacing: 3) {
                    HStack {
                        Text(item.remark ?? "")
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        if settingModel.enableDelete {
                            IconButton(
                                icon: Image(systemName: "trash"),
                                hoverIcon: Image(systemName: "trash.fill"),
                                action: { self.showDeleteAlert = true }
                            )
                            .font(.system(size: 12))
                            .popover(isPresented: $showDeleteAlert) {
                                ModalView(
                                    message: {
                                        HStack {
                                            Text("deleteMessage\(Text(String(describing: item.remark ?? "")).foregroundColor(.accentColor))")
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.top, 20)
                                        .padding(.bottom, 15)
                                    },
                                    destructive: {
                                        Auth2FAManaged.delete(obj: item)
                                    },
                                    secondaryMessage: "This action cannot be undone!"
                                )
                            }
                        }
                    }
                    .onReceive(timer) {time in
                        let updateTime = getTimeRemaining(period: Int(self.item.period))
                        
                        self.timeRemaining = updateTime
                        if settingModel.showCode && updateTime == Int(item.period) {
                            self.code = generateCode(item: item)
                        }
                    }
                    Divider().foregroundColor(.primary.opacity(0.4))
                    HStack (spacing: 2) {
                        let issuer = item.issuer ?? ""
                        let icon = Iconfont(rawValue: issuer.lowercased())?.icon
                        HStack(spacing: 5) {
                            if icon != nil {
                                Text(icon!).font(.iconfont(size: 14))
                            }
                            Text(issuer)
                                .lineLimit(1)
                                .font(.system(size: 11, weight: .light))
                        }
                        Spacer(minLength: 0)
                        if item.factor?.lowercased() == "hotp" {
                            Text("\(Image(systemName: "numbersign"))\(item.counter)")
                                .font(.system(size: 10))
                                .foregroundColor(Color.accentColor)
                        }
                        Text(settingModel.showCode ? code ?? normalCode : normalCode)
                            .font(Font.system(size: 12, weight: .light))
                            .frame(minWidth: CGFloat(item.digits * 11))
                            .tracking(3)
                            .offset(y: settingModel.showCode ? 0 : 1.5)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .foregroundColor(Color.accentColor)
                            .background(Color.accentColor.opacity(0.1))
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: settingModel.radius / 2))
                            .onChange(of: item.counter, perform: { counter in
                                if settingModel.showCode {
                                    self.code = generateCode(item: item)
                                }
                            })
                            .onChange(of: settingModel.showCode, perform: { showCode in
                                if showCode {
                                    self.code = generateCode(item: item)
                                }
                            })
                        
                    }
                    .foregroundColor(.primary.opacity(0.6))
                }
            }
            
        }
        .padding(.top, 10)
        .padding(.horizontal, 15)
        .padding(.bottom, 6)
        .onHoverStyle()
        .onTapGesture {
            if settingModel.enableClipBoard && item.secret != nil {
                guard let authCode = generateCode(item: item), authCode.count > 0 else {
                    withAnimation {
                        self.toastMessage = "copyFailed"
                        self.toastType = .error
                        self.showToast = true
                    }
                    return
                }
                copyToClipBoard(textToCopy: authCode)
                withAnimation {
                    self.toastMessage = "copySuccessfully"
                    self.toastType = .success
                    self.showToast = true
                }
            }
        }
        .toast(isShow: $showToast, info: toastMessage, status: toastType)
        .contextMenu {
            if settingModel.enableEdit {
                Button {
                    self.editModel.setup(item: item)
                    self.showEdit = true
                } label: {
                    Label("edit", systemImage: "square.and.pencil")
                }
                Button {
                    if settingModel.enableClipBoard && item.secret != nil {
                        copyToClipBoard(textToCopy: OTP.generateURL(parseURLParamsOnItem(item)))
                        withAnimation {
                            self.showToast = true
                        }
                    }
                } label: {
                    Label("copyOTPAuthURL", systemImage: "doc.on.clipboard")
                }
            }
        }
        .sheet(
            isPresented: $showEdit,
            onDismiss: {
                self.editModel.reset()
            }
        ) {
            ModalView(message: {
                Form {
                    TextField("remark", text: $editModel.remark)
                    TextField("issuer", text: $editModel.issuer)
                    if item.factor == "hotp" {
                        TextField("counter", value: $editModel.counter, formatter: NumberFormatter())
                    } else {
                        TextField("period", value: $editModel.period, formatter: NumberFormatter())
                    }
                }
                .formStyle(.grouped)
                .font(.system(size: 13, weight: .light))
                .frame(width: 300)
                .scrollContentBackground(.hidden)
            }, destructive: {
                Auth2FAManaged.put(with: item.objectID, remark: self.editModel.remark,issuer: self.editModel.issuer, counter: self.editModel.counter, period: self.editModel.period)
            })
        }
        .symbolRenderingMode(.multicolor)
        .environment(\.locale, .init(identifier: getLocale(locale: settingModel.locale)))
    }
}

struct CodeItemView_Previews: PreviewProvider {
    static var previews: some View {
        CodeItemView(item: Item())
    }
}
