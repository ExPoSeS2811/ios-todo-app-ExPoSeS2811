//
//  TodoItemTests.swift
//  TodoItemTests
//
//  Created by Gleb Rasskazov on 16.06.2023.
//

@testable import ToDoApp
import XCTest

final class TodoItemTests: XCTestCase {
    // MARK: Check inits
    
    func test_init_setupWithDefaultValues() {
        // Given
        let text = "First homework from yandex"
        let importance = Importance.high
        
        // When
        let sut = TodoItem(text: text, importance: importance)
        
        // Then
        XCTAssertNotEqual(sut.id, "")
        XCTAssertEqual(sut.text, text)
        XCTAssertEqual(sut.importance, importance)
        XCTAssertNil(sut.deadline)
        XCTAssertFalse(sut.isDone)
        XCTAssertNil(sut.changedAt)
    }
    
    func test_init_setupWithAllValues() {
        let id = "EXPOSES-#28"
        let text = "Exam in history"
        let importance = Importance.low
        let deadline = Date(timeIntervalSince1970: 1687455249)
        let createdAt = Date(timeIntervalSince1970: 1686764011)
        let changedAt = Date(timeIntervalSince1970: 1687023274)
        
        let sut = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: true,
            createdAt: createdAt,
            changedAt: changedAt
        )
        
