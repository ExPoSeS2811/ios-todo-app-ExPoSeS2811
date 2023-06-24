//
//  DeleteButton.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 22.06.2023.
//

import UIKit

class DeleteButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        isEnabled = false
        layer.cornerCurve = .continuous
        backgroundColor = .secondaryBack
        setTitle("Удалить", for: .normal)
        titleLabel?.font = UIFont.body
        setTitleColor(.redDisplay, for: .normal)
        setTitleColor(.tertiaryLabel, for: .disabled)
        contentEdgeInsets = UIEdgeInsets(top: 17, left: 0, bottom: 17, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
