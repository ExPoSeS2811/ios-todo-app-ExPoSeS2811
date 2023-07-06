//
//  ViewController.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 16.06.2023.
//

import UIKit
import MyLibrary

class DetailViewController: UIViewController {
    // MARK: - GUI variables

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize = view.bounds.size
        
        return scrollView
    }()
    
    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Сохранить",
            image: nil,
            target: self,
            action: #selector(saveAction)
        )
        let attributesForSave: [NSAttributedString.Key: Any] = [
            .font: UIFont.headline ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.blueDisplay
        ]
        
        button.isEnabled = isModified
        button.setTitleTextAttributes(attributesForSave, for: .normal)
        
        return button
    }()
    
    lazy var textView: UITextView = {
        let textView = DescriptionTextView()
        
        textView.delegate = self

        return textView
    }()
    
    lazy var storedStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 10

        stackView.layer.cornerRadius = 16
        stackView.layer.cornerCurve = .continuous
        
        stackView.backgroundColor = .secondaryBack
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        return stackView
    }()
    
    lazy var importanceStackView: UIStackView = SectionStackView()
    
    lazy var importanceLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Важность"
        label.font = .body
        label.textColor = .primaryLabel
        
        return label
    }()
    
    lazy var importanceSegmentedControl: UISegmentedControl = {
        let segment = ImportanceSegmentControl()
        
        segment.addTarget(self, action: #selector(selectedSectionSegmented), for: .valueChanged)
        
        return segment
    }()
    
    lazy var firstLine: UIView = {
        let view = UIView()

        view.backgroundColor = .separatorSupport
        
        return view
    }()
    
    lazy var colorStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 8
        
        return stackView
    }()
    
    lazy var innerColorStackView: UIStackView = SectionStackView()
    
    lazy var colorLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Цвет текста"
        label.font = .body

        return label
    }()
    
    lazy var hexLabel: UILabel = {
        let label = UILabel()
        
        label.text = UIColor.primaryLabel.toHex()
        label.font = .body
        
        return label
    }()
    
    lazy var colorResult: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .primaryLabel
        button.layer.cornerRadius = 13
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: #selector(setInvisibleColorPicker), for: .touchUpInside)

        return button
    }()
    
    lazy var colorPicker: ColorPicker = {
        let picker = ColorPicker()
        
        picker.delegate = self
        picker.isHidden = true
        
        return picker
    }()
    
    lazy var sliderBrightness: UISlider = {
        let slider = UISlider()
        
        slider.minimumValue = 0.0041079456
        slider.maximumValue = 1
        slider.isHidden = true
        slider.value = Float(colorResult.backgroundColor?.brightness ?? 1)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

        return slider
    }()
    
    lazy var secondLine: UIView = {
        let view = UIView()

        view.backgroundColor = .separatorSupport
        
        return view
    }()
    
    lazy var deadlineStackView: UIStackView = SectionStackView()
    
    lazy var innerDeadlineStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.alignment = .leading

        return stackView
    }()
    
    lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Сделать до"
        label.font = .body

        return label
    }()
    
    lazy var dateButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.addTarget(self, action: #selector(switchInvisibleDatePicker), for: .touchUpInside)
        button.titleLabel?.font = .footnote
        
        return button
    }()

    lazy var deadlineSwitch: UISwitch = {
        let switchControl = DeadlineSwitch()
        
        switchControl.addTarget(self, action: #selector(deadlineSwitchValueChanged), for: .valueChanged)

        return switchControl
    }()
    
    lazy var calendarPicker: UIDatePicker = {
        let datePicker = DeadlineDatePicker()
        
        dateButton.setTitle(datePicker.date.configureDate(), for: .normal)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        return datePicker
    }()

    lazy var deleteButton: UIButton = {
        let button = DeleteButton()
        
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        button.isEnabled = textView.text != "Что надо сделать?" && textView.textColor != .tertiaryLabel && !textView.text.isEmpty
        
        return button
    }()
    
    lazy var thirdLine: UIView = {
        let view = UIView()
        
        view.backgroundColor = .separatorSupport
        
        return view
    }()

    // MARK: - Properties

    private let importanceValues = Importance.allCases
    private let edgesSize: CGFloat = 16
    private var isModified = false {
        didSet {
            saveButton.isEnabled = isModified
        }
    }
    
    private var savedText = ""
    private var currentTaskId = ""
    private var currentItem: TodoItem?
    var completionHandler: ((TodoItem?) -> Void)?
    private var textViewBottomConstraint: NSLayoutConstraint?
    private var scrollViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primaryBack
        setupUI()
        updateSettingsForCurrentTheme()
        updateLayoutForOrientationChange()
    }
    
    init(currentItem: TodoItem?) {
        self.currentItem = currentItem
        super.init(nibName: nil, bundle: nil)
        setupDataFromItem(item: currentItem)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Update label text when the theme changes
        updateSettingsForCurrentTheme()
    }
    
    // MARK: Private methods

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubviews([textView, storedStackView, deleteButton])
        storedStackView.addArrangedSubviews([importanceStackView, firstLine, colorStackView, secondLine, deadlineStackView, thirdLine, calendarPicker])
        importanceStackView.addArrangedSubviews([importanceLabel, importanceSegmentedControl])
        colorStackView.addArrangedSubviews([innerColorStackView, colorPicker, sliderBrightness])
        innerColorStackView.addArrangedSubviews([colorLabel, hexLabel, colorResult])
        deadlineStackView.addArrangedSubviews([innerDeadlineStackView, deadlineSwitch])
        innerDeadlineStackView.addArrangedSubviews([deadlineLabel, dateButton])
        visibilitySetting(isDateHidden: true, isCalendarHidden: true)
        
        setupNavigationBar()
        setupConstraints()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        recognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(recognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateKeyboardLayoutGuideConstraint()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardLayoutGuideConstraint()
    }
    
    private func setupNavigationBar() {
        self.title = "Дело"
        
        let attributesForTitle: [NSAttributedString.Key: Any] = [
            .font: UIFont.headline ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.primaryLabel
        ]
        navigationController?.navigationBar.titleTextAttributes = attributesForTitle
        
        let cancelButton = UIBarButtonItem(
            title: "Отмена",
            image: nil,
            target: self,
            action: #selector(cancelAction)
        )
        let attributesForCancel: [NSAttributedString.Key: Any] = [
            .font: UIFont.body ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.blueDisplay
        ]
        
        cancelButton.setTitleTextAttributes(attributesForCancel, for: .normal)
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setupConstraints() {
        scrollViewConstraints()
        textViewConstraints()
        storedStackViewConstraints()
        deleteButtonConstraints()
        [firstLine, thirdLine, secondLine].forEach { $0.heightAnchor.constraint(equalToConstant: 1).isActive = true }
        colorResultConstraint()
    }

    private func scrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        scrollViewBottomConstraint = bottomConstraint
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomConstraint
        ])
    }
    
    private func textViewConstraints() {
        let bottomConstraint: NSLayoutConstraint = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        
        textViewBottomConstraint = bottomConstraint

        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: edgesSize),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: edgesSize),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -edgesSize),
            textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * edgesSize),
            bottomConstraint
        ])
    }
    
    private func removeKeyboardLayoutGuideConstraint() {
        scrollViewBottomConstraint?.isActive = false
        scrollViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        scrollViewBottomConstraint?.isActive = true
    }
    
    private func updateKeyboardLayoutGuideConstraint() {
        scrollViewBottomConstraint?.isActive = false
        scrollViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        scrollViewBottomConstraint?.isActive = true
    }
    
    private func removeTextViewConstraint() {
        textViewBottomConstraint?.isActive = false
        textViewBottomConstraint = textView.heightAnchor.constraint(equalToConstant: view.bounds.height)
        textViewBottomConstraint?.isActive = true
    }
    
    private func updateTextViewConstraint() {
        textViewBottomConstraint?.isActive = false
        textViewBottomConstraint = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        textViewBottomConstraint?.isActive = true
    }
    
    private func storedStackViewConstraints() {
        storedStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storedStackView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: edgesSize),
            storedStackView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            storedStackView.trailingAnchor.constraint(equalTo: textView.trailingAnchor)
        ])
    }
    
    private func colorResultConstraint() {
        colorResult.widthAnchor.constraint(equalToConstant: 26).isActive = true
        colorResult.heightAnchor.constraint(equalToConstant: 26).isActive = true
        colorPicker.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    private func deleteButtonConstraints() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: storedStackView.bottomAnchor, constant: edgesSize),
            deleteButton.leadingAnchor.constraint(equalTo: storedStackView.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: storedStackView.trailingAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -edgesSize)
        ])
    }

    private func setupDataFromItem(item: TodoItem?) {
        guard let item = item else { return }
        currentTaskId = item.id
        
        textView.text = item.text
        textView.textColor = UIColor.primaryLabel
        
        importanceSegmentedControl.selectedSegmentIndex = getIndex(by: item.importance)
        if let deadline = item.deadline {
            deadlineSwitch.isOn = true
            dateButton.setTitle(deadline.configureDate(), for: .normal)
            calendarPicker.date = deadline
            visibilitySetting(isDateHidden: false, isCalendarHidden: true)
        }
        if let textColor = item.textColor {
            hexLabel.text = textColor
            textView.textColor = UIColor.colorFromHex(textColor) ?? UIColor.primaryLabel
            colorResult.backgroundColor = UIColor.colorFromHex(textColor) ?? UIColor.primaryLabel
        }
        
        sliderBrightness.value = Float(colorResult.backgroundColor?.brightness ?? 0)
    }

    private func getIndex(by importance: Importance) -> Int {
        return importanceValues.firstIndex(of: importance) ?? 1
    }
    
    private func getImportance(by selectedSegmentIndex: Int) -> Importance {
        return importanceValues[selectedSegmentIndex]
    }
    
    private func visibilitySetting(isDateHidden: Bool, isCalendarHidden: Bool) {
        dateButton.isHidden = isDateHidden
        calendarPicker.isHidden = isCalendarHidden
        thirdLine.isHidden = isCalendarHidden
    }

    private func resizeIfNeeded() {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        if textView.frame.size.height >= UIScreen.main.bounds.height {
            preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: textView.frame.size.height)
        } else {
            preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }
    
    func disableInteracted() {
        self.deleteButton.isEnabled = false
        self.saveButton.isEnabled = false
        textView.isEditable = false
        deadlineSwitch.isEnabled = false
        colorResult.isEnabled = false
        importanceSegmentedControl.isEnabled = false
    }
    
    private func animateCalendarAppereance() {
        UIView.animate(withDuration: 0.3) {
            self.visibilitySetting(isDateHidden: self.dateButton.isHidden, isCalendarHidden: false)
                    
            self.calendarPicker.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.calendarPicker.alpha = 0.0
                    
            self.calendarPicker.transform = .identity
            self.calendarPicker.alpha = 1.0
        }
    }
    
    private func animateCalendarDisappereance() {
        UIView.animate(withDuration: 0.3) {
            self.calendarPicker.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.calendarPicker.alpha = 1.0
                
            self.calendarPicker.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.calendarPicker.alpha = 0.0
            
            self.visibilitySetting(isDateHidden: self.dateButton.isHidden, isCalendarHidden: true)
        }
    }
    
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.date(from: dateString)
    }
    
    private func updateSettingsForCurrentTheme() {
        if textView.text != "Что надо сделать?" && textView.textColor != .tertiaryLabel {
            hexLabel.text = colorResult.backgroundColor?.toHex()
            textView.textColor = colorResult.backgroundColor
        }
    }
    
    @objc private func saveAction() {
        let importance = getImportance(by: importanceSegmentedControl.selectedSegmentIndex)
        let deadlineDate = deadlineSwitch.isOn ? convertStringToDate(dateButton.titleLabel?.text ?? "") : nil
        if currentItem != nil {
            currentItem = TodoItem(id: currentItem!.id, text: textView.text, importance: importance, deadline: deadlineDate, isDone: currentItem!.isDone, createdAt: currentItem!.createdAt, changedAt: Date(), textColor: hexLabel.text)
        } else {
            currentItem = TodoItem(text: textView.text, importance: importance, deadline: deadlineDate, textColor: hexLabel.text)
        }
        
        if let completion = completionHandler {
            completion(currentItem)
        }
        removeKeyboardLayoutGuideConstraint()

        self.dismiss(animated: true)
    }
    
    @objc private func hideKeyboard() {
        textView.resignFirstResponder()
    }
    
    @objc func deadlineSwitchValueChanged(_ sender: UISwitch) {
        if !sender.isOn {
            guard let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else { return }
            dateButton.setTitle(date.configureDate(), for: .normal)
            calendarPicker.date = date
            if !calendarPicker.isHidden {
                animateCalendarDisappereance()
            }
        }
        isModified = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && textView.text != "Что надо сделать?" && textView.textColor != .tertiaryLabel

        visibilitySetting(isDateHidden: !sender.isOn, isCalendarHidden: calendarPicker.isHidden)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        dateButton.setTitle(sender.date.configureDate(), for: .normal)
        isModified = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && textView.text != "Что надо сделать?" && textView.textColor != .tertiaryLabel
    }
    
    @objc func switchInvisibleDatePicker() {
        calendarPicker.isHidden ? animateCalendarAppereance() : animateCalendarDisappereance()
    }
    
    @objc func deleteAction() {
        currentItem = nil
        if let completion = completionHandler {
            completion(currentItem)
        }
        removeKeyboardLayoutGuideConstraint()
        self.dismiss(animated: true)
    }
    
    @objc func setInvisibleColorPicker() {
        colorPicker.isHidden = !colorPicker.isHidden
        sliderBrightness.isHidden = !sliderBrightness.isHidden
    }
    
    @objc func selectedSectionSegmented() {
        isModified = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && textView.text != "Что надо сделать?" && textView.textColor != .tertiaryLabel
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        if textView.text != "Что надо сделать?" && textView.textColor != .tertiaryLabel {
            textView.textColor = colorResult.backgroundColor?.withBrightness(CGFloat(sender.value))
        }
        colorResult.backgroundColor = colorResult.backgroundColor?.withBrightness(CGFloat(sender.value))
        hexLabel.text = colorResult.backgroundColor?.toHex()
        isModified = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && textView.text != "Что надо сделать?" && textView.textColor != .tertiaryLabel
    }
    
    @objc private func cancelAction() {
        removeKeyboardLayoutGuideConstraint()
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension DetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        resizeIfNeeded()
        isModified = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Что надо сделать?" && textView.textColor == .tertiaryLabel {
            textView.text = ""
            textView.textColor = colorResult.backgroundColor?.withBrightness(CGFloat(sliderBrightness.value))
            isModified = false
        }
    }
        
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = .tertiaryLabel
            isModified = false
        }
    }
}

