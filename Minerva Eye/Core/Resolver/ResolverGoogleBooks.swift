//
//  Resolver.swift
//  Minerva Eye
//
//  Created by Tomas Korcak on 4/27/20.
//  Copyright © 2020 Tomas Korcak. All rights reserved.
//

import Foundation

class ResolverGoogleBooks {
    static private var cache: [String: BookItem] = [:]
    
    enum LookupError: Error {
        case wrongRequest
        case wrongResponse
    }
    
    static func fetchBookInfo(isbn: String) -> Result<BookItem?, LookupError> {
        
        if let book = cache[isbn] {
            Logger.log(msg: "Using cached book info - ISBN: \(isbn)")
            return .success(book)
        }
        
        let path = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)&key=AIzaSyD9VE8TZy5ai4Ioc3Kzagr2ehibpiksxKA"
        guard let url = URL(string: path) else {
            return .failure(.wrongRequest)
        }
        
        var result: Result<BookItem?, LookupError>!
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Logger.log(msg: "Calling Google Books API - ISBN: \(isbn)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                Logger.log(msg: "Google Books API failed - ISBN: \(isbn), error: \(error)")
                result = .failure(.wrongResponse)
            }
            
            if let data = data {
                Logger.log(msg: "Google Books API returned data - \(data)")
                
                do {
                    let res = try JSONDecoder().decode(BookQueryResult.self, from: data)
                    if(!res.items.isEmpty) {
                        let book = res.items[0]
                        self.cache[isbn] = book
                        result = .success(book)
                    }
                    
                } catch  {
                    Logger.log(msg: "Unable to decode Google Books API response - ISBN: \(isbn)")
                    result = .failure(.wrongResponse)
                }
            }
            
            semaphore.signal()
        }.resume()
                
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return result
    }
}
