//
//  OTP.swift
//  moneko
//
//  Created by neko Mo on 2022/12/29.
//

import Foundation
import CommonCrypto

func getTimeRemaining(_ timeIntervalSince1970: TimeInterval, _ period: Int) -> Int {
    guard period > 0 else { return 0 }
    return period - (Int(timeIntervalSince1970) % period)
}

func parseOtpParams(_ item: Item) -> OTP.Params {
    return (Factor(rawValue: (item.factor ?? "totp").lowercased()) ?? .totp, item.secret ?? "", item.issuer ?? "", item.remark ?? "", item.period, Algorithm(rawValue: (item.algorithm ?? "sha1").lowercased()) ?? .sha1, item.digits, item.counter, item.icon ?? item.issuer?.lowercased())
}
public enum Algorithm: String {
    case sha1, sha256, sha512
}

public enum Factor: String, CaseIterable {
    case totp, hotp
}

public class OTP {
    /// 解析的错误
    private enum ParseError: Error {
        case URL,secret,type,algorithm
    }
    private static let HmacSHA: [String: (capacity: Int,hmacAlgorithm: Int)] = [
        "sha1": (Int(CC_SHA1_DIGEST_LENGTH), kCCHmacAlgSHA1),
        "sha256": (Int(CC_SHA256_DIGEST_LENGTH), kCCHmacAlgSHA256),
        "sha512": (Int(CC_SHA512_DIGEST_LENGTH), kCCHmacAlgSHA512)
    ]
    public typealias Params = (factor: Factor, secret: String, issuer: String, remark: String, period: Int32, algorithm: Algorithm, digits: Int32, counter: Int32, icon: String?)
    /// 缓存base32解码
    private static let base32Cache = { () -> NSCache<NSString, NSData> in
        let cache = NSCache<NSString, NSData>()
        cache.countLimit = 256
        cache.totalCostLimit = 256
        return cache
    }()
    /// 获取code
    /// - Parameter secret: 秘钥
    /// - Parameter factor: 因子
    /// - Parameter period: 默认 30
    /// - Parameter algorithm: 默认 SHA1
    /// - Parameter digits: 位数
    public static func generateCode(_ factor: String?, _ secret: String?, _ period: Int32?, _ algorithm: String?, _ digits: Int32?, _ counter: Int32?) -> String? {
        guard let _secret = secret, secret != nil else { return nil }
        let factor = (factor ?? "totp").lowercased()
        let algorithm = (algorithm ?? "sha1").lowercased()
        var key: [Data.Element] = []
        var data: [Data.Element] = []
        if factor == "hotp" {
            key = Data(hex: _secret).map{ $0 }
            data = Int(counter ?? 0).bigEndian.data.map { $0 }
        } else {
            let period = Int(period ?? 30)
            guard period > 0 else { return nil }
            guard let _key = base32Decode(str: _secret) else { return nil }
            key = _key.map { $0 }
            data = time2Bytes(Int(Date().timeIntervalSince1970) / period).map { $0 }
        }
        let digits = digits ?? 6
        // 数据进行hmac sha hash
        let hmacResult = UnsafeMutablePointer<CChar>.allocate(capacity: HmacSHA[algorithm]!.capacity)
        CCHmac(CCHmacAlgorithm(HmacSHA[algorithm]!.hmacAlgorithm), key, key.count, data, data.count, hmacResult)
        // 数据取最后一位的后8 bit作为偏移
        let hashData = Data(bytesNoCopy: hmacResult, count: HmacSHA[algorithm]!.capacity, deallocator: .none)
        let offset = Int(hashData.last ?? 0x00) & 0x0F
        // 取偏移和其后4 byte, 转为一个Int32, 再取后 [digits] 位
        let num = hashData.subdata(in: offset..<offset+4).reduce(0) {
            ($0 << 8) | Int($1)
        } & Int(Int32.max) % Int(pow(10, Float(digits)))
        hmacResult.deallocate()
        // 将数字转成字符串，不够位数往前面补0
        return String(format: "%0*u", digits, num)
    }

    /// 构建otpauth链接
    /// - Parameter params: otpauth参数
    public static func generateURL(_ params: Params) -> String {
        let label = params.issuer.count != 0 ? "\(params.issuer):\(params.remark)" : params.remark
        var query: [String] = []
        if params.issuer.count != 0 {
            query.append("issuer=\(params.issuer)")
        }
        if params.period != 30 {
            query.append("period=\(params.period)")
        }
        if params.algorithm != .sha1 {
            query.append("algorithm=\(params.algorithm.rawValue)")
        }
        if params.digits != 6 {
            query.append("digits=\(params.digits)")
        }
        if params.counter != 0 {
            query.append("counter=\(params.counter)")
        }
        
        query.insert("otpauth://\(params.factor.rawValue)/\(label)?secret=\(params.secret)", at: 0)

        return query.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    /// 解析totp链接参数
    /// - Parameter urlStr: totp链接
    public static func parseURL(_ urlStr: String) throws -> Params {
        guard let urlComponent = URLComponents(string: urlStr), let queryItems = urlComponent.queryItems else {
            throw ParseError.URL
        }
        var queryItemsDict: [String : String] = ["issuer":"","algorithm":"sha1","period":"30","digits":"6","counter":"0"]
        for queryItem in queryItems {
            queryItemsDict[queryItem.name] = queryItem.value ?? ""
        }
        guard let secret = queryItemsDict["secret"]?.trimmingCharacters(in: CharacterSet.whitespaces), secret.count != 0 else {
            throw ParseError.secret
        }
        let issuer = queryItemsDict["issuer"]!.trimmingCharacters(in: CharacterSet.whitespaces)
        let period: Int32 = Int32(queryItemsDict["period"]!) ?? 30
        let digits: Int32 = Int32(queryItemsDict["digits"]!) ?? 6
        let counter: Int32 = Int32(queryItemsDict["counter"]!) ?? 0
        let factor = Factor(rawValue: (urlComponent.host ?? "totp").lowercased()) ?? .totp
        let algorithm: Algorithm = Algorithm(rawValue: queryItemsDict["algorithm"]!.lowercased()) ?? .sha1
        let splitDS = urlComponent.path.dropFirst().split(separator: ":")
        let remark = (splitDS.count > 1 ? String(splitDS[1]) : String(splitDS[0])).trimmingCharacters(in: CharacterSet.whitespaces)
        
        return (factor, secret, issuer, remark, period, algorithm, digits, counter, issuer)
    }
    
    /// 时间点转bytes
    /// - Parameter tm: 时间点
    private static func time2Bytes(_ tm: Int) -> Data {
        return (0..<8).reversed().reduce((Data(repeating: 0, count: 8), tm)) {
            var d = $0.0
            d[$1] = UInt8($0.1 & 0xFF)
            return (d, $0.1 >> 8)
        }.0
    }
    
    /// 带缓存的base32解码
    /// - Parameter str: 需要解码的字符
    private static func base32Decode(str: String) -> Data? {
        if let b32 = base32Cache.object(forKey: str as NSString) as Data? {
            return b32
        }
        guard let b32 = str.base32Decode() else { return nil }
        base32Cache.setObject(b32 as NSData, forKey: str as NSString)
        return b32
    }
    private static func validateTime(time: Int) -> Bool {
        return (time > 0)
    }
}
