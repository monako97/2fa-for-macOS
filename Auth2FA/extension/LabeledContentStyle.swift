//
//  LabeledContentStyle.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/5.
//

import SwiftUI

struct VerticalLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
    }
}
struct SegmentedControlLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            configuration.content
                .frame(width: 120)
        }
    }
}

extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
    static var vertical: VerticalLabeledContentStyle { .init() }
}

extension LabeledContentStyle where Self == SegmentedControlLabeledContentStyle {
    static var toggleSegmentedControl: SegmentedControlLabeledContentStyle { .init() }
}
