//
//  TodoItem.swift
//  ToDoAppSUI
//
//  Created by Gleb Rasskazov on 20.07.2023.
//

import Foundation
import SwiftUI

struct TodoItem: Hashable, Identifiable {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    var isDone: Bool
    let createdAt: Date
    let changedAt: Date?
    let textColor: String?
    let isNew: Bool

    var image: Image {
        Image(importance.rawValue)
    }

    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(),
        changedAt: Date? = nil,
        textColor: String? = nil,
        isNew: Bool = false
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.textColor = textColor
        self.isNew = isNew
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
    
    static func getItems() -> [TodoItem] {
        return [
            TodoItem(text: "asdfpkaspfkasopfkop[askdfp[akfdopkaopsdfkopasdfkp[oadskfpo[aksdpfa[ospdfkoarherherwioihjeiorhjioerwhowerpohjewpiorj", importance: .important, deadline: Calendar.current.date(byAdding: .month, value: 5, to: Date())),
            TodoItem(text: "Task 2", importance: .important),
            TodoItem(text: "Task 3", importance: .important),
            TodoItem(text: "Task 2", importance: .basic, deadline: Calendar.current.date(byAdding: .month, value: 2, to: Date()), isDone: true),
            TodoItem(text: "Task 3", importance: .basic, isDone: true),
            TodoItem(text: "", importance: .low, isNew: true),
        ]
    }
}

enum Keys: String {
    case id, text, importance, deadline, done, color, created_at, changed_at, last_updated_by
}

enum Importance: String, CaseIterable {
    case low, basic, important
}
