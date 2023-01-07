//
//  EditModel.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/6.
//

import Foundation

class EditModel: ObservableObject {
    var remark: String = ""
    var counter: Int = 0
    var period: Int = 30
    var issuer: String = ""
    
    func setup(item: Item) {
        self.remark = item.remark ?? ""
        self.counter = Int(item.counter)
        self.period = Int(item.period)
        self.issuer = item.issuer ?? ""
    }
    func reset() {
        self.remark = ""
        self.counter = 0
        self.period = 30
        self.issuer = ""
    }
}
