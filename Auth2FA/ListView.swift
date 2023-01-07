//
//  ListView.swift
//  moneko
//
//  Created by neko Mo on 2022/12/29.
//

import SwiftUI

struct ListView: View {
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        ScrollView {
            ForEach(items) { item in
                CodeItemView(item: item)
            }
            .padding(15)
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
