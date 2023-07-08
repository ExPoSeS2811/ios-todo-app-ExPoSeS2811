//
//  FileCache.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 16.06.2023.
//

import Foundation
import MyLibrary


enum FileCacheErrors: Error {
    case systemDirectoryNotFound
    case parsingError
}

final class FileCache {
    var tasks: [String: TodoItem] = [:]
    var isDirty: Bool = false
    
    private let csv = ".csv"
    private let json = ".json"
    
    func add(newTask: TodoItem) {
        tasks[newTask.id] = newTask
    }
    
    func remove(_ id: String) {
        tasks[id] = nil
    }
    
    func saveJSON(to file: String) throws {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.systemDirectoryNotFound
        }
        print(documentsDirectory)
        let fileURL = documentsDirectory.appendingPathComponent("\(file)\(json)")
        let jsonData = tasks.map { $1.json }
        let data = try JSONSerialization.data(withJSONObject: jsonData)
        try data.write(to: fileURL)
    }
    
    func loadJSON(from file: String) throws {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.systemDirectoryNotFound
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("\(file)\(json)")
        let data = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: data)
        
        guard let jsn = json as? [Any] else {
            throw FileCacheErrors.parsingError
        }
        
        let parseJson = jsn.compactMap { TodoItem.parse(json: $0) }
        parseJson.forEach { add(newTask: $0) }
    }
    
    func saveCSV(to file: String) throws {
        let csvHeader = "id;text;importance;deadline;isDone;createdAt;changedAt;textColor"

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.systemDirectoryNotFound
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("\(file)\(csv)")
        let csvData = [csvHeader] + tasks.map { $1.csv }
        try csvData.joined(separator: "\n").write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    func loadCSV(from file: String) throws {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.systemDirectoryNotFound
        }

        let fileURL = documentsDirectory.appendingPathComponent("\(file)\(csv)")
        let data = try String(contentsOf: fileURL, encoding: .utf8)
        let rows = data.components(separatedBy: "\n")
        
        for row in rows {
            if let task = TodoItem.parse(csv: row) {
                add(newTask: task)
            }
        }
    }
}
