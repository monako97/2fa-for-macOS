//
//  QRCode.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/2.
//

import Foundation
import CoreImage.CIFilterBuiltins
import AppKit

let context = CIContext()
let filter = CIFilter.qrCodeGenerator()

func generateQRCode(from string: String, size: CGFloat) -> NSImage {
    filter.setValue(Data(string.utf8), forKey: "inputMessage")

    if let outputImage = filter.outputImage {
        let extent = outputImage.extent.integral
        let scale = min(size / extent.width, size / extent.height)
        /// Create bitmap
        let width: size_t = size_t(extent.width * scale)
        let height: size_t = size_t(extent.height * scale)
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmap: CGContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 1)!
        ///
        let context = CIContext.init()
        let bitmapImage = context.createCGImage(outputImage, from: extent)
        bitmap.interpolationQuality = .none
        bitmap.scaleBy(x: scale, y: scale)
        bitmap.draw(bitmapImage!, in: extent)
            
        let scaledImage = bitmap.makeImage()
        return NSImage(cgImage: scaledImage!, size: NSSize(width: size, height: size))
    }
    return NSImage()
}
