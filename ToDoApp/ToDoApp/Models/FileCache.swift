//
//  FileCache.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 16.06.2023.
//

import CoreData
import Foundation

final class FileCache {
    var tasks: [String: TodoItem] = [:]
    var isDirty: Bool = false

    private lazy var sqlDatabase: SQLDataManager = {
        let manager = SQLDataManager(fileCache: self)
        return manager
    }()

    private lazy var coreDataDatabase: CoreDataManager = {
        let manager = CoreDataManager(fileCache: self)
        return manager
    }()

    private var storage: StorageManager?

    init(database selected: DataBaseSelect = .coredata) {
        switch selected {
        case .sql: storage = self.sqlDatabase
        case .coredata: storage = self.coreDataDatabase
        }
    }

    func save() throws {
        try storage?.save()
    }

    func load() throws {
        try storage?.load()
    }

    func update(_ task: TodoItem) {
        storage?.update(task)
    }

    func delete(with id: String) {
        storage?.delete(with: id)
    }

    func insert(_ task: TodoItem) {
        storage?.insert(task)
    }

    func add(newTask: TodoItem) {
        tasks[newTask.id] = newTask
    }

    func remove(_ id: String) {
        tasks[id] = nil
    }

    enum DataBaseSelect {
        case sql, coredata
    }
}

enum FileCacheErrors: Error {
    case systemDirectoryNotFound
    case parsingError
}
