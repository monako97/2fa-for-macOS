//
//  Auth2FAManaged.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/2.
//
import SwiftUI

class Auth2FAManaged {
    private static let viewContext = PersistenceController.shared.container.viewContext
    
    public static func object(with: NSManagedObjectID) -> Item {
        return viewContext.object(with: with) as! Item
    }
//    public static func search(remark: String? = nil, period: Int? = nil, algorithm: String? = nil, issuer: String? = nil) -> [Item] {
//        // 设置查询的实体
//        let entity = NSEntityDescription.entity(forEntityName: "Item", in: viewContext)
//        // 请求实体
//        let request = NSFetchRequest<Item>()
//        request.entity = entity
//        request.sortDescriptors = []
//        // 设置查询条件
//        var format: [String] = []
//        var variables: [String: Any] = [:]
//        if remark != nil {
//            format.insert("remark CONTAINS $remark", at: format.endIndex)
//            variables.updateValue(remark!, forKey: "remark")
//        }
//        if period != nil {
//            format.insert("period >= $period", at: format.endIndex)
//            variables.updateValue(period!, forKey: "period")
//        }
//        if algorithm != nil {
//            format.insert("algorithm == $algorithm", at: format.endIndex)
//            variables.updateValue(algorithm!, forKey: "algorithm")
//        }
//        if issuer != nil {
//            format.insert("issuer CONTAINS $issuer", at: format.endIndex)
//            variables.updateValue(issuer!, forKey: "issuer")
//        }
//        if variables.isEmpty == false {
//            let predicate = NSPredicate(format: format.joined(separator: " AND "))
//            request.predicate = predicate.withSubstitutionVariables(variables)
//        }
//        do {
//            let results = try viewContext.fetch(request)
//
//            return results
//        } catch  {
//            print("读取数据失败")
//            return []
//        }
//    }
    
    public static func add(factor: Factor = .totp, secret: String, remark: String, issuer: String, period: Int = 30, algorithm: Algorithm = .SHA1, digits: Int = 6, counter: Int = 0) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.secret = secret
            newItem.remark = remark
            newItem.issuer = issuer
            newItem.period = Int32(period)
            newItem.algorithm = String(describing: algorithm)
            newItem.factor = String(describing: factor)
            newItem.digits = Int32(digits)
            newItem.counter = Int32(counter)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                NSLog("添加失败: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    public static func delete(obj: NSManagedObject) {
        withAnimation {
            viewContext.delete(obj)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                
                NSLog("删除失败: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    public static func put(with: NSManagedObjectID, remark: String, issuer: String, counter: Int = 0, period: Int = 30) {
        let item = object(with: with)
        
            withAnimation {
                item.remark = remark
                item.issuer = issuer
                item.counter = Int32(counter)
                item.period = Int32(period)
                
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    NSLog("修改失败: \(nsError), \(nsError.userInfo)")
                }
            }
    }
}
