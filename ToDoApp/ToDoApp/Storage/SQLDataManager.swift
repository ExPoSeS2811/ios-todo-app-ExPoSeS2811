//
//  SQLDataManager.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 14.07.2023.
//

import Foundation
import SQLite

final class SQLDataManager: StorageManager {
    private var db: Connection?
    private let todoItems = Table("todo_items")
    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let importance = Expression<String>("importance")
    private let deadline = Expression<Date?>("deadline")
    private let isDone = Expression<Bool>("is_done")
    private let createdAt = Expression<Date>("created_at")
    private let changedAt = Expression<Date?>("changed_at")
    private let textColor = Expression<String?>("color")
    
    let fileCache: FileCache
    
    init(fileCache: FileCache) {
        self.fileCache = fileCache
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentDirectory.appendingPathComponent("todo_datebase.sqlite3")
        print("database to", fileURL.path)

        do {
            db = try Connection(fileURL.path)

            try db?.run(todoItems.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(text)
                table.column(importance)
                table.column(deadline)
                table.column(isDone)
                table.column(createdAt)
                table.column(changedAt)
                table.column(textColor)
            })
        } catch {
            print(error)
        }
    }

    func save() throws {
        guard let db = db else { throw FileCacheErrors.systemDirectoryNotFound }

        do {
            try db.transaction {
                try db.run(todoItems.delete())
                for task in fileCache.tasks.values {
                    try db.run(task.sqlReplaceStatement)
                }
            }
        } catch {
            throw FileCacheErrors.systemDirectoryNotFound
        }
    }

    func load() throws {
        guard let db = db else { throw FileCacheErrors.systemDirectoryNotFound }
        fileCache.tasks.removeAll()
        do {
            for row in try db.prepare(todoItems) {
                if let task = TodoItem.parse(row: row) {
                    fileCache.add(newTask: task)
                }
            }
        } catch {
            throw FileCacheErrors.systemDirectoryNotFound
        }
    }

    func insert(_ task: TodoItem) {
        let insert = todoItems.insert(
            id <- task.id,
            text <- task.text,
            importance <- task.importance.rawValue,
            deadline <- task.deadline,
            isDone <- task.isDone,
            createdAt <- task.createdAt,
            changedAt <- task.changedAt,
            textColor <- task.textColor
        )

        do {
            try db?.run(insert)
        } catch {
            print(error)
        }
    }

    func update(_ task: TodoItem) {
        let targetTask = todoItems.filter(id == task.id)
        let update = targetTask.update(
            text <- task.text,
            importance <- task.importance.rawValue,
            deadline <- task.deadline,
            isDone <- task.isDone,
            createdAt <- task.createdAt,
            changedAt <- task.changedAt,
            textColor <- task.textColor
        )

        do {
            try db?.run(update)
        } catch {
            print(error)
        }
    }

    func delete(with id: String) {
        let targetTask = todoItems.filter(self.id == id)
        let delete = targetTask.delete()

        do {
            try db?.run(delete)
        } catch {
            print(error)
        }
    }
}
