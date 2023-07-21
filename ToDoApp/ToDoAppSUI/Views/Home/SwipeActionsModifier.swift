//
//  SwipeActionsModifier.swift
//  ToDoAppSUI
//
//  Created by Gleb Rasskazov on 20.07.2023.
//

import Foundation
import SwiftUI

struct SwipeActionsModifier: ViewModifier {
    var item: TodoItem
    @Binding var items: [TodoItem]
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                guard let index = items.firstIndex(of: item) else {
                    return
                }
                items.remove(at: index)
            } label: {
                Label(
                    title: { Text("Delete") },
                    icon: { Image(systemName: "trash") }
                )
                .tint(.redDisplay)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                guard let index = items.firstIndex(of: item) else {
                    return
                }
                items[index].isDone.toggle()
            } label: {
                Label(
                    title: { Text("Done") },
                    icon: { Image(systemName: "checkmark.circle.fill") }
                )
                .tint(.greenDisplay)
            }
        }

    }
}
