//
//  HomeViewModel.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 05.07.2023.
//

import Foundation

protocol HomeViewModelProtocol {
    var reloadData: (() -> Void)? { get set }
    var showCompletedTasks: Bool { get set }
    var updateCompletedTasksCount: ((Int) -> Void)? { get }
    var revision: Int { get set }
}

class HomeViewModel: HomeViewModelProtocol {
    // MARK: - Properties

    var updateCompletedTasksCount: ((Int) -> Void)?
    var showCompletedTasks: Bool = false
    var fileCache: FileCache
    var reloadData: (() -> Void)?
    var revision: Int {
        get { UserDefaults.standard.integer(forKey: "revision") }
        set { UserDefaults.standard.setValue(newValue, forKey: "revision") }
    }
    
    var networking: DefaultNetworkService = .init()

    var items: [TodoItem] = [] {
        didSet {
            updateCompletedTasksCount?(fileCache.tasks.values.filter { $0.isDone }.count)
            self.reloadData?()
        }
    }
    
    var stateVisibility: TaskVisibility = .hideCompleted {
        didSet {
            switch stateVisibility {
            case .hideCompleted: items = Array(fileCache.tasks.values).filter { !$0.isDone }.sorted { $0.createdAt < $1.createdAt }
            case .showCompleted: items = Array(fileCache.tasks.values).sorted { $0.createdAt < $1.createdAt }
            }
        }
    }
    
    // MARK: - Initialization

    init(fileCache: FileCache) {
        self.fileCache = fileCache
    }
    
    // MARK: - Methods
    
    func loadData() {
        do {
            try fileCache.load()
            stateVisibility = .hideCompleted
            updateCompletedTasksCount?(fileCache.tasks.values.filter { $0.isDone }.count)
            
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
    
    func saveData(with selected: OperationType = .save) {
        items.forEach { fileCache.add(newTask: $0) }
        switch stateVisibility {
        case .hideCompleted: items = Array(fileCache.tasks.values).filter { !$0.isDone }.sorted { $0.createdAt < $1.createdAt }
        case .showCompleted: items = Array(fileCache.tasks.values).sorted { $0.createdAt < $1.createdAt }
        }
                
        do {
            switch selected {
            case .insert(let item):
                fileCache.insert(item)
            case .update(let item):
                fileCache.update(item)
            case .delete(let id):
                guard let indexDelete = items.firstIndex(where: { $0.id == id }) else { return }
                fileCache.delete(with: items[indexDelete].id)
                items.remove(at: indexDelete)
            case .save:
                try fileCache.save()
            }
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
    
    func changeVisibility(to state: TaskVisibility) {
        stateVisibility = state
    }
    
    // MARK: - Enums

    enum TaskVisibility: String {
        case showCompleted
        case hideCompleted
    }
    
    enum OperationType {
        case insert(TodoItem)
        case update(TodoItem)
        case delete(String)
        case save
    }
}
