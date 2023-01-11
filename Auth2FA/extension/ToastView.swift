//
//  ToastView.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//

import SwiftUI
enum ToastStatus {
    case success, error, normal, warning
}
struct ToastView: View {
    let info: String
    @Binding var isShow: Bool
    @State private var isShowAnimation: Bool = true
    @State private var duration : Double
    @State private var status: ToastStatus = .normal
    let accentColor: Color
    
    init(isShow:Binding<Bool>,info: String = "", duration:Double = 2.0, status: ToastStatus = .normal) {
        self._isShow = isShow
        self.info = info
        self.duration = duration
        self.status = status
        self.accentColor = status == .warning ? Color.orange : status == .success ? Color.green : status == .error ? Color.red : Color.accentColor
    }
    
    var body: some View {
        HStack{
            Text(LocalizedStringKey(info))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
                .frame(alignment: .center)
                .padding(.vertical, 5)
                .padding(.horizontal, 20)
                .lineLimit(1)
                .background(
                    self.accentColor.opacity(0.3)
                )
                .shadow(color: self.accentColor, radius: 1, y: 1)
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation {
                    isShowAnimation = false
                }
            }
        }
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 50)
        )
        .opacity(isShowAnimation ? 1 : 0)
        .scaleEffect(isShowAnimation ? 1 : 0)
        .animation(Animation.easeIn(duration: 0.5), value: 0)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isShowAnimation) { e in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isShow = false
            }
        }
    }
}

extension View {
    func toast(isShow:Binding<Bool>, info:String = "", duration:Double = 2.0, status: ToastStatus = .normal) -> some View {
        ZStack {
            self
            if isShow.wrappedValue {
                ToastView(isShow:isShow, info: info, duration: duration, status: status)
            }
        }
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(isShow: .constant(true))
    }
}
