//
//  AddButtonView.swift
//  ToDoAppSUI
//
//  Created by Gleb Rasskazov on 20.07.2023.
//

import SwiftUI

struct AddButtonView: View {
    @Binding var modal: Bool
    var body: some View {
        Button(action: {
            modal = true
        }, label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 44, height: 44)
        })
    }
}

