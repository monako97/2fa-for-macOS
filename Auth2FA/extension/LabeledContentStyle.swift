//
//  LabeledContentStyle.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/5.
//

import Foundation
import SwiftUI

struct VerticalLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
    }
}
struct ReverseLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.content
            configuration.label
            Spacer()
        }
    }
}

extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
    static var vertical: VerticalLabeledContentStyle { .init() }
}

extension LabeledContentStyle where Self == ReverseLabeledContentStyle {
    static var reverse: ReverseLabeledContentStyle { .init() }
}
