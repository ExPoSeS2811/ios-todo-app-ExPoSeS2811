//
//  DeadlineDatePicker.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 22.06.2023.
//

import UIKit

class DeadlineDatePicker: UIDatePicker {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        datePickerMode = .date
        locale = Locale(identifier: "ru_RU")
        preferredDatePickerStyle = .inline
        date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        minimumDate = Date()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
