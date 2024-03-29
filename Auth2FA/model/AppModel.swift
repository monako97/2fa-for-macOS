//
//  AppModel.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//

import SwiftUI
import PhotosUI.PHPicker

struct ImageData: Transferable {
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            return ImageData(data: data)
        }
    }
}

enum HomeTab: String, CaseIterable {
    case list, add
}

let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)!


func getAppVersion() -> String {
    if let infoDictionary = Bundle.main.infoDictionary,
        let appVersion = infoDictionary["CFBundleShortVersionString"] as? String,
       let buildNumber = infoDictionary["CFBundleVersion"] as? String {
        return "\(appVersion) (Build: \(buildNumber))"
    } else {
        return "Version information not available"
    }
}

final class AppModel: ObservableObject {
    var version = getAppVersion()
    @Published var currentTab: HomeTab = .list
    @Published var addItem: OTP.Params = (.totp, "", "", "", 30, .sha1, 6, 0, "")
    @Published var addText: String = "add" {
        didSet {
            if addText != "add" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        if self.addText == "addSuccess" {
                            self.url = ""
                            self.imageSelection = nil
                            self.dropImage = nil
                            self.addItem = (.totp, "", "", "", 30, .sha1, 6, 0, "")
                        }
                        self.addText = "add"
                    }
                }
            }
        }
    }
    @Published var url: String = "" {
        didSet {
            if url.hasPrefix("otpauth://") {
                do {
                    self.addItem = try OTP.parseURL(url)
                } catch _ {
                    DispatchQueue.main.async {
                        withAnimation {
                            self.addText = "inputIsInvalid"
                        }
                    }
                }
            }
        }
    }
    var dropImage: Data? = nil {
        didSet {
            if let dropImage {
                DispatchQueue.main.async {
                    withAnimation {
                        self.currentTab = .add
                    }
                    guard let ciimage = CIImage(data: dropImage) else {
                        self.dropImage = nil
                        withAnimation {
                            self.addText = "invalidImage"
                        }
                        return
                    }
                    let features: [CIQRCodeFeature] = qrDetector.features(in:  ciimage) as! [CIQRCodeFeature]
                    
                    if features.count == 0 {
                        withAnimation {
                            self.addText = "noQRcode"
                        }
                    }
                    for feature in features {
                        if feature.messageString != nil {
                            self.url = feature.messageString!
                        } else {
                            withAnimation {
                                self.addText = "theQRcodeIsInvalid"
                            }
                        }
                    }
                }
            }
        }
    }
    var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                imageSelection.loadTransferable(type: ImageData.self) { result in
                    DispatchQueue.main.async {
                        guard imageSelection == self.imageSelection else {
                            self.addText = "unableToFetchSelectedItem"
                            return
                        }
                        switch result {
                        case .success(let image?):
                            self.dropImage = image.data
                        case .success(nil):
                            self.addText = "notAValidImage"
                            self.dropImage = nil
                        case .failure(_):
                            self.addText = "wrongWrong"
                            self.dropImage = nil
                        }
                    }
                }
            }
        }
    }
    func setDropImageData(_ url: URL) {
        withAnimation {
            self.addText = "loading"
        }
        URLSession.shared.dataTask(with: url) { data,resp,err  in
            DispatchQueue.main.async {
                if let imgdata = data {
                    self.dropImage = imgdata
                } else {
                    withAnimation {
                        self.addText = "failedToReadFile"
                    }
                }
            }
        }.resume()
    }
}
