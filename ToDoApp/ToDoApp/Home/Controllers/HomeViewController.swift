//
//  HomeViewController.swift
//  test
//
//  Created by Gleb Rasskazov on 21.06.2023.
//

import MyLibrary
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
    
    // MARK: Properties
    
    var tasks: [TodoItem] = []
    var completedTasks: [TodoItem] = [] {
        didSet {
            statusDoneTasksLabel.text = "Выполнено — \(completedTasks.count)"
        }
    }

    private let fileCache: FileCache
    private var showCompletedTasks = false
    
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
    
    func saveDataAndReloadCell() {
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
    
    func markTaskAsDone(at index: Int) {
        tasks[index].isDone = true
        completedTasks.append(tasks.remove(at: index))
    }

    func markTaskAsUndone(at index: Int) {
        tasks[index].isDone = false
        completedTasks.removeAll(where: { $0.id == tasks[index].id })
    }

    func deleteTask(at index: Int) {
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
