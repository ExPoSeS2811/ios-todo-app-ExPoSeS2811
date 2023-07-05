//
//  DescriptionTextView.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 22.06.2023.
//

import UIKit

class DescriptionTextView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        isScrollEnabled = false
        backgroundColor = .secondaryBack
        layer.cornerRadius = 16

        text = "Что надо сделать?"
        font = .body
        adjustsFontForContentSizeCategory = true
        textColor = .tertiaryLabel
        textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
