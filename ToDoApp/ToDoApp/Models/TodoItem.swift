//
//  TodoItem.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 16.06.2023.
//

import Foundation

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
    static func parse(csv: String) -> TodoItem? {
        let columns = csv.components(separatedBy: ";")
        guard !columns[0].isEmpty,
              !columns[1].isEmpty,
              let createdAt = Int(columns[5]).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) }) else { return nil }
        let id = columns[0]
        let text = columns[1]
        let importance = Importance(rawValue: columns[2]) ?? .basic
        
        let deadline = Int(columns[3]).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        let isDone = Bool(columns[4]) ?? false
        let changedAt = Int(columns[6]).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        let textColor = columns[7]
        
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
    
    var csv: String {
        let deadlineString = deadline.flatMap { String(Int($0.timeIntervalSince1970)) } ?? ""
        let changedAtString = changedAt.flatMap { String(Int($0.timeIntervalSince1970)) } ?? ""
        let createdAtString = String(Int(createdAt.timeIntervalSince1970))
        let importanceString = importance != .basic ? importance.rawValue : ""
        let textColorString = textColor != nil ? textColor! : ""
        
        return "\(id);\(text);\(importanceString);\(deadlineString);\(isDone);\(createdAtString);\(changedAtString);\(textColorString)"
    }
}

enum Keys: String {
    case id, text, importance, deadline, done, color, created_at, changed_at, last_updated_by
}
