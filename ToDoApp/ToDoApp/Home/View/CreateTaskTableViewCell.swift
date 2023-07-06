//
//  CreateTaskTableViewCell.swift
//  test
//
//  Created by Gleb Rasskazov on 27.06.2023.
//

import UIKit

class CreateTaskTableViewCell: UITableViewCell {
    lazy var createStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        
        return stackView
    }()
    
    lazy var createImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
                
        return imageView
    }()
    
    lazy var createTextLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Новое"
        label.textColor = UIColor(red: 0, green: 0.47, blue: 1, alpha: 1)
        
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .secondaryBack
        addSubview(createStackView)
        createStackView.addArrangedSubview(createImageView)
        createStackView.addArrangedSubview(createTextLabel)
        setupConstraints()
    }
    
    private func setupConstraints() {
        createStackView.translatesAutoresizingMaskIntoConstraints = false
        createImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createImageView.widthAnchor.constraint(equalToConstant: 24),
            createImageView.heightAnchor.constraint(equalToConstant: 24),
            createStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            createStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            createStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            createStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

}
