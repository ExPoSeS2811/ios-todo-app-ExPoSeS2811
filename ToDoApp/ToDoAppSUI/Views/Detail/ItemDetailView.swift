//
//  ItemDetailView.swift
//  ToDoAppSUI
//
//  Created by Gleb Rasskazov on 20.07.2023.
//

import SwiftUI

struct ItemDetailView: View {
    @State var item: TodoItem?
    @State var isShowingSheet = false
    @State var text: String = "Что надо сделать?"
    @State private var selectedImportance = 1
    @State private var isShowingCalendar = true
    @State private var toggle = true
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    editor
                    infoBlock
                    deleteButton
                }
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 16)
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Сохранить") {}
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Отмена") {}
                }
            }
        }
    }

    @ViewBuilder
    var editor: some View {
        HStack {
            ZStack {
                if let item = item {
                    Text(item.text)
                        .font(.system(size: 17))
                        .foregroundColor(.primaryLabel)
                } else {
                    Text("Что надо сделать?")
                        .font(.system(size: 17))
                        .foregroundColor(.tertiaryLabel)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 81)

            Spacer()
        }
        .background(.secondaryBack)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    var infoBlock: some View {
        VStack {
            HStack {
                Text("Важность")
                Spacer()
                Picker("", selection: $selectedImportance) {
                    Image("low")
                    Text("нет")
                        .foregroundColor(.primaryLabel)
                    Image("high")
                }
                .pickerStyle(.segmented)
                .disabled(true)
                .frame(width: 150)
            }
            .padding(.vertical, 10)

            Divider()

            HStack {
                VStack(alignment: .leading) {
                    Text("Сделать до")
                    Button {
                        isShowingCalendar.toggle()
                    } label: {
                        Text(Date().configureDate())
                            .font(.system(size: 13)).bold()
                            .foregroundColor(.blueDisplay)
                    }
                }

                Toggle(isOn: $toggle, label: {})
                    .disabled(true)

                Spacer()
            }
            .padding(.vertical, 10)
            if isShowingCalendar {
                Divider()
                VStack {
                    DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                        .labelsHidden()
                        .disabled(true)
                        .datePickerStyle(.graphical)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(.secondaryBack)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    var deleteButton: some View {
        Button {} label: {
            Spacer()
            Text("Удалить")
                .foregroundColor(.redDisplay)
            Spacer()
        }
        .padding(16)
        .background(.secondaryBack)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ItemDetailView(item: nil)
}
