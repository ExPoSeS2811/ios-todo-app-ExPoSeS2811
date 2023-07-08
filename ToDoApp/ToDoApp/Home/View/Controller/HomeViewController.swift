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
        
        label.text = "Выполнено — \(0)"
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

    var homeViewModel: HomeViewModel

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskTableViewCell")
        tasksTableView.register(CreateTaskTableViewCell.self, forCellReuseIdentifier: "CreateTaskTableViewCell")
        setupUI()
        homeViewModel.loadData()
        
        homeViewModel.networking.makeRequest(completion: { result in
            DispatchQueue.main.async {
                self.handleResponse(result)
            }
        })
    }
    
    private func handleResponse(_ result: Result<[TodoItem], Error>) {
        switch result {
        case .success(let items):
            homeViewModel.items = items
            homeViewModel.saveData()
        case .failure(let error):
            // TODO: Show alert with error
            print("error")
        }
    }
    
    private func updateTable() {
        
    }
    
    init(viewModel: HomeViewModel) {
        self.homeViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupViewModel()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = UIColor.iOSPrimaryBack
        view.addSubviews([statusStackView, tasksTableView, addTask])
        setupNavigationBar()
        tabBarController?.tabBar.backgroundColor = .clear
        setupConstraints()
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
    
    private func setupViewModel() {
        homeViewModel.reloadData = { [weak self] in
            self?.tasksTableView.reloadData()
        }
        
        homeViewModel.updateCompletedTasksCount = { [weak self] count in
            DispatchQueue.main.async {
                self?.statusDoneTasksLabel.text = "Выполнено — \(count)"
            }
        }
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
    
    // MARK: - Objc methods

    @objc func createNewItem() {
        let vc = DetailViewController(currentItem: nil)
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
        vc.completionHandler = { [self] item in
            if let item = item {
                homeViewModel.items.append(item)
                homeViewModel.saveData()
                homeViewModel.networking.makeRequest(with: .post(item), completion: { result in
                    // TODO: Relalize to check with isDirty
                    print("change is dirty")
                })
            }
        }
    }

    @objc private func toggleInvisibleCell() {
        homeViewModel.showCompletedTasks.toggle()
        homeViewModel.showCompletedTasks ? homeViewModel.changeVisibility(to: .showCompleted) : homeViewModel.changeVisibility(to: .hideCompleted)
        statusInvisibleTask.setTitle(homeViewModel.showCompletedTasks ? "Скрыть" : "Показать", for: .normal)
    }
}

extension HomeViewController: TaskTableViewCellDelegate {
    func didEditingStatusButton(source: UIButton) {
        homeViewModel.items[source.tag].isDone.toggle()
        homeViewModel.networking.makeRequest(with: .put(homeViewModel.items[source.tag].id, homeViewModel.items[source.tag])) { result in
            print("isDirty")
        }
        homeViewModel.saveData()
        
//        if !self.homeViewModel.fileCache.isDirty {
//            homeViewModel.networking.makeRequest(with: .put(homeViewModel.items[source.tag].id, homeViewModel.items[source.tag]), completion: { result in
//                DispatchQueue.main.async {
//                    print(self.homeViewModel.fileCache.isDirty)
//                    switch result {
//                    case .success(let items):
//                        self.homeViewModel.fileCache.isDirty = false
//                    case .failure(let error):
//                        self.homeViewModel.fileCache.isDirty = true
//                    }
//                    print("is dirty need to realize")
//                }
//            })
//        } else {
//            self.homeViewModel.networking.makeRequest(with: .patch(homeViewModel.items)) { result in
//                DispatchQueue.main.async {
//                    print(self.homeViewModel.fileCache.isDirty = false)
//                    switch result {
//                    case .success(let items):
//                        self.homeViewModel.fileCache.isDirty = false
//                        self.homeViewModel.items = Array(items).sorted { $0.createdAt < $1.createdAt }
//                        self.homeViewModel.saveData()
//                    case .failure(let error):
//                        self.homeViewModel.fileCache.isDirty = true
//                    }
//                }
//            }
//        }
    }
}
