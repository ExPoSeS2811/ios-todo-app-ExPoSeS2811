//
//  ImportanceSegmentControl.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 22.06.2023.
//

import UIKit

class ImportanceSegmentControl: UISegmentedControl {
    init() {
        super.init(frame: .zero)
        
        insertSegment(with: .low, at: 0, animated: true)
        insertSegment(withTitle: "нет", at: 1, animated: true)
        insertSegment(with: .important, at: 2, animated: true)
        selectedSegmentIndex = 1
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.subhead ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.primaryLabel
        ]
        
        setTitleTextAttributes(titleAttributes, for: .normal)
        tintColor = .elevatedBack
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
