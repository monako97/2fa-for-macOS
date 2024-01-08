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
struct SpaceBetweenStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 20) {
            configuration.label
            Spacer()
            configuration.content
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
//            .background(Color.accentColor.opacity(0.05))
//            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
    static var vertical: VerticalLabeledContentStyle { .init() }
}

extension LabeledContentStyle where Self == SegmentedControlLabeledContentStyle {
    static var toggleSegmentedControl: SegmentedControlLabeledContentStyle { .init() }
}

extension LabeledContentStyle where Self == SpaceBetweenStyle {
    static var spaceBetween: SpaceBetweenStyle { .init() }
}