        XCTAssertEqual(sut.id, id)
        XCTAssertEqual(sut.text, text)
        XCTAssertEqual(sut.importance, importance)
        XCTAssertEqual(sut.deadline, deadline)
        XCTAssertTrue(sut.isDone)
        XCTAssertEqual(sut.createdAt, createdAt)
        XCTAssertEqual(sut.changedAt, changedAt)
    }
    
    // MARK: Parsing from JSON
    
    func test_parse_FromJSONWithDefaultValues() {
        let createdAt = Date(timeIntervalSince1970: TimeInterval(1686522045))
        
        let json: [String: Any] = [
            "id": "RIQKADURQLQ-32JKWI-2",
            "text": "Prepare the floor",
            "importance": "high",
            "createdAt": Int(createdAt.timeIntervalSince1970)
        ]
        let parsedItem = TodoItem.parse(json: json)
        
        XCTAssertNotNil(parsedItem)
        XCTAssertEqual(parsedItem?.id, json["id"] as? String)
        XCTAssertEqual(parsedItem?.text, json["text"] as? String)
        XCTAssertEqual(parsedItem?.importance.rawValue, json["importance"] as? String)
        XCTAssertNil(parsedItem?.deadline)
        XCTAssertEqual(parsedItem?.isDone, false)
        XCTAssertEqual(parsedItem?.createdAt, createdAt)
        XCTAssertNil(parsedItem?.changedAt)
    }
    
    func test_parse_FromJSONWithAllValues() {
        let deadline = Date(timeIntervalSince1970: TimeInterval(1679091200))
        let createdAt = Date(timeIntervalSince1970: TimeInterval(1679004800))
        let changedAt = Date(timeIntervalSince1970: TimeInterval(1679080000))
        
        let json: [String: Any] = [
            "id": "12345",
            "text": "Complete project tasks",
            "importance": "high",
            "deadline": Int(deadline.timeIntervalSince1970),
            "isDone": false,
            "createdAt": Int(createdAt.timeIntervalSince1970),
            "changedAt": Int(changedAt.timeIntervalSince1970)
        ]
        let parsedItem = TodoItem.parse(json: json)
        
        XCTAssertNotNil(parsedItem)
        XCTAssertEqual(parsedItem?.id, json["id"] as? String)
        XCTAssertEqual(parsedItem?.text, json["text"] as? String)
        XCTAssertEqual(parsedItem?.importance.rawValue, json["importance"] as? String)
        XCTAssertEqual(parsedItem?.deadline, deadline)
        XCTAssertEqual(parsedItem?.isDone, json["isDone"] as? Bool)
        XCTAssertEqual(parsedItem?.createdAt, createdAt)
        XCTAssertEqual(parsedItem?.changedAt, changedAt)
    }
    
    func test_parse_FromJSONWithNormalImportance() {
        let deadline = Date(timeIntervalSince1970: TimeInterval(1679091200))
        let createdAt = Date(timeIntervalSince1970: 1679004800)
        
        let json: [String: Any] = [
            "id": "67890",
            "text": "Buy groceries",
            "deadline": Int(deadline.timeIntervalSince1970),
            "isDone": false,
            "createdAt": Int(createdAt.timeIntervalSince1970)
        ]
        let parsedItem = TodoItem.parse(json: json)
        
        XCTAssertNotNil(parsedItem)
        XCTAssertEqual(parsedItem?.id, json["id"] as? String)
        XCTAssertEqual(parsedItem?.text, json["text"] as? String)
        XCTAssertEqual(parsedItem?.importance, .normal)
        XCTAssertEqual(parsedItem?.deadline, deadline)
        XCTAssertEqual(parsedItem?.isDone, json["isDone"] as? Bool)
        XCTAssertEqual(parsedItem?.createdAt, createdAt)
        XCTAssertNil(parsedItem?.changedAt)
    }
    
    func test_parse_FromJSONWithoutId() {
        let json: [String: Any] = [
            "text": "Buy groceries",
            "importance": "high",
            "deadline": 1679091200,
            "isDone": false,
            "createdAt": 1679004800,
            "changedAt": 1663056800
        ]
        
        let parsedItem = TodoItem.parse(json: json)
        
        XCTAssertNil(parsedItem)
    }
    
    func test_parse_FromJSONWithoutCreated() {
        let json: [String: Any] = [
            "id": "EEQELQPRKOQO-123-153",
            "text": "Clear the car",
            "importance": "high",
            "deadline": 1674091200,
            "isDone": true,
            "changedAt": 1663056800
        ]
        
        let parsedItem = TodoItem.parse(json: json)
        
        XCTAssertNil(parsedItem)
    }
    
    func test_parse_FromJSONWithoutText() {
        let json: [String: Any] = [
            "id": "EEQELQPRKOQO-123-153",
            "importance": "high",
            "deadline": 1674091200,
            "isDone": true,
            "createdAt": 1679004800,
            "changedAt": 1663056800
        ]
        
        let parsedItem = TodoItem.parse(json: json)
        
        XCTAssertNil(parsedItem)
    }
    
    // MARK: Parsing to JSON
    
    func test_parse_ToJSONWithDefaultValues() {
        let sut = TodoItem(text: "Some structure", importance: .low)
        let json = sut.json as? [String: Any]
        
        XCTAssertNotNil(json)
        XCTAssertNotEqual(json?["id"] as? String, "")
        XCTAssertEqual(json?["text"] as? String, sut.text)
        XCTAssertEqual(json?["importance"] as? String, sut.importance.rawValue)
        XCTAssertNil(json?["deadline"] as? Int)
        XCTAssertEqual(json?["isDone"] as? Bool, sut.isDone)
        XCTAssertEqual(json?["createdAt"] as? Int, Int(sut.createdAt.timeIntervalSince1970))
        XCTAssertNil(json?["changedAt"] as? Int)
    }
    
    func test_parse_ToJSONWithAllValues() {
        let deadline = Date(timeIntervalSince1970: TimeInterval(12686522045))
        let createdAt = Date(timeIntervalSince1970: TimeInterval(1686522045))
        let changedAt = Date(timeIntervalSince1970: TimeInterval(1686522057))
        
        let sut = TodoItem(
            id: "10",
            text: "Clean the house",
            importance: .low,
            deadline: deadline,
            isDone: true,
            createdAt: createdAt,
            changedAt: changedAt
        )
        let json = sut.json as? [String: Any]
        
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["id"] as? String, sut.id)
        XCTAssertEqual(json?["text"] as? String, sut.text)
        XCTAssertEqual(json?["importance"] as? String, sut.importance.rawValue)
        XCTAssertEqual(json?["deadline"] as? Int, Int(deadline.timeIntervalSince1970))
        XCTAssertEqual(json?["isDone"] as? Bool, sut.isDone)
        XCTAssertEqual(json?["createdAt"] as? Int, Int(createdAt.timeIntervalSince1970))
        XCTAssertEqual(json?["changedAt"] as? Int, Int(changedAt.timeIntervalSince1970))
    }
    
    func test_parse_ToJSONWithNormalImportance() {
        let deadline = Date(timeIntervalSince1970: TimeInterval(12686522045))
        let createdAt = Date(timeIntervalSince1970: TimeInterval(258265292))
        
        let sut = TodoItem(id: "120242856_eq",
                           text: "Clear a desktop",
                           importance: .normal,
                           deadline: deadline,
                           isDone: true,
                           createdAt: createdAt)
        let json = sut.json as? [String: Any]
        
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["id"] as? String, sut.id)
        XCTAssertEqual(json?["text"] as? String, sut.text)
        XCTAssertNil(json?["importance"] as? String)
        XCTAssertEqual(json?["deadline"] as? Int, Int(deadline.timeIntervalSince1970))
        XCTAssertEqual(json?["isDone"] as? Bool, sut.isDone)
        XCTAssertEqual(json?["createdAt"] as? Int, Int(createdAt.timeIntervalSince1970))
        XCTAssertNil(json?["changedAt"] as? Int)
    }
    
    // MARK: Parsing from CSV
    
    func test_parse_FromCSVWithDefaultValues() {
        let id = "RIQKADURQLQ-32JKWI-2"
        let text = "Prepare the floor"
        let importance = Importance.high
        let createdAt = Date(timeIntervalSince1970: TimeInterval(1686522045))
        
        let csv = "\(id);\(text);\(importance.rawValue);;;\(Int(createdAt.timeIntervalSince1970));"
        let parsedItem = TodoItem.parse(csv: csv)
        
        XCTAssertNotNil(parsedItem)
        XCTAssertEqual(parsedItem?.id, id)
        XCTAssertEqual(parsedItem?.text, text)
        XCTAssertEqual(parsedItem?.importance, importance)
        XCTAssertNil(parsedItem?.deadline)
        XCTAssertEqual(parsedItem?.isDone, false)
        XCTAssertEqual(parsedItem?.createdAt, createdAt)
        XCTAssertNil(parsedItem?.changedAt)
    }
    
    func test_parse_FromCSVWithAllValues() {
        let id = "12345"
        let text = "Complete project tasks"
        let importance = Importance.high
        let deadline = Date(timeIntervalSince1970: TimeInterval(1679091200))
        let isDone = true
        let createdAt = Date(timeIntervalSince1970: TimeInterval(1679004800))
        let changedAt = Date(timeIntervalSince1970: TimeInterval(1679080000))
        
        let csv = "\(id);\(text);\(importance.rawValue);\(Int(deadline.timeIntervalSince1970));\(isDone);\(Int(createdAt.timeIntervalSince1970));\(Int(changedAt.timeIntervalSince1970))"
        let parsedItem = TodoItem.parse(csv: csv)
        
        XCTAssertNotNil(parsedItem)
        XCTAssertEqual(parsedItem?.id, id)
        XCTAssertEqual(parsedItem?.text, text)
        XCTAssertEqual(parsedItem?.importance, importance)
        XCTAssertEqual(parsedItem?.deadline, deadline)
        XCTAssertEqual(parsedItem?.isDone, isDone)
        XCTAssertEqual(parsedItem?.createdAt, createdAt)
        XCTAssertEqual(parsedItem?.changedAt, changedAt)
    }
    
    func test_parse_FromCSVWithNormalImportance() {
        let id = "67890"
        let text = "Buy groceries"
        let deadline = Date(timeIntervalSince1970: TimeInterval(1679091200))
        let isDone = false
        let createdAt = Date(timeIntervalSince1970: TimeInterval(1679004800))
        
        let csv = "\(id);\(text);;\(Int(deadline.timeIntervalSince1970));\(isDone);\(Int(createdAt.timeIntervalSince1970));"
        let parsedItem = TodoItem.parse(csv: csv)
        
        XCTAssertNotNil(parsedItem)
        XCTAssertEqual(parsedItem?.id, id)
        XCTAssertEqual(parsedItem?.text, text)
        XCTAssertEqual(parsedItem?.importance, .normal)
        XCTAssertEqual(parsedItem?.deadline, deadline)
        XCTAssertEqual(parsedItem?.isDone, isDone)
        XCTAssertEqual(parsedItem?.createdAt, createdAt)
        XCTAssertNil(parsedItem?.changedAt)
    }
    
    func test_parse_FromCSVWithoutId() {
        let csv = ";Buy groceries;;1679091200;false;1679004800;1663056800"
        let parsedItem = TodoItem.parse(csv: csv)
        
        XCTAssertNil(parsedItem)
    }
    
    func test_parse_FromCSVWithoutCreatedAt() {
        let csv = "EEQELQPRKOQO-123-153;Clear the car;high;1674091200;true;;1663056800"
        let parsedItem = TodoItem.parse(csv: csv)
        
        XCTAssertNil(parsedItem)
    }
    
    func test_parse_FromCSVWithoutText() {
        let csv = "EEQELQPRKOQO-123-153;;high;1674091200;true;1679004800;1663056800"
        let parsedItem = TodoItem.parse(csv: csv)
        
        XCTAssertNil(parsedItem)
    }
    
    // MARK: Parsing to CSV
    
    func test_parse_ToCSVWithAllVariants() {
        let sut1 = TodoItem(
            id: "Source#1",
            text: "Submit expense report",
            importance: .high,
            createdAt: Date(timeIntervalSince1970: 1687300000)
        )
        let sut2 = TodoItem(
            id: "Source#2",
            text: "Review meeting notes",
            importance: .low,
            deadline: Date(timeIntervalSince1970: 1687456789),
            isDone: true,
            createdAt: Date(timeIntervalSince1970: 1687600000),
            changedAt: Date(timeIntervalSince1970: 1687700000)
        )
        
        XCTAssertEqual(sut1.csv, "Source#1;Submit expense report;high;;false;1687300000;")
        XCTAssertEqual(sut2.csv, "Source#2;Review meeting notes;low;1687456789;true;1687600000;1687700000")
    }
    
    func test_parse_ToCSVWithNormalImportance() {
        let sut1 = TodoItem(
            id: "SourcePriority#1",
            text: "Clear a desktop",
            importance: .normal,
            deadline: Date(timeIntervalSince1970: TimeInterval(12686522045)),
            isDone: true,
            createdAt: Date(timeIntervalSince1970: 1686846432),
            changedAt: Date(timeIntervalSince1970: 1696883522)
        )
        
        XCTAssertEqual(sut1.csv, "SourcePriority#1;Clear a desktop;;12686522045;true;1686846432;1696883522")
    }
    
    // MARK: Parsing JSON TO CSV and CSV TO JSON
    
    func test_parse_JSONToCSV() {
        let json: [String: Any] = [
            "id": "12345",
            "text": "Complete project tasks",
            "importance": "high",
            "deadline": 1679091200,
            "isDone": false,
            "createdAt": 1679004800,
            "changedAt": 1679080000
        ]
        
        XCTAssertEqual(TodoItem.parse(json: json)?.csv, "12345;Complete project tasks;high;1679091200;false;1679004800;1679080000")
    }
    
    func test_parse_CSVToJSON() {
        let csv = "12345;Complete project tasks;high;1679091200;true;1679004800;1679080000"
        let parsedItem = TodoItem.parse(csv: csv)?.json as? [String: Any]
        
        XCTAssertNotNil(parsedItem)
        XCTAssertEqual(parsedItem?["id"] as? String, "12345")
        XCTAssertEqual(parsedItem?["text"] as? String, "Complete project tasks")
        XCTAssertEqual(parsedItem?["importance"] as? String, "high")
        XCTAssertEqual(parsedItem?["deadline"] as? Int, 1679091200)
        XCTAssertEqual(parsedItem?["isDone"] as? Bool, true)
        XCTAssertEqual(parsedItem?["createdAt"] as? Int, 1679004800)
        XCTAssertEqual(parsedItem?["changedAt"] as? Int, 1679080000)
    }
}
