//
//  TodoItem.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 16.06.2023.
//

import Foundation

enum Importance: String {
    case low, normal, high
}

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let createdAt: Date
    let changedAt: Date?
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(),
        changedAt: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.changedAt = changedAt
    }
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let jsn = json as? [String: Any] else { return nil }
        guard let id = jsn["id"] as? String,
              let text = jsn["text"] as? String,
              let createdAt = (jsn["createdAt"] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) })
        else { return nil }
        
        let importance = (jsn["importance"] as? String).flatMap { Importance(rawValue: $0) } ?? .normal
        let deadline = (jsn["deadline"] as? Int).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        let isDone = jsn["isDone"] as? Bool ?? false
        let changedAt = (jsn["changedAt"] as? Int).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changedAt: changedAt
        )
    }
    
    var json: Any {
        var res: [String: Any] = [:]
        
        res["id"] = id
        res["text"] = text
        if importance != .normal {
            res["importance"] = importance.rawValue
        }
        if let deadline = deadline {
            res["deadline"] = Int(deadline.timeIntervalSince1970)
        }
        res["isDone"] = isDone
        res["createdAt"] = Int(createdAt.timeIntervalSince1970)
        if let changedAt = changedAt {
            res["changedAt"] = Int(changedAt.timeIntervalSince1970)
        }
        
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
        let importance = Importance(rawValue: columns[2]) ?? .normal
        
        let deadline = Int(columns[3]).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        let isDone = Bool(columns[4]) ?? false
        let changedAt = Int(columns[6]).flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changedAt: changedAt
        )
    }
    
    var csv: String {
        let deadlineString = deadline.flatMap { String(Int($0.timeIntervalSince1970)) } ?? ""
        let changedAtString = changedAt.flatMap { String(Int($0.timeIntervalSince1970)) } ?? ""
        let createdAtString = String(Int(createdAt.timeIntervalSince1970))
        let importanceString = importance != .normal ? importance.rawValue : ""
        
        return "\(id);\(text);\(importanceString);\(deadlineString);\(isDone);\(createdAtString);\(changedAtString)"
    }
}
