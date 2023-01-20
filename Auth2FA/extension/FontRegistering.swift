//
//  FontRegistering.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/9.
//
import SwiftUI

let fontFiles = ["iconfont"]

final class FontRegistering {
    static let shared = FontRegistering()
    var isRegistered = false
    
    static func register() {
        if !shared.isRegistered {
            shared.registerFonts()
        }
    }
    
    func registerFonts() {
        let fontDatas = fontFiles
            .compactMap { Bundle(for: Self.self).url(forResource: $0, withExtension: "ttf") }
            .compactMap { try? Data(contentsOf: $0) }
        for data in fontDatas {
            guard let provider = CGDataProvider(data: data as CFData) else { return }
            guard let font = CGFont(provider) else { return }
            let error: UnsafeMutablePointer<Unmanaged<CFError>?>? = nil
            guard CTFontManagerRegisterGraphicsFont(font, error) else {
                guard
                    let unError = error?.pointee?.takeUnretainedValue(),
                    let description = CFErrorCopyDescription(unError)
                else {
                    print("Unknown error")
                    return
                }
                print("Failed to load font: ", description)
            }
        }
        isRegistered = true
    }
}
