//
//  ItemCellView.swift
//  ToDoAppSUI
//
//  Created by Gleb Rasskazov on 20.07.2023.
//

import SwiftUI

struct ItemCellView: View {
    var item: TodoItem
    var body: some View {
        HStack {
            Button(action: {}, label: {
                configureImage()
                    .foregroundColor(.tertiaryLabel)
                    .frame(width: 24, height: 24)
            })

            VStack(alignment: .leading) {
                Text(item.text)
                    .lineLimit(3)
                    .strikethrough(item.isDone ? true : false)
                    .foregroundColor(item.isDone ? .tertiaryLabel : .primary)
                if let deadline = item.deadline,
                   !item.isDone
                {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.tertiaryLabel)
                        Text(deadline.configureDate(format: "d MMMM"))
                            .foregroundColor(.tertiaryLabel)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding([.top, .bottom], 8)
    }

    private func configureImage() -> Image {
        if !item.isDone {
            switch item.importance {
            case .low, .basic:
                return Image(systemName: "circle").resizable()
            case .important:
                return Image("important").resizable()
            }
        } else {
            return Image("done").resizable()
        }
    }
}

#Preview {
    ItemCellView(item: TodoItem(text: "Some task", importance: .important))
}
