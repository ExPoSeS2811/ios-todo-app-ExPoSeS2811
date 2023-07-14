//
//  HTTPResponse.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 06.07.2023.
//

import Foundation

class HTTPResponse {
    private let httpMethod: MethodHttp
    private let path: String
    private let header: [String: String]
    private let httpBody: Data?
    var updateRevision: ((Int) -> ())?
    
    init(path: String = "", header: [String: String], httpMethod: MethodHttp = .get, httpBody: Data? = nil) {
        self.httpMethod = httpMethod
        self.path = "/todobackend/list" + path
        self.header = header
        self.httpBody = httpBody
    }
    
    private func makeUrl() throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "beta.mrdekk.ru"
        components.path = path
        
        guard let url = components.url else {
            throw NetworkingError.incorrectURL
        }
        
        return url
    }
    
    private func configureURLRequest() throws -> URLRequest {
        let url = try makeUrl()
        
        var request = URLRequest(url: url, timeoutInterval: 60.0)
        request.httpMethod = httpMethod.rawValue.uppercased()
        request.httpBody = httpBody
        header.forEach { request.addValue($1, forHTTPHeaderField: $0) }

        return request
    }
    
    func getResponse(completion: @escaping (Result<[TodoItem], Error>) -> ()) {
        do {
            let request = try configureURLRequest()
            switch httpMethod {
            case .get, .patch:
                performListRequest(request: request, completion: completion)
            case .post, .delete, .put, .getElement:
                performElementRequest(request: request, completion: completion)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func performListRequest(request: URLRequest, completion: @escaping (Result<[TodoItem], Error>) -> ()) {
        let session = URLSession.shared.dataTask(with: request) { data, req, error in

            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkingError.incorrectData))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                if let jsn = json as? [String: Any] {
                    if let revision = jsn["revision"] as? Int {
                        self.updateRevision?(revision)
                    }
                    if let list = jsn["list"] as? [Any] {
                        completion(.success(list.compactMap { TodoItem.parse(json: $0) }))
                    }
                } else {
                    completion(.failure(NetworkingError.parseFailed))
                }
            } catch let decodeError {
                completion(.failure(decodeError))
            }
        }
        
        session.resume()
    }
    
    private func performElementRequest(request: URLRequest, completion: @escaping (Result<[TodoItem], Error>) -> ()) {
        let session = URLSession.shared.dataTask(with: request) { data, req, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkingError.incorrectData))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                if let jsn = json as? [String: Any] {
                    if let revision = jsn["revision"] as? Int {
                        self.updateRevision?(revision)
                    }
                    if let list = jsn["element"] as? [Any] {
                        completion(.success(list.compactMap { TodoItem.parse(json: $0) }))
                    }
                } else {
                    completion(.failure(NetworkingError.parseFailed))
                }
            } catch let decodeError {
                completion(.failure(decodeError))
            }
        }
        session.resume()
    }
}
