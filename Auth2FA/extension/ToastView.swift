//
//  ToastView.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//

import SwiftUI

struct ToastView: View {
    @Binding var isShow: Bool
    let info: String
    @State private var isShowAnimation: Bool = true
    @State private var duration : Double
    
    init(isShow:Binding<Bool>,info: String = "", duration:Double = 2.0) {
        self._isShow = isShow
        self.info = info
        self.duration = duration
    }
    
    var body: some View {
        HStack{
            Text(LocalizedStringKey(info))
                .font(.system(size: 12))
                .foregroundColor(.white)
                .frame(alignment: .center)
                .padding(.vertical, 5)
                .padding(.horizontal, 20)
                .lineLimit(1)
                .background(
                    Color.accentColor.opacity(0.2)
                )
                .shadow(color: .accentColor, radius: 1, y: 1)
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
    func toast(isShow:Binding<Bool>, info:String = "", duration:Double = 2.0) -> some View {
        ZStack {
            self
            if isShow.wrappedValue {
                ToastView(isShow:isShow, info: info, duration: duration)
            }
        }
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(isShow: .constant(true))
    }
}
