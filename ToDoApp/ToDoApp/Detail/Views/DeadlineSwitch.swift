//
//  DeadlineSwitch.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 22.06.2023.
//

import UIKit

class DeadlineSwitch: UISwitch {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        thumbTintColor = .whiteDisplay
        backgroundColor = .overlaySupport
        
        layer.cornerRadius = 16
        layer.opacity = 1
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
