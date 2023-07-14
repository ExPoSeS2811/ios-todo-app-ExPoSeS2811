//
//  StorageManager.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 11.07.2023.
//

import CoreData
import UIKit

protocol StorageManager {
    func save() throws
    func load() throws
    func update(_ task: TodoItem) 
    func delete(with id: String)
    func insert(_ task: TodoItem)
}
