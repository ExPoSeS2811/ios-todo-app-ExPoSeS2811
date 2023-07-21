//
//  ItemListView.swift
//  ToDoAppSUI
//
//  Created by Gleb Rasskazov on 20.07.2023.
//

import SwiftUI

struct ItemListView: View {
    @State var items: [TodoItem]
    @State var isShow = false
    @State var isShowModal = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack {
                    List {
                        Section {
                            let sortedItems = items.sorted(by: { $0.createdAt < $1.createdAt })
                            let completedItems = sortedItems.filter { $0.isDone }
                            let uncompletedItems = sortedItems.filter { !$0.isDone }
                            let currentItems = isShow ? completedItems + uncompletedItems : uncompletedItems
                            ForEach(currentItems) { item in
                                if item.isNew {
                                    ZStack(alignment: .leading) {
                                        NavigationLink {} label: {}
                                            .opacity(0)
                                        Text("Новое")
                                            .padding(.leading, 32)
                                            .padding([.top, .bottom], 9)
                                            .foregroundColor(Color.tertiaryLabel)
                                    }
                                    .listRowBackground(Color.secondaryBack)

                                } else {
                                    NavigationLink {
                                        ItemDetailView(item: item)
                                    } label: {
                                        ItemCellView(item: item)
                                            .modifier(SwipeActionsModifier(item: item, items: $items))
                                    }
                                    .listRowBackground(Color.secondaryBack)
                                }
                            }
                        } header: {
                            StatusView(items: $items, status: $isShow)
                                .padding(.bottom, 6)
                        }
                    }
                }
                AddButtonView(modal: $isShowModal)
            }
            .navigationBarTitle("Мои дела")
        }
        .sheet(isPresented: $isShowModal) {
            ItemDetailView()
                .presentationBackground(.primaryBack)
        }
    }
}

#Preview {
    ItemListView(items: TodoItem.getItems())
}
