//
//  IconView.swift
//  CodeSnippet
//
//  Created by Moneko on 2024/3/25.
//

import SwiftUI

// iconfont.0.woff2
let iconfontOne = convertIconfont([
    "nintendo account": "f1fc",
    "playstation": "ec18",
    "xbox": "ec30",
    "twitter": "ea07",
    "x": "e602",
    "google": "ea0c",
    "npm": "e685",
    "discord": "ebf8",
    "qnap": "e605",
    "github": "ea0b",
    "gitlab": "e65c",
    "synology": "ecd3",
    "facebook": "ebfc",
    "twitch": "ea3d",
    "tesla": "e613",
    "microsoft": "e60b",
    "epic+games": "eb8a",
    "linkedin": "e60c",
    "rockstar+games": "e604",
    "amazon": "ea09",
    "paypal": "e60d",
    "snapchat": "ea33",
    "dropbox": "ea0a",
    "mega": "ec0f",
    "gbatemp": "e60e",
    "instagram": "e87f",
    "pixiv": "e665",
    "openai": "e603",
    "adobe": "e6cc",
    "jetbrains": "e72f",
    "riot": "e69f",
    "unity": "ecf6",
    "ubisoft": "ecf2",
    "shopify": "ea03",
    "aliyun": "e6d1",
    "v2ex": "e67c",
    "hub.docker.com": "e625",
    "jira": "e60f",
    "kubernetes": "e6dd",
    "apple": "e6f2",
])

// iconfont.1.woff2
let iconfontTwo = convertIconfont([
    "atlassian": "e600",
    "alist": "e644",
    "tencent cloud services": "e6de",
])

func convertIconfont(_ mapping: [String:String]) -> [String:String]{
    mapping.reduce(into: [:]) { result, pair in
        let (key, value) = pair
        result[key] = Int(value, radix: 16).flatMap(UnicodeScalar.init).map(String.init)
    }
}

struct IconView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var text: String
    var size: CGFloat
    var normalIcon: String
    init(_ text: String?, _ size: CGFloat = 14, _ normalIcon: String = "questionmark.key.filled") {
        self.text = text ?? ""
        self.size = size
        self.normalIcon = normalIcon
    }
    var body: some View {
        if let icon = iconfontOne[text] {
            Text(icon)
                .font(.custom("auth2fa-1 Regular", size: size))
        } else if let icon = iconfontTwo[text] {
            Text(icon)
                .font(.custom("auth2fa-2 Regular", size: size))
        } else {
            Image(systemName: normalIcon)
        }
    }
}

#Preview {
    IconView("questionmark.key.filled")
}
