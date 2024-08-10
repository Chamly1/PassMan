//
//  ToolbarMenu.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 07.08.2024.
//

import SwiftUI

struct ToolbarMenu: View {
    @Binding var sortOption: SortingOptions
    @Binding var sortOrder: SortingOrders
    
    var body: some View {
        Menu(content: {
            Menu(content: {
                Picker("Sort By", selection: $sortOption) {
                    ForEach(SortingOptions.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                Divider()
                Picker("Order", selection: $sortOrder) {
                    ForEach(SortingOrders.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
            }, label: {
                Label {
                    // No other working ways to fit two lines in one Menu's label
                    Button(action: {}) {
                        Text("Sort By")
                        Text(sortOption.rawValue)
                    }
                } icon: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            })
            Button(action: {
                
            }, label: {
                Label("Settings", systemImage: "gear")
            })
        }, label: {
            Image(systemName: "ellipsis")
        })
    }
}
