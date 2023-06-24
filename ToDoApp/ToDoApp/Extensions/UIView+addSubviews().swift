//
//  Extensions.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 20.06.2023.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
}
