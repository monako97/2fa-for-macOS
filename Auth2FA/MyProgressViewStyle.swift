//
//  MyProgressViewStyle.swift
//  moneko
//
//  Created by neko Mo on 2022/12/28.
//

import SwiftUI

struct MyProgressViewStyle:ProgressViewStyle{
    let foregroundColor:Color
    let backgroundColor:Color
    let total:CGFloat
    @State var timeRemaining:CGFloat
    init(foregroundColor:Color = .green.opacity(0.8),backgroundColor:Color = .accentColor.opacity(0.8), timeRemaining: CGFloat = 30, total: CGFloat = 30){
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.timeRemaining = timeRemaining
        self.total = total
    }
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader{ proxy in
            ZStack(alignment:.bottomTrailing){
                backgroundColor
                Rectangle()
                    .fill(foregroundColor)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .frame(
                        width: proxy.size.width * self.timeRemaining / self.total,
                        height: 20
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                configuration.label
                    .frame(
                        alignment: .center
                    )
                    .font(Font.system(size: 12))
                    .foregroundColor(.white)
                    .fontWeight(.light)
                    .kerning(3)
                    .padding(.horizontal, 2)
            )
            .onReceive(timer) {time in
                withAnimation {
                    self.timeRemaining = self.timeRemaining > 0 ? self.timeRemaining - 1 : self.total
                }
            }
        }
    }
}
