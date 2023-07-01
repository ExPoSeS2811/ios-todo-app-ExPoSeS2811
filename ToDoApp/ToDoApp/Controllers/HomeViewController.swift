//
//  HomeViewController.swift
//  test
//
//  Created by Gleb Rasskazov on 21.06.2023.
//

import UIKit

class HomeViewController: UIViewController {
    // MARK: GUI Variables

    lazy var statusStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [statusDoneTasksLabel, statusInvisibleTask])
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        
        return stackView
    }()
    
    lazy var statusDoneTasksLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Выполнено — \(completedTasks.count)"
        label.textColor = UIColor.tertiaryLabel
        
        return label
    }()
    
    lazy var statusInvisibleTask: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle("Показать", for: .normal)
        button.titleLabel?.textColor = UIColor.blueDisplay
        button.addTarget(self, action: #selector(toggleInvisibleCell), for: .touchUpInside)
        
        return button
    }()
    
    lazy var tasksTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    lazy var addTask: UIButton = {
        let button = UIButton(type: .system)
        
        let image = UIImage(systemName: "plus.circle.fill")
        button.setBackgroundImage(image, for: .normal)
        button.backgroundColor = .blueDisplay
        button.layer.cornerRadius = 22
        button.backgroundColor = .clear
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowColor = UIColor(red: 0, green: 0.19, blue: 0.4, alpha: 1).cgColor
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.layer.masksToBounds = false
        
        button.addTarget(self, action: #selector(createNewItem), for: .touchUpInside)
    
        return button
    }()
    
    // MARK: Propertiesa

    private let fileCache: FileCache
    private var showCompletedTasks = false
    private var tasks: [TodoItem] = []
    private var completedTasks: [TodoItem] = [] {
        didSet {
            statusDoneTasksLabel.text = "Выполнено — \(completedTasks.count)"
        }
    }
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskTableViewCell")
        tasksTableView.register(CreateTaskTableViewCell.self, forCellReuseIdentifier: "CreateTaskTableViewCell")
        setupUI()
    }
    
    init(fileCache: FileCache) {
        self.fileCache = fileCache
        super.init(nibName: nil, bundle: nil)
        loadDataFromFile()
    }
    
    private func loadDataFromFile() {
        do {
            try fileCache.loadJSON(from: "storage_json")
            tasks = Array(fileCache.tasks.values).sorted { $0.createdAt < $1.createdAt }
            completedTasks = tasks.filter { $0.isDone }
            tasks.removeAll { $0.isDone }
        } catch let error as FileCacheErrors {
            switch error {
            case .parsingError:
                print("Incorrect format")
            case .systemDirectoryNotFound:
                print("Not found system directory at \(error)")
            }
        } catch {
            print("Unhandled error: \(error)")
        }
    }
    
    private func saveDataAndReloadCell() {
        fileCache.tasks.removeAll()
        tasks.forEach { fileCache.add(newTask: $0) }
        completedTasks.forEach { fileCache.add(newTask: $0) }
        do {
            try fileCache.saveJSON(to: "storage_json")
        } catch let error as FileCacheErrors {
            switch error {
            case .parsingError:
                print("Incorrect format")
            case .systemDirectoryNotFound:
                print("Not found system directory at \(error)")
            }
        } catch {
            print("Unhandled error: \(error)")
        }
        reloadCell()
    }
    
    private func reloadCell() {
        tasks.removeAll { $0.isDone }
        tasks += showCompletedTasks ? completedTasks : []
        tasks = tasks.sorted { $0.createdAt < $1.createdAt }
        tasksTableView.reloadData()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = UIColor.iOSPrimaryBack
        view.addSubviews([statusStackView, tasksTableView, addTask])
        setupConstraints()
        setupNavigationBar()
        tabBarController?.tabBar.backgroundColor = .clear
    }

    private func setupConstraints() {
        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            statusStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            statusStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
        ])
        
        tasksTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tasksTableView.topAnchor.constraint(equalTo: statusStackView.bottomAnchor, constant: 12),
            tasksTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tasksTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tasksTableView.bottomAnchor.constraint(equalTo: addTask.bottomAnchor, constant: -14),
        ])
        
        addTask.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addTask.widthAnchor.constraint(equalToConstant: 44),
            addTask.heightAnchor.constraint(equalToConstant: 44),
            addTask.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            addTask.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
    
    private func setupNavigationBar() {
        title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.layoutMargins.left = 32

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.primaryLabel,
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
    }
    
    private func markTaskAsDone(at index: Int) {
        tasks[index].isDone = true
        completedTasks.append(tasks.remove(at: index))
    }

    private func markTaskAsUndone(at index: Int) {
        tasks[index].isDone = false
        completedTasks.removeAll(where: { $0.id == tasks[index].id })
    }

    private func deleteTask(at index: Int) {
        completedTasks.removeAll(where: { $0.id == tasks[index].id })
        tasks.remove(at: index)
    }
    
    @objc func createNewItem() {
        let vc = DetailViewController(currentItem: nil)
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
        vc.completionHandler = { [self] item in
            if let item = item {
                tasks.append(item)
                saveDataAndReloadCell()
            }
        }
    }

    @objc private func toggleInvisibleCell() {
        showCompletedTasks.toggle()
        statusInvisibleTask.setTitle(!showCompletedTasks ? "Показать" : "Скрыть", for: .normal)
        reloadCell()
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < tasks.count {
            let currentItem = tasks[indexPath.row]
            let vc = DetailViewController(currentItem: currentItem)
            let navController = UINavigationController(rootViewController: vc)
            navController.transitioningDelegate = self
            navController.modalPresentationStyle = .custom
            self.present(navController, animated: true)
            vc.completionHandler = { [self] item in
                if let item = item {
                    tasks[indexPath.row] = item
                } else {
                    tasks.remove(at: indexPath.row)
                }
                saveDataAndReloadCell()
            }
        } else {
            createNewItem()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row < tasks.count else { return nil }
        
        let markAsDoneAction = UIContextualAction(style: .normal, title: "Done") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            tasks[indexPath.row].isDone ? markTaskAsUndone(at: indexPath.row) : markTaskAsDone(at: indexPath.row)
            saveDataAndReloadCell()
            completionHandler(true)
        }
        
        let image = UIImage(systemName: "checkmark.circle.fill")
        markAsDoneAction.image = image?.withTintColor(.white, renderingMode: .alwaysOriginal)
        markAsDoneAction.backgroundColor = .greenDisplay
        let configuration = UISwipeActionsConfiguration(actions: [markAsDoneAction])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row < tasks.count else { return nil }
        
        let deleteAction = UIContextualAction(style: .normal, title: "Done") { [weak self] _, _, _ in
            guard let self = self else { return }
            deleteTask(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveDataAndReloadCell()
        }
        
        let image = UIImage(systemName: "trash.fill")
        deleteAction.image = image
        deleteAction.backgroundColor = .redDisplay
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.row < tasks.count else { return nil }
        
        let identifier = indexPath as NSCopying
        
        var menuItem1: UIAction!
        if !tasks[indexPath.row].isDone {
            menuItem1 = UIAction(title: "Mark As Done") { [weak self] _ in
                guard let self = self else { return }
                self.markTaskAsDone(at: indexPath.row)
                self.saveDataAndReloadCell()
            }
            
            menuItem1.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            menuItem1 = UIAction(title: "Mark As Undone") { [weak self] _ in
                guard let self = self else { return }
                self.markTaskAsUndone(at: indexPath.row)
                self.saveDataAndReloadCell()
            }
            
            menuItem1.image = UIImage(systemName: "circle")
        }
        
        let menuItem2 = UIAction(title: "Delete") { [weak self] _ in
            guard let self = self else { return }
            self.deleteTask(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveDataAndReloadCell()
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.redDisplay,
        ]
        let title = NSAttributedString(string: "Delete", attributes: attributes)
        menuItem2.setValue(title, forKey: "attributedTitle")
        menuItem2.image = UIImage(systemName: "trash")?.withTintColor(.redDisplay, renderingMode: .alwaysOriginal)
        
        let menu = UIMenu(children: [menuItem1, menuItem2])
        return UIContextMenuConfiguration(identifier: identifier, previewProvider:  { return DetailViewController(currentItem: self.tasks[indexPath.row])}) { _ in
            menu
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < tasks.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
            cell.set(with: tasks[indexPath.row])
            cell.statusButton.tag = indexPath.row
            cell.delegate = self
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateTaskTableViewCell", for: indexPath) as? CreateTaskTableViewCell else { return UITableViewCell() }
        return cell
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}

extension HomeViewController {
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? IndexPath else {
            return
        }
        
        let currentItem = tasks[indexPath.row]
        let vc = DetailViewController(currentItem: currentItem)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.disableInteracted()
        show(vc, sender: self)
    }
}

extension HomeViewController: TaskTableViewCellDelegate {
    func didEditingStatusButton(source: UIButton) {
        if source.imageView?.image != State.done.image {
            source.setImage(State.done.image, for: .normal)
            markTaskAsDone(at: source.tag)
        } else {
            markTaskAsUndone(at: source.tag)
        }
        saveDataAndReloadCell()
    }
}


