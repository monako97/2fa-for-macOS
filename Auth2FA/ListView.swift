//
//  ListView.swift
//  moneko
//
//  Created by neko Mo on 2022/12/29.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject private var time: TimeModel
    @EnvironmentObject private var app: AppModel
    @FocusState private var focused: Bool
    @State private var query = ""
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.objectID, ascending: true)],
        predicate: nil,
        animation: .default.speed(450)
    )
    private var items: FetchedResults<Item>

    var body: some View {
        ZStack (alignment: .topLeading) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search...", text: $query)
                    .focused($focused)
                    .textFieldStyle(.plain)
                    .task(id: query, priority: .background) {
                        items.nsPredicate = query.isEmpty ? nil : NSPredicate(format: "issuer CONTAINS[c] %@ OR remark CONTAINS[c] %@ OR factor CONTAINS[c] %@", query, query, query)
                    }
                
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background(Color.accentColor.opacity(0.05))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .cornerRadius(8)
            .font(.subheadline)
            .padding(.top, 10)
            .padding(.horizontal)
            .zIndex(1)
            
            ScrollView (showsIndicators: false) {
                LazyVStack {
                    ForEach(items) { item in
                        CodeItemView(item)
                    }
                }
                .padding(.top, 35)
                .padding(15)
            }
        }
        .task(id: app.currentTab, priority: .background) {
            focused = false
            app.currentTab == .list ? time.start() : time.timerCancel.cancelAll()
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
