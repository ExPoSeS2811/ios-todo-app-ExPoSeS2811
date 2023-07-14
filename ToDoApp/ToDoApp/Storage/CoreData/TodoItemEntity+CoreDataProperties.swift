//
//  TodoItemEntity+CoreDataProperties.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 11.07.2023.
//
//

import Foundation
import CoreData


extension TodoItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemEntity> {
        return NSFetchRequest<TodoItemEntity>(entityName: "TodoItemEntity")
    }

    @NSManaged public var textColor: String?
    @NSManaged public var changedAt: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var isDone: Bool
    @NSManaged public var deadline: Date?
    @NSManaged public var importance: String
    @NSManaged public var text: String
    @NSManaged public var id: String

}

extension TodoItemEntity : Identifiable {

}
