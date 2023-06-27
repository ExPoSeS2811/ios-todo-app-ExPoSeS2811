//
//  SectionStackView.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 22.06.2023.
//

import UIKit

class SectionStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .horizontal
        spacing = 16
        alignment = .center
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
