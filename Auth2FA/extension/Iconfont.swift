//
//  Iconfont.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/8.
//

import SwiftUI

public enum Iconfont: String, CaseIterable, Identifiable, CustomStringConvertible {
    public var id: Self { self }
    case nintendoaccount = "nintendo account", playstation, xbox, twitter, google, npm, discord, qnap, github, gitlab, synology, facebook, twitch, tesla, microsoft,  epicgames = "epic+games", linkedin, rockstargames = "rockstar+games", amazon, paypal, snapchat, dropbox, mega, gbatemp, instagram, pixiv, openai, adobe, jetbrains, riot, unity, ubisoft, shopify
    
    public var description: String {
        switch self {
        case .nintendoaccount: return "\u{f1fc}"
        case .playstation: return "\u{ec18}"
        case .xbox: return "\u{ec30}"
        case .twitter: return "\u{ea07}"
        case .google: return "\u{ea0c}"
        case .npm: return "\u{e685}"
        case .discord: return "\u{ebf8}"
        case .qnap: return "\u{e605}"
        case .github: return "\u{ea0b}"
        case .gitlab: return "\u{e65c}"
        case .synology: return "\u{ecd3}"
        case .facebook: return "\u{ebfc}"
        case .twitch: return "\u{ea3d}"
        case .tesla: return "\u{e613}"
        case .microsoft: return "\u{e60b}"
        case .epicgames: return "\u{eb8a}"
        case .linkedin: return "\u{e60c}"
        case .rockstargames: return "\u{e604}"
        case .amazon: return "\u{ea09}"
        case .paypal: return "\u{e60d}"
        case .snapchat: return "\u{ea33}"
        case .dropbox: return "\u{ea0a}"
        case .mega: return "\u{ec0f}"
        case .gbatemp: return "\u{e60e}"
        case .instagram: return "\u{e87f}"
        case .pixiv: return "\u{e665}"
        case .openai: return "\u{e603}"
        case .adobe: return "\u{e6cc}"
        case .jetbrains: return "\u{e72f}"
        case .riot: return "\u{e69f}"
        case .unity: return "\u{ecf6}"
        case .ubisoft: return "\u{ecf2}"
        case .shopify: return "\u{ea03}"
        }
    }
}

extension Font {
    static func iconfont(size: CGFloat = 13) -> Font? {
        return .custom("iconfont Regular", size: size)
    }
}
