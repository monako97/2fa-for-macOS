//
//  Font.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/8.
//

import SwiftUI

public enum Icon {
    case iconfont(Iconfont)
}

public enum Iconfont: String, CaseIterable, Identifiable {
    case nintendoaccount = "nintendo account", playstation, xbox, steam, twitter, google, npm, discord, qnap, github, gitlab, synology, sony, facebook, twitch, tesla, microsoft,  epicgames = "epic+games", linkedin, rockstargames = "rockstar+games", amazon, paypal, snapchat, dropbox, mega, gbatemp
    public var id: Self { self }
}

extension Iconfont {
    var icon: String {
        switch self {
            case .nintendoaccount:
                return "\u{f1fc}"
            case .playstation:
                return "\u{ec18}"
            case .xbox:
                return "\u{ec30}"
            case .steam:
                return "\u{e610}"
            case .twitter:
                return "\u{ea07}"
            case .google:
                return "\u{ea0c}"
            case .npm:
                return "\u{e685}"
            case .discord:
                return "\u{ebf8}"
            case .qnap:
                return "\u{e605}"
            case .github:
                return "\u{ea0b}"
            case .gitlab:
                return "\u{e65c}"
            case .synology:
                return "\u{ecd3}"
            case .sony:
                return "\u{e67e}"
            case .facebook:
                return "\u{ebfc}"
            case .twitch:
                return "\u{ea3d}"
            case .tesla:
                return "\u{e613}"
            case .microsoft:
                return "\u{e60b}"
            case .epicgames:
                return "\u{eb8a}"
            case .linkedin:
                return "\u{e60c}"
            case .rockstargames:
                return "\u{e604}"
            case .amazon:
                return "\u{ea09}"
            case .paypal:
                return "\u{e60d}"
            case .snapchat:
                return "\u{ea33}"
            case .dropbox:
                return "\u{ea0a}"
            case .mega:
                return "\u{ec0f}"
            case .gbatemp:
                return "\u{e60e}"
        }
    }
}

extension Font {
    static func iconfont(size: CGFloat = 13, relativeTo: Font.TextStyle = .body) -> Font? {
        return .custom("iconfont Regular", size: size, relativeTo: relativeTo)
    }
}
