//
//  TaskTableViewCell.swift
//  test
//
//  Created by Gleb Rasskazov on 26.06.2023.
//

import UIKit
import MyLibrary

protocol TaskTableViewCellDelegate {
    func didEditingStatusButton(source: UIButton)
}

class TaskTableViewCell: UITableViewCell {
    lazy var outerStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        
        return stackView
    }()
    
    lazy var statusButton: UIButton = {
        let button = UIButton()
        
        button.setImage(State.normal.image, for: .normal)
        button.addTarget(self, action: #selector(changeState), for: .touchUpInside)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        
        return button
    }()
    
    lazy var innerStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 2
        
        return stackView
    }()
    
    lazy var importanceImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.isHidden = true
        
        return imageView
    }()
    
    lazy var descriptionTaskStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        
        return stackView
    }()
    
    lazy var deadlineTaskStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.isHidden = true
        stackView.axis = .horizontal
        
        return stackView
    }()
    
    lazy var descriptionTaskLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Задание"
        label.numberOfLines = 3
        
        return label
    }()
    
    lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 3
        label.textColor = .tertiaryLabel
        label.font = .subhead
        
        return label
    }()
    
    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(systemName: "chevron.right") ?? UIImage.actions
        imageView.contentMode = .center
        imageView.tintColor = UIColor.grayDisplay
        
        return imageView
    }()
    
    var delegate: TaskTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets(top: 0, left: statusButton.frame.width + 56, bottom: 0, right: 0) // (16 + 12) * 2
        contentView.isUserInteractionEnabled = true
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .secondaryBack
        addSubviews([outerStackView, innerStackView])
        outerStackView.addArrangedSubviews([statusButton, innerStackView])
        innerStackView.addArrangedSubviews([importanceImageView, descriptionTaskStackView, UIView(), arrowImageView])
        descriptionTaskStackView.addArrangedSubviews([descriptionTaskLabel, deadlineTaskStackView])
        let calendarImageView = UIImageView(image: UIImage(systemName: "calendar")?.withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal))
        calendarImageView.contentMode = .scaleAspectFit
        calendarImageView.clipsToBounds = true
        deadlineTaskStackView.addArrangedSubviews([calendarImageView, deadlineLabel])
    
        setupConstraints()
    }
    
    private func setupConstraints() {
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            outerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            outerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            outerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            outerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
        
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusButton.heightAnchor.constraint(equalToConstant: 24),
            statusButton.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    func set(with item: TodoItem) {
        if let deadline = item.deadline {
            deadlineTaskStackView.isHidden = false
            deadlineLabel.text = configureDate(with: deadline)
        } else {
            deadlineTaskStackView.isHidden = true
            deadlineLabel.text = ""
        }
        
        if item.importance == .high || item.importance == .low {
            if item.importance == .high {
                importanceImageView.image = UIImage.high
            } else {
                importanceImageView.image = UIImage.low
            }
            importanceImageView.isHidden = false
            if item.isDone {
                statusButton.setImage(State.done.image, for: .normal)
                let attributedText = NSAttributedString(string: item.text, attributes: [
                    NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    NSAttributedString.Key.foregroundColor: UIColor.tertiaryLabel

                ])
                descriptionTaskLabel.attributedText = attributedText
                if let deadline = item.deadline {
                    deadlineTaskStackView.isHidden = false
                    deadlineLabel.text = configureDate(with: deadline)
                } else {
                    deadlineTaskStackView.isHidden = true
                    deadlineLabel.text = ""
                }
                

            } else {
                statusButton.setImage(item.importance == .high ? State.critical.image : State.normal.image, for: .normal)
                let attributedText = NSAttributedString(string: item.text)
                descriptionTaskLabel.attributedText = attributedText
                if let deadline = item.deadline {
                    deadlineTaskStackView.isHidden = false
                    deadlineLabel.text = configureDate(with: deadline)
                } else {
                    deadlineTaskStackView.isHidden = true
                    deadlineLabel.text = ""
                }
                
            }
        } else {
            importanceImageView.image = nil
            if item.isDone {
                statusButton.setImage(State.done.image, for: .normal)
                let attributedText = NSAttributedString(string: item.text, attributes: [
                    NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    NSAttributedString.Key.foregroundColor: UIColor.tertiaryLabel
                ])
                descriptionTaskLabel.attributedText = attributedText
            } else {
                statusButton.setImage(State.normal.image, for: .normal)
                let attributedText = NSAttributedString(string: item.text)
                descriptionTaskLabel.attributedText = attributedText
            }
        }
        
        if let color = item.textColor {
            descriptionTaskLabel.textColor = UIColor.colorFromHex(color)
        }
    }
        
    private func configureDate(with date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "d MMMM"
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        return dateFormatter.string(from: date)
    }
    
    @objc private func changeState(_ sender: UIButton) {
        print("Tapped")
        delegate?.didEditingStatusButton(source: sender)
    }
}

enum State {
    case critical, normal, done
    
    var image: UIImage {
        switch self {
        case .normal: return UIImage(systemName: "circle")?.withTintColor(.separatorSupport, renderingMode: .alwaysOriginal) ?? UIImage.add
        case .critical: return UIImage.prop
        case .done: return UIImage.done
        }
    }
}
