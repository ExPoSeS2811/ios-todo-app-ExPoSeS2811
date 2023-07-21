//
//  StatusView.swift
//  ToDoAppSUI
//
//  Created by Gleb Rasskazov on 20.07.2023.
//

import SwiftUI

struct StatusView: View {
    @Binding var items: [TodoItem]
    @Binding var status: Bool
    
    var body: some View {
        HStack {
            Text("Выполнено - \(items.filter({ $0.isDone }).count)")
                .font(.subheadline)
                .foregroundColor(Color.tertiaryLabel)
                .textCase(nil)
            Spacer()
            Button(status ? "Скрыть" : "Показать") {
                status.toggle()
            }
            .textCase(nil)
            .fontWeight(.semibold)
        }
    }
}

