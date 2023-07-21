//
//  ContentView.swift
//  ToDoAppSUI
//
//  Created by Gleb Rasskazov on 19.07.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ItemListView(items: TodoItem.getItems())
    }
}

#Preview {
    ContentView()
}
