//
//  configureDate.swift
//  ToDoAppSUI
//
//  Created by Gleb Rasskazov on 20.07.2023.
//

import Foundation

extension Date {
    func configureDate(format: String = "d MMMM yyyy") -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        dateFormatter.locale = Locale(identifier: "ru_RU")

        return dateFormatter.string(from: self)
    }
}
