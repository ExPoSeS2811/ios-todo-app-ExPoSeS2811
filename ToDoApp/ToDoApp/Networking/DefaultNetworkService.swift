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
            return HTTPResponse(header: header)
        case .post(let item):
            return HTTPResponse(
                header: header,
                httpMethod: .post(item),
                httpBody: try? JSONSerialization.data(withJSONObject: ["element": item.json], options: [])
            )
        case .patch(let items):
            return HTTPResponse(
                header: header,
                httpMethod: .patch(items),
                httpBody: try? JSONSerialization.data(withJSONObject: ["list": items.map { $0.json }])
            )
        case .delete(let id):
            return HTTPResponse(
                path: "/\(id)",
                header: header,
                httpMethod: .delete(id)
            )
        case .put(let id, let item):
            return HTTPResponse(
                path: "/\(id)",
                header: header,
                httpMethod: .put(id, item),
                httpBody: try? JSONSerialization.data(withJSONObject: ["element": item.json], options: [])
            )
        case .getElement(let id):
            return HTTPResponse(
                path: "/\(id)",
                header: header,
                httpMethod: .getElement(id)
            )
        }
    }

    func makeRequest(with response: MethodHttp = .get, completion: @escaping (Result<[TodoItem], Error>) -> ()) {
        self.httpResponse = configureResponse(selectedResponse: response)
        httpResponse?.updateRevision = { value in
            DefaultNetworkService.revision = value
        }
        httpResponse?.getResponse(completion: completion)
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
