//
//  QRCode.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/2.
//

import Foundation
import CoreImage.CIFilterBuiltins

let context: CIContext = CIContext()
let filter = CIFilter.qrCodeGenerator()

func generateQRCode(_ from: String, _ size: CGFloat) -> CGImage? {
    filter.setValue(Data(from.utf8), forKey: "inputMessage")
    if let outputImage = filter.outputImage {
        let extent = outputImage.extent.integral
        let scale = min(size / extent.width, size / extent.height)
        /// Create bitmap
        let bitmap = CGContext(data: nil, width: size_t(extent.width * scale), height: size_t(extent.height * scale), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: 1)
        if let bitmap = bitmap {
            bitmap.interpolationQuality = .none
            bitmap.scaleBy(x: scale, y: scale)
            bitmap.draw(context.createCGImage(outputImage, from: extent)!, in: extent)
            
            return bitmap.makeImage()
        }
        return nil
    }
    return nil
}
