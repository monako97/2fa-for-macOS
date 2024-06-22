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
