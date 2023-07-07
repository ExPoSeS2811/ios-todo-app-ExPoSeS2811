//
//  URLSession.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 04.07.2023.
//

import Foundation

protocol NetworkService {
    var httpResponse: HTTPResponse? { get set }
}

class DefaultNetworkService: NetworkService {
    var httpResponse: HTTPResponse?

    static var revision: Int {
        get {
            UserDefaults.standard.integer(forKey: "revision")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "revision")
        }
    }

    private var header = [
        "Authorization": "Bearer progeotropism",
    ]

    private func configureResponse(selectedResponse: MethodHttp) -> HTTPResponse {
        header["X-Last-Known-Revision"] = String(DefaultNetworkService.revision)
        switch selectedResponse {
        case .get:
            return HTTPResponse(path: "/todobackend/list", header: header)
        case .post(let item):
            return HTTPResponse(
                path: "/todobackend/list",
                header: header,
                httpMethod: .post(item),
                httpBody: try? JSONSerialization.data(withJSONObject: ["element": item.json], options: [])
            )
        case .patch(let items):
            return HTTPResponse(
                path: "/todobackend/list",
                header: header,
                httpMethod: .patch(items),
                httpBody: try? JSONSerialization.data(withJSONObject: ["list": items.map { $0.json }])
            )
        case .delete(let id):
            return HTTPResponse(
                path: "/todobackend/list/\(id)",
                header: header,
                httpMethod: .delete(id)
            )
        case .put(let id, let item):
            return HTTPResponse(
                path: "/todobackend/list/\(id)",
                header: header,
                httpMethod: .put(id, item),
                httpBody: try? JSONSerialization.data(withJSONObject: ["element": item.json], options: [])
            )
        case .getElement(let id):
            return HTTPResponse(
                path: "/todobackend/list/\(id)",
                header: header,
                httpMethod: .getElement(id)
            )
        }
    }
    
    func getList(completion: @escaping (Result<[TodoItem], Error>) -> ()) {
        self.httpResponse = configureResponse(selectedResponse: .get)
        httpResponse?.performListRequest(completion: completion)
    }
    
    func postElementItem(item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> ()) {
        self.httpResponse = configureResponse(selectedResponse: .post(item))
        httpResponse?.performElementRequest(completion: completion)
    }
    
    func getElementItem(id: String, completion: @escaping (Result<TodoItem, Error>) -> ()) {
        self.httpResponse = configureResponse(selectedResponse: .getElement(id))
        httpResponse?.performElementRequest(completion: completion)
    }
    
    func patchList(items: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> ()) {
        self.httpResponse = configureResponse(selectedResponse: .patch(items))
        httpResponse?.performListRequest(completion: completion)
    }
    
    func putElementItem(id: String, item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> ()) {
        self.httpResponse = configureResponse(selectedResponse: .put(id, item))
        httpResponse?.performElementRequest(completion: completion)
    }
    
    func deleteElementItem(id: String, completion: @escaping (Result<TodoItem, Error>) -> ()) {
        self.httpResponse = configureResponse(selectedResponse: .delete(id))
        httpResponse?.performElementRequest(completion: completion)
    }
}

enum MethodHttp {
    case get
    case post(TodoItem)
    case patch([TodoItem])
    case delete(String)
    case put(String, TodoItem)
    case getElement(String)

    var rawValue: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        case .put: return "PUT"
        case .getElement: return "GET"
        }
    }
}