extension DetailViewController: ColorPickerDelegate {
    func colorPicker(_ view: ColorPicker, didSelect color: UIColor) {
        guard color != UIColor(red: 0, green: 0, blue: 0, alpha: 0) else { return }
        colorResult.backgroundColor = color.withBrightness(CGFloat(sliderBrightness.value))
        if textView.text != "Что надо сделать?" && textView.textColor != .tertiaryLabel {
            textView.textColor = colorResult.backgroundColor?.withBrightness(CGFloat(sliderBrightness.value))
        }
        hexLabel.text = colorResult.backgroundColor?.toHex()
        isModified = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && textView.text != "Что надо сделать?" && textView.textColor != .tertiaryLabel
    }
}

extension DetailViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateLayoutForOrientationChange()
        }, completion: nil)
    }

    private func updateLayoutForOrientationChange() {
        if UIDevice.current.orientation.isLandscape, currentItem != nil {
            hideControlsInLandscape()
            removeTextViewConstraint()
        } else {
            showControlsInPortrait()
            updateTextViewConstraint()
        }
    }
    
    private func hideControlsInLandscape() {
        storedStackView.isHidden = true
        deleteButton.isHidden = true
    }
    
    private func showControlsInPortrait() {
        storedStackView.isHidden = false
        deleteButton.isHidden = false
    }
}
