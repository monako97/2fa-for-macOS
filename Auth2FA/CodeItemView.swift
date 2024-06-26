//
//  CodeItemView.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//
import SwiftUI

func genCode(_ item: Item) -> String? {
    return OTP.generateCode(item.factor, item.secret, item.period , item.algorithm, item.digits, item.counter)
}

struct CodeItemView: View {
    @EnvironmentObject private var time: TimeModel
    @EnvironmentObject private var setting: SettingModel
    @EnvironmentObject private var app: AppModel
    private let item: Item
    @State private var timeRemaining: Int
    @State private var code: String?
    @State private var normalCode: String
    @State private var toastMessage: String = ""
    @State private var toastType: ToastStatus = .normal
    @State private var showView = (delete: false,toast: false,qrcode: false,edit: false)
    @State private var edit: PutItem = ("", 0, 30, "", "")
    
    init(_ item: Item) {
        self.item = item
        self.timeRemaining = getTimeRemaining(Date().timeIntervalSince1970, Int(item.period))
        self.code = genCode(item)
        self.normalCode = String(repeating: "*", count: Int(item.digits))
    }
    private func copyToClipBoard(textToCopy: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(textToCopy, forType: .string)
    }
    private func getSafeIcon(icon: Optional<String>, issuer: String) -> IconView? {
        let _icon = item.icon ?? ""
        
        return IconView(_icon.isEmpty ? issuer.lowercased() : _icon)
    }
    
    var body: some View {
        let hasTimer = item.factor == "totp" && setting.showTimeRemaining
        HStack (spacing: 10) {
            if setting.enableShowQRCode || hasTimer {
                VStack(spacing: 5) {
                    let counterView = Text("\(hasTimer ? timeRemaining : Int(item.counter))")
                        .font(.system(size: 11, weight: .light))
                    let qrcode = Text(Image(systemName: "qrcode"))
                        .font(.system(size: 13, weight: .light))
                    RingView(
                        text: IconButton(
                            hasTimer ? counterView : qrcode,
                            setting.enableShowQRCode ? qrcode : counterView,
                            action: {
                                if setting.enableShowQRCode {
                                    showView.qrcode = true
                                }
                            }
                        ),
                        total: CGFloat(item.period),
                        percent: hasTimer ? CGFloat(timeRemaining) : 0
                    )
                    .frame(width: 20)
                    .popover(isPresented: $showView.qrcode, arrowEdge: .leading) {
                        let cgimage = generateQRCode(OTP.generateURL(parseOtpParams(item)), 168)
                        if cgimage != nil {
                            Image(cgimage!, scale: 1, label: Text(""))
                                .padding()
                        }
                    }
                    Text((item.factor ?? "TOTP").uppercased())
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
                        if setting.enableDelete {
                            IconButton<Image>(
                                "trash",
                                "trash.fill",
                                { showView.delete = true }
                            )
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                            .popover(isPresented: $showView.delete) {
                                ModalView(
                                    Text("deleteMessage\(Text(item.remark ?? "").foregroundColor(.accentColor))")
                                        .padding(.horizontal, 20)
                                        .padding(.top, 20)
                                        .padding(.bottom, 15),
                                    "thisActionCannotBeUndone",
                                    destructive: {
                                        Auth2FAManaged.delete(item)
                                    }
                                )
                            }
                        }
                    }
                    Divider().foregroundColor(.primary.opacity(0.4))
                    HStack (spacing: 2) {
                        let issuer = item.issuer ?? ""
                        let _icon = item.icon ?? ""
                        
                        HStack(spacing: 5) {
                            IconView(_icon.isEmpty ? issuer.lowercased() : _icon)
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
                        Text(setting.showCode ? code ?? normalCode : normalCode)
                            .font(Font.system(size: 12, weight: .light))
                            .frame(minWidth: CGFloat(item.digits * 11))
                            .tracking(3)
                            .offset(y: setting.showCode ? 0 : 1.5)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .foregroundColor(Color.accentColor)
                            .background(Color.accentColor.opacity(0.1))
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: setting.radius / 2))
                            .task(id: item.counter, priority: .background) {
                                if setting.showCode {
                                    self.code = genCode(item)
                                    self.normalCode = String(repeating: "*", count: Int(item.digits))
                                }
                            }
                            .task(id: setting.showCode, priority: .background) {
                                if setting.showCode {
                                    self.code = genCode(item)
                                }
                            }
                            .task(id: time.time, priority: .background) {
                                self.timeRemaining = getTimeRemaining(time.time.timeIntervalSince1970, Int(item.period))
                                if setting.showCode && timeRemaining == Int(item.period) {
                                    self.code = genCode(item)
                                }
                            }
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
            Task(priority: .background) {
                guard let authCode = genCode(item), authCode.count > 0 else {
                    self.toastMessage = "copyFailed"
                    self.toastType = .error
                    withAnimation {
                        showView.toast = true
                    }
                    return
                }
                copyToClipBoard(textToCopy: authCode)
                self.toastMessage = "copySuccessfully"
                self.toastType = .success
                withAnimation {
                    showView.toast = true
                }
            }
        }
        .toast(toastMessage, $showView.toast, status: toastType)
        .contextMenu {
            if setting.enableEdit {
                Button("edit") {
                    let issuer = item.issuer ?? ""
                    let icon = getSafeIcon(icon: item.icon, issuer: issuer)
                    
                    self.edit = (item.remark ?? "", Int(item.counter), Int(item.period), issuer, icon?.text)
                    showView.edit = true
                }
            }
            Button("add") {
                withAnimation {
                    app.currentTab = HomeTab.add
                }
            }
        }
        .sheet(isPresented: $showView.edit, onDismiss: {
            self.edit = ("", 0, 30, "", "")
        }) {
            ModalView(
                Form {
                    TextField("remark", text: $edit.remark)
                    TextField("issuer", text: $edit.issuer)
                    LabeledContent("icon") {
                        IconPickerView(selection: $edit.icon)
                    }
                    if item.factor == "hotp" {
                        TextField("counter", value: $edit.counter, formatter: NumberFormatter())
                    } else {
                        TextField("period", value: $edit.period, formatter: NumberFormatter())
                    }
                }
                    .formStyle(.grouped)
                    .font(.system(size: 13, weight: .light))
                    .frame(width: 300)
                    .scrollContentBackground(.hidden)
                ,
                destructive: {
                    Auth2FAManaged.put(item.objectID, self.edit)
                }
            )
            .blurBackground()
        }
        .symbolRenderingMode(.multicolor)
    }
}

struct CodeItemView_Previews: PreviewProvider {
    static var previews: some View {
        CodeItemView(Item())
    }
}
