//
//  TimeModel.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/15.
//

import SwiftUI

final class TimeModel: ObservableObject {
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    var timerCancel = CancelAll()
    private var windowCancel = CancelAll()
    @Published var time: Date = Date()
    
    func start() {
        self.timerCancel.cancelAll()
        self.time = Date()
        self.timer.assign(to: \.time, on: self).store(in: &self.timerCancel)
    }
    init() {
        NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)
            .sink { _ in
                self.start()
            }
            .store(in: &windowCancel)
        NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)
            .sink { _ in
                self.timerCancel.cancelAll()
            }
            .store(in: &windowCancel)
    }
}
