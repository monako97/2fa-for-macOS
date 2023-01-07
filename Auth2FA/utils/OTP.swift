//
//  OTP.swift
//  moneko
//
//  Created by neko Mo on 2022/12/29.
//

import Foundation
import CommonCrypto

func getTimeRemaining(period: Int) -> Int {
    if period == 0 {
        return period
    }
    return period - (Int(Date().timeIntervalSince1970) % period)
}

public enum Algorithm: String {
    case SHA1 = "sha1", SHA256 = "sha256", SHA512 = "sha512"
}
public enum Factor: String, CaseIterable {
    case totp = "totp", hotp = "hotp"
}
public func parseGenerateParamsOnItem(_ item: Item) -> OTP.GenerateParams {
    return (factor: Factor(rawValue: item.factor ?? "totp") ?? .totp, secret: item.secret ?? "", period: item.period , algorithm: Algorithm(rawValue: item.algorithm ?? "sha1") ?? .SHA1, digits: item.digits , counter: item.counter)
}
public func parseURLParamsOnItem(_ item: Item) -> OTP.URLParams {
    return (factor: Factor(rawValue: item.factor ?? "totp") ?? .totp, secret: item.secret ?? "", issuer: item.issuer ?? "", remark: item.remark ?? "", period: item.period , algorithm: Algorithm(rawValue: item.algorithm ?? "sha1") ?? .SHA1, digits: item.digits , counter: item.counter)
}
/// 非标准TOTP算法, 省略很多参数, 只针对于Google Authoricator使用的部分
/// 主要参考:
///     - https://github.com/google/google-authenticator-libpam/blob/master/src/google-authenticator.c
///     - https://github.com/google/google-authenticator/wiki/Key-Uri-Format
public class OTP {
    public typealias URLParams = (factor: Factor, secret: String, issuer: String, remark: String, period: Int32, algorithm: Algorithm, digits: Int32, counter: Int32)
    public typealias GenerateParams = (factor: Factor, secret: String, period: Int32, algorithm: Algorithm, digits: Int32, counter: Int32)

//    public static func parseTOTP(_ item: Item) throws -> TOTP {
//
//    }
    /// 解析的错误
    public enum ParseError: Error {
        case URL,secret,type,algorithm
    }
    
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
    public static func generateCode(params: GenerateParams) -> String? {
        var key: [Data.Element] = []
        var data: [Data.Element] = []
        let algorithm = params.algorithm
        let digits = params.digits
        
        if params.factor == .hotp {
            key = Data(hex: params.secret).map{ $0 }
            data = Int(params.counter).bigEndian.data.map { $0 }
        } else {
            guard validateTime(time: params.period) else { return nil }
            guard let _key = base32Decode(str: params.secret) else { return nil }
            key = _key.map { $0 }
            let tm = Int(Date().timeIntervalSince1970) / Int(params.period)
            data = time2Bytes(tm).map { $0 }
        }
        var capacity: Int32 = CC_SHA1_DIGEST_LENGTH
        var hmacAlgorithm: Int = kCCHmacAlgSHA1
        switch algorithm {
            case .SHA1:
                capacity = CC_SHA1_DIGEST_LENGTH
                hmacAlgorithm = kCCHmacAlgSHA1
                break;
            case .SHA256:
                capacity = CC_SHA256_DIGEST_LENGTH
                hmacAlgorithm = kCCHmacAlgSHA256
                break;
            case .SHA512:
                capacity = CC_SHA512_DIGEST_LENGTH
                hmacAlgorithm = kCCHmacAlgSHA512
                break;
        }
        // 数据进行hmac sha hash
        let hmacResult = UnsafeMutablePointer<CChar>.allocate(capacity: Int(capacity))
        CCHmac(CCHmacAlgorithm(hmacAlgorithm), key, key.count, data, data.count, hmacResult)
        // 数据取最后一位的后8 bit作为偏移
        let hashData = Data(bytesNoCopy: hmacResult, count: Int(capacity), deallocator: .none)
        let offset = Int(hashData.last ?? 0x00) & 0x0F
        // 取偏移和其后4 byte, 转为一个Int32, 再取后 [digits] 位
        let num = hashData.subdata(in: offset..<offset+4).reduce(0) {
            ($0 << 8) | Int($1)
        } & Int(Int32.max) % Int(pow(10, Float(digits)))

        hmacResult.deallocate()
        // 将数字转成字符串，不够位数往前面补0
        return String(format: "%0*u", digits, num)
    }

    public static func genCode(factor: Factor = .totp, secret: String, period: Int32 = 30, algorithm: Algorithm = .SHA1, digits: Int32 = 6, counter: Int32 = 0) -> String? {
        return generateCode(params: GenerateParams(factor, secret, period, algorithm, digits, counter))
    }
    /// 构建otpauth链接
    /// - Parameter params: otpauth参数
    public static func generateURL(_ params: URLParams) -> String {
        var label = params.remark
        var query: [String] = []
        if params.issuer.count != 0 {
            query.insert("issuer=\(params.issuer)", at: query.endIndex)
            label = "\(params.issuer):" + params.remark
        }
        if params.period != 30 {
            query.insert("period=\(params.period)", at: query.endIndex)
        }
        if params.algorithm != .SHA1 {
            query.insert("algorithm=\(params.algorithm.rawValue)", at: query.endIndex)
        }
        if params.digits != 6 {
            query.insert("digits=\(params.digits)", at: query.endIndex)
        }
        if params.counter != 0 {
            query.insert("counter=\(params.counter)", at: query.endIndex)
        }
        query.insert("otpauth://\(params.factor.rawValue.lowercased())/\(label)?secret=\(params.secret)", at: 0)
        return query.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
    }
    
    /// 解析totp链接参数
    /// - Parameter urlStr: totp链接
    public static func parseURL(_ urlStr: String) throws -> URLParams {
        guard let urlComponent = URLComponents(string: urlStr), let queryItems = urlComponent.queryItems else {
            throw ParseError.URL
        }
        guard let factor: Factor = Factor(rawValue: (urlComponent.host?.lowercased() ?? "totp")), [.totp,.hotp].contains(factor) else {
            throw ParseError.type
        }
        let queryItemsDict = queryItems.reduce(into: [String: String]()) {
            $0[$1.name] = $1.value ?? ""
        }
        guard let secret = queryItemsDict["secret"], secret.count != 0 else {
            throw ParseError.secret
        }
        let issuer = queryItemsDict["issuer"]?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
        let period: Int32 = Int32(queryItemsDict["period"] ?? "30") ?? 30
        let algorithm: Algorithm = Algorithm(rawValue: queryItemsDict["algorithm"]?.lowercased() ?? "sha1") ?? .SHA1
        let digits: Int32 = Int32(queryItemsDict["digits"] ?? "6") ?? 6
        let counter: Int32 = Int32(queryItemsDict["counter"] ?? "0") ?? 0
        let ds = urlComponent.path.dropFirst()
        let splitDS = ds.split(separator: ":")
        let remark = (splitDS.count > 1 ? String(splitDS[1]) : String(splitDS[0])).trimmingCharacters(in: CharacterSet.whitespaces)
        
        return URLParams(factor, secret, issuer, remark, period, algorithm, digits, counter)
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
    private static func validateTime(time: Int32) -> Bool {
        return (time > 0)
    }
}
