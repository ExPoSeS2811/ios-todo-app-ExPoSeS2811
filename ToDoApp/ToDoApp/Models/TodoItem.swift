//
//  TodoItem.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 16.06.2023.
//

import Foundation
import SQLite
import CoreData

enum Importance: String, CaseIterable {
    case low, basic, important
}

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    var isDone: Bool
    let createdAt: Date
    let changedAt: Date?
    let textColor: String?

    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(),
        changedAt: Date? = nil,
        textColor: String? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.textColor = textColor
    }
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let jsn = json as? [String: Any] else { return nil }
        guard let id = jsn[Keys.id.rawValue] as? String,
              let text = jsn[Keys.text.rawValue] as? String,
              let createdAt = (jsn[Keys.created_at.rawValue] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) })
        else { return nil }

        let importance = (jsn[Keys.importance.rawValue] as? String).flatMap { Importance(rawValue: $0) } ?? .basic
        let deadline = (jsn[Keys.deadline.rawValue] as? Int).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        let isDone = jsn[Keys.done.rawValue] as? Bool ?? false
        let changedAt = (jsn[Keys.changed_at.rawValue] as? Int).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        let textColor = jsn[Keys.color.rawValue] as? String

        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changedAt: changedAt,
            textColor: textColor
        )
    }

    var json: Any {
        var res: [String: Any] = [:]

        res[Keys.id.rawValue] = id
        res[Keys.text.rawValue] = text
        res[Keys.importance.rawValue] = importance.rawValue
        if let deadline = deadline {
            res[Keys.deadline.rawValue] = Int(deadline.timeIntervalSince1970)
        }
        res[Keys.done.rawValue] = isDone
        res[Keys.created_at.rawValue] = Int(createdAt.timeIntervalSince1970)

        res[Keys.changed_at.rawValue] = Int(changedAt?.timeIntervalSince1970 ?? 102020)
        if let textColor = textColor {
            res[Keys.color.rawValue] = textColor
        }
        res[Keys.last_updated_by.rawValue] = ""
        return res
    }
}

extension TodoItem {
    static func parse(row: Row) -> TodoItem? {
        guard let id = try? row.get(Expression<String>("id")),
              let text = try? row.get(Expression<String>("text")),
              let importanceRawValue = try? row.get(Expression<String>("importance")),
              let importance = Importance(rawValue: importanceRawValue),
              let createdAtString = try? row.get(Expression<String>("created_at")),
              let createdAt = dateFormatter.date(from: createdAtString)
        else {
            return nil
        }

        let deadlineString = try? row.get(Expression<String?>("deadline"))
        let deadline = deadlineString.flatMap { dateFormatter.date(from: $0) }

        let isDone = try? row.get(Expression<Bool>("is_done"))

        let changedAtString = try? row.get(Expression<String?>("changed_at"))
        let changedAt = changedAtString.flatMap { dateFormatter.date(from: $0) }

        let textColor = try? row.get(Expression<String?>("color"))

        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone ?? false,
            createdAt: createdAt,
            changedAt: changedAt,
            textColor: textColor
        )
    }

    var sqlReplaceStatement: String {
        let importanceValue = importance.rawValue
        let deadlineString = deadline.map { dateFormatter.string(from: $0) } ?? "NULL"
        let isDoneValue = isDone ? "1" : "0"
        let createdAtString = dateFormatter.string(from: createdAt)
        let changedAtString = changedAt.map { dateFormatter.string(from: $0) } ?? "NULL"
        let textColorValue = textColor.map { "'\($0)'" } ?? "NULL"

        return """
        REPLACE INTO todo_items (id, text, importance, deadline, is_done, created_at, changed_at, color)
        VALUES ('\(id)', '\(text)', '\(importanceValue)', '\(deadlineString)', \(isDoneValue), '\(createdAtString)', \(changedAtString), \(textColorValue));
        """
    }
}

extension TodoItem {
    static func parse(entity: TodoItemEntity) -> TodoItem {
        return TodoItem(
            id: entity.id,
            text: entity.text,
            importance: Importance(rawValue: entity.importance) ?? .basic,
            deadline: entity.deadline,
            isDone: entity.isDone,
            createdAt: entity.createdAt,
            changedAt: entity.changedAt,
            textColor: entity.textColor
        )
    }
}

enum Keys: String {
    case id, text, importance, deadline, done, color, created_at, changed_at, last_updated_by
}
