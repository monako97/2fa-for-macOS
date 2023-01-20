//
//  Auth2FAManaged.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/2.
//
import SwiftUI

public typealias PutItem = (remark: String,counter: Int,period: Int,issuer: String, icon: String?)
class Auth2FAManaged {
    private static let viewContext = PersistenceController.shared.container.viewContext
    
//    public static func object(with: NSManagedObjectID) -> Item {
//        return viewContext.object(with: with) as! Item
//    }
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
    
    public static func add(_ item: OTP.Params) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.secret = item.secret
            newItem.remark = item.remark
            newItem.issuer = item.issuer
            newItem.period = item.period
            newItem.algorithm = String(describing: item.algorithm)
            newItem.factor = String(describing: item.factor)
            newItem.digits = item.digits
            newItem.counter = item.counter
            newItem.icon = item.icon
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                NSLog("添加失败: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    public static func delete(_ obj: NSManagedObject) {
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
    public static func put(_ with: NSManagedObjectID, _ newItem: PutItem) {
        let item = viewContext.object(with: with) as! Item
        
        withAnimation {
            item.remark = newItem.remark
            item.issuer = newItem.issuer
            item.counter = Int32(newItem.counter)
            item.period = Int32(newItem.period)
            item.icon = newItem.icon
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                NSLog("修改失败: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
