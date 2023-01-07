//
//  HomeModel.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//

import SwiftUI

enum HomeTab: String, CaseIterable {
    case list, add
}

class HomeModel: ObservableObject {
    let tabs: [TabObject<HomeTab>] = [
        TabObject(label: "verificationCode", key: .list, icon: "list.dash.header.rectangle"),
        TabObject(label: "scanCode", key: .add, icon: "qrcode.viewfinder")
    ]
    
    @Published var currentTab: HomeTab = .list
}
