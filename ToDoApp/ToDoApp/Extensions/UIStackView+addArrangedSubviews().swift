//
//  UIStackView+addArrangedSubviews().swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 20.06.2023.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { self.addArrangedSubview($0) }
    }
}
