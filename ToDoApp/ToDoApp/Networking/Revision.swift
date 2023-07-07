//
//  Revision.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 07.07.2023.
//

import Foundation

class Revision {
    private var revision: Int = 0
    
    func updateRevision(num: Int) {
        self.revision = num
    }
    
    func getRevision() -> String {
        return String(revision)
    }
}
