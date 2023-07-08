//
//  NetworkingErrors.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 07.07.2023.
//

import Foundation

enum NetworkingError: Error {
    case incorrectURL
    case incorrectData
    case parseFailed
}
