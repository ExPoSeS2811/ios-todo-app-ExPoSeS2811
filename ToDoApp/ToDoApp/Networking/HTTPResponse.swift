//
//  HTTPResponse.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 06.07.2023.
//

import Foundation

class HTTPResponse {
    let httpMethod: MethodHttp
    private let path: String
    private let header: [String: String]
    private let httpBody: Data?
    var updateRevision: ((Int) -> ())?
    
    init(path: String, header: [String: String], httpMethod: MethodHttp = .get, httpBody: Data? = nil) {
        self.httpMethod = httpMethod
        self.path = path
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
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        header.forEach { request.addValue($1, forHTTPHeaderField: $0) }

        return request
    }
    
    func performListRequest(completion: @escaping (Result<[TodoItem], Error>) -> ()) {
        do {
            let request = try configureURLRequest()
        } catch {
            completion(.failure(error))
        }
        
        let session = URLSession.shared.dataTask(with: request) { data, req, error in
            print(req)

            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    if let jsn = json as? [String: Any] {
                        if let revision = jsn["revision"] as? Int {
                            self.updateRevision?(revision)
                        }
                        if let list = jsn["list"] as? [Any] {
                            completion(.success(list.compactMap { TodoItem.parse(json: $0) }))
                        }
                    }
                } catch let decodeError {
                    print(decodeError)
                }
            }
        }
        
        session.resume()
    }
    
    func performElementRequest(completion: @escaping (Result<TodoItem, Error>) -> ()) {
        do {
            let request = try configureURLRequest()
        } catch {
            completion(.failure(error))
        }
        
        let session = URLSession.shared.dataTask(with: request) { data, req, error in
            print(req)
            
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    if let jsn = json as? [String: Any] {
                        if let revision = jsn["revision"] as? Int {
                            self.updateRevision?(revision)
                        }
                        if let element = jsn["element"] {
                            guard let parsedItem = TodoItem.parse(json: element) else { return }
                            completion(.success(parsedItem))
                        }
                    }

                } catch let decodeError {
                    print(decodeError)
                }
            }
        }
        
        session.resume()
    }
}

