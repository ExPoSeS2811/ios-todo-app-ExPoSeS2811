//
//  CoreDataManager.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 11.07.2023.
//

import CoreData
import Foundation

final class CoreDataManager: StorageManager {
    private let persistentContainer: NSPersistentContainer
    let fileCache: FileCache
    
    init(fileCache: FileCache) {
        self.fileCache = fileCache
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("Failed to load CoreData store: \(error)")
            } else {
                print(description.url?.absoluteString ?? "")
            }
        }
    }
    
    func save() throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            for entity in entities {
                context.delete(entity)
            }
            
            for task in fileCache.tasks.values {
                let entity = TodoItemEntity(context: context)
                entity.id = task.id
                entity.text = task.text
                entity.importance = task.importance.rawValue
                entity.deadline = task.deadline
                entity.isDone = task.isDone
                entity.createdAt = task.createdAt
                entity.changedAt = task.changedAt
                entity.textColor = task.textColor
            }
            
            try context.save()
        } catch {
            print("Failed to save CoreData context: \(error)")
            throw error
        }
    }
    
    func load() throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            fileCache.tasks.removeAll()
            entities.forEach { fileCache.add(newTask: TodoItem.parse(entity: $0)) }
        } catch {
            print("Failed to fetch CoreData entities: \(error)")
            throw error
        }
    }
    
    func insert(_ task: TodoItem) {
        fileCache.tasks[task.id] = task
        
        let context = persistentContainer.viewContext
        let entity = TodoItemEntity(context: context)
        entity.id = task.id
        entity.text = task.text
        entity.importance = task.importance.rawValue
        entity.deadline = task.deadline
        entity.isDone = task.isDone
        entity.createdAt = task.createdAt
        entity.changedAt = task.changedAt
        entity.textColor = task.textColor
        
        do {
            try context.save()
        } catch {
            print("Failed to save CoreData context: \(error)")
        }
    }
    
    func update(_ task: TodoItem) {
        fileCache.tasks[task.id] = task
        
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", task.id)
        
        do {
            let entities = try context.fetch(fetchRequest)
            if let entity = entities.first {
                entity.text = task.text
                entity.importance = task.importance.rawValue
                entity.deadline = task.deadline
                entity.isDone = task.isDone
                entity.createdAt = task.createdAt
                entity.changedAt = task.changedAt
                entity.textColor = task.textColor
                
                try context.save()
            }
        } catch {
            print("Failed to fetch and update CoreData entity: \(error)")
        }
    }
    
    func delete(with id: String) {
        fileCache.tasks[id] = nil
        
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            let entities = try context.fetch(fetchRequest)
            if let entity = entities.first {
                context.delete(entity)
                try context.save()
            }
        } catch {
            print("Failed to fetch and delete CoreData entity: \(error)")
        }
    }
}
