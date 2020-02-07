//
//  GetNotesOperation.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 10/12/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import Foundation

class GetNotesOperation: OperationWhithFinished {
    
    var data: Data?
    var error: Error?

    override func main() {
        print("GetNotesOperation started")
        // здесь в конце строки вместо идентификатора "\(identifier)", ключевое слово "_search" т.е. мы будем искать
        let request = NSMutableURLRequest(url: NSURL(string: "https://uc_itf31GmIK:bea8cd90-17b7-4cef-bd00-7f3335e55012@scalr.api.appbase.io/NotesApp/note/_search")! as URL)

        request.httpMethod = "POST"

        // и после этого строим запрос на сервер в виде словаря
        let query = ["query": ["match": ["userID": UserDefaults.standard.value(forKey: "UserIdentifier")]]]

        request.httpBody = try! JSONSerialization.data(withJSONObject: query, options: JSONSerialization.WritingOptions.init(rawValue: 0))

        // после этого мы должны отправить наш запрос
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            self.data = data
            self.error = error

            print("get notes finished")
            // print("GOT NOTES = \(data!)")

            // у каждой операции есть свойство (isFinished)
            // сдесь важно в конце операции сказать что наша операция закончена
            self.isFinished = true
        }

        // для того чтобы наш запрос начал выполняться нужно его запустить с помощью команды "resume()"
        task.resume()
    }

}
