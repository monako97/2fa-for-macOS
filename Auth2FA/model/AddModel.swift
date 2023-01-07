//
//  AddModel.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct ImageData: Transferable {
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            return ImageData(data: data)
        }
    }
}
class AddModel: ObservableObject {
    let algorithmOption: [TabObject<Algorithm>] = [
        TabObject(label: "SHA1", key: .SHA1),
        TabObject(label: "SHA256", key: .SHA256),
        TabObject(label: "SHA512", key: .SHA512)
    ]
    let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)!

    @Published var addText: String = "add" {
        didSet {
            if addText != "add" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        if self.addText == "addSuccessfully" {
                            self.url = ""
                            self.remark = ""
                            self.issuer = ""
                            self.factor = .totp
                            self.algorithm = .SHA1
                            self.period = 30
                            self.digits = 6
                            self.counter = 0
                            self.secret = ""
                            self.imageSelection = nil
                            self.imageData = nil
                        }
                        self.addText = "add"
                    }
                }
            }
        }
    }
    @Published var url: String = "" {
        didSet {
            if url != "" {
                do {
                    let ds = try OTP.parseURL(url)
                    self.issuer = ds.issuer
                    self.secret = ds.secret
                    self.period = Int(ds.period)
                    self.algorithm = ds.algorithm
                    self.factor = ds.factor
                    self.remark = ds.remark
                    self.digits = Int(ds.digits)
                    self.counter = Int(ds.counter)
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
    @Published var factor: Factor = .totp
    @Published var secret: String = ""
    @Published var remark: String = ""
    @Published var issuer: String = ""
    @Published var period: Int = 30
    @Published var digits: Int = 6
    @Published var counter: Int = 0
    @Published var algorithm: Algorithm = .SHA1
    var imageData: Data? = nil {
        didSet {
            if let imageData {
                DispatchQueue.main.async {
                    guard let ciimage = CIImage(data: imageData) else {
                        self.imageData = nil
                        withAnimation {
                            self.addText = "invalidImage"
                        }
                        return
                    }
                    let features: [CIQRCodeFeature] = self.qrDetector.features(in:  ciimage) as! [CIQRCodeFeature]
                    
                    if features.count == 0 {
                        withAnimation {
                            self.addText = "noQRcode"
                        }
                    }
                    for feature in features {
                        let qrCodeFeature = feature
                        
                        if qrCodeFeature.messageString != nil {
                            self.url = qrCodeFeature.messageString!
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
                                self.imageData = image.data
                            case .success(nil):
                                self.addText = "notAValidImage"
                                self.imageData = nil
                            case .failure(_):
                                self.addText = "wrongWrong"
                                self.imageData = nil
                        }
                    }
                }
            }
        }
    }
}
