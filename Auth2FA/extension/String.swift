//
//  extension:StringBase32.swift
//  moneko
//
//  Created by neko Mo on 2022/12/29.
//

import Foundation

public class Base32 {
    private static let numAlphabet: [UInt8] = [26, 27, 28, 29, 30, 31] // 2[50] - 7[55] -> 26 - 31
    private static let letterAlphabet: [UInt8] = (0...25).map { $0 } // A[65](a[97]) - Z[90](z[122]) -> 0 - 25
    private static let bit5FrontAnd: [UInt8] = [0b10000, 0b11000, 0b11100, 0b11110, 0b11111]
    private static let bit5BackAnd: [UInt8] = [0b00001, 0b00011, 0b00111, 0b01111, 0b11111]
    private static let byteOfbitSize = [8, 16, 24, 32, 40]
    
    /// base32解码
    /// - Parameter data: 需要解码的数据
    public static func decodeChar(data: Data) -> Data? {
        // 解码
        guard let decodeData = decode5Bit(data: data) else { return nil }
        // 拼接
        return bit5Concat(data: decodeData)
    }
    
    /// 5 bit解码
    /// - Parameter data: 需要解码的数据
    private static func decode5Bit(data: Data) -> Data? {
        var decodeData = Data()
        for c in data {
            switch c {
            case 50...55: // 2 - 7
                decodeData.append(Base32.numAlphabet[Int(c) - 50])
            case 65...90: // A - Z
                decodeData.append(Base32.letterAlphabet[Int(c) - 65])
            case 97...122: // a - z
                decodeData.append(Base32.letterAlphabet[Int(c) - 97])
            case 61: // =
                decodeData.append(0)
            default:
                // invalid char code
                return nil
            }
        }
        return decodeData
    }
    
    /// 拼接5 bit解码数据
    /// - Parameter data: 5 bit解码的数据
    private static func bit5Concat(data: Data) -> Data {
        // datas, tmp bytes, bit offset
        let res = data.reduce(into: (ds: Data(), bs: initZeroBytes(count: 5), bitOffset: 0)) {
            let byteOffset = $0.bitOffset / 8 // 当前5 byte位置
            let currentBitCount = Base32.byteOfbitSize[byteOffset] // 当前byte的bit数
            let needBitCount = $0.bitOffset + 5 // 所需要bit数
            let diffBitCount = currentBitCount - needBitCount
            
            if diffBitCount < 0 { // 超出当前byte情况
                let leftBitCount = needBitCount - $0.bitOffset
                let rightBitCount = -diffBitCount
                $0.bs[byteOffset] += (($1 & Base32.bit5FrontAnd[leftBitCount - 1]) >> rightBitCount)
                $0.bs[byteOffset + 1] += (($1 & Base32.bit5BackAnd[rightBitCount - 1]) << (8 - rightBitCount))
            } else { // 当前字节位置足够
                $0.bs[byteOffset] += ($1 << diffBitCount)
            }
            
            // 5 byte数据已合并
            if needBitCount == 40 {
                $0.ds.append(contentsOf: $0.bs)
                $0.bs = initZeroBytes(count: 5)
                $0.bitOffset = 0
            } else {
                $0.bitOffset = needBitCount
            }
        }
        
        // 拼接不足5 byte的数据
        if res.bitOffset != 0 {
            var ds = res.ds
            let bs = res.bs[0..<res.bitOffset/8].map { $0 }
            ds.append(contentsOf: bs)
            return ds
        }
        return res.ds
    }
    
    private static func initZeroBytes(count: Int) -> [UInt8] {
        return Array<UInt8>.init(repeating: 0, count: count)
    }
}

extension String {
    public func base32Decode(using encode: String.Encoding = .utf8) -> Data? {
        guard let ds = data(using: encode) else { return nil }
        return Base32.decodeChar(data: ds)
    }
}
