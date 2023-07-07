//
//  URLSession.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 04.07.2023.
//

import UIKit

//extension URLSession {
//    func dataTask(for urlRequest: URLRequest, completion: @escaping @Sendable (Result<(Data, URLResponse), Error>) -> Void) {
//        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data, let response = response else {
//                let error = NSError(domain: "URLSession", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response or data received"])
//                completion(.failure(error))
//                return
//            }
//
//            completion(.success((data, response)))
//        }
//        task.resume()
//    }
//}
