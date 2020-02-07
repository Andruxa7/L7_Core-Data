//
//  ModifyNoteOperation.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 8/1/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import Foundation

class ModifyNoteOperation: OperationWhithFinished {
    var error: Error?
    
    let modification: NoteModificationTask
    let note: Note!

    init(note: Note, task: NoteModificationTask) {
        self.note = note
        self.modification = task
    }

    override func main() {
        if isCancelled {
            return
        }

        let requestMethod: String
        let identifier: String
        let requestData: Data?

        switch modification {
        case .create:
            // запрос создания
            requestMethod = "PUT"
            // создаем уникальный идентификатор
            identifier = UUID().uuidString

            // создаем структуру которую мы передаем на сервер (в виде словаря)
            //"notetext": self.note.text
            //"userID": UserDefaults.standard.value(forKey: "UserIdentifier")
            //"userID": self.note.userID
            //"lastModified": "\(self.note.lastModified.timeIntervalSince1970)"
            let note = ["notetext": self.note.text,
                        "userID": UserDefaults.standard.value(forKey: "UserIdentifier"),
                        "lastModified": "\(self.note.lastModified.timeIntervalSince1970)"]
            // тепере можем заполнить данные запроса с помощью JSON - (англ. JavaScript Object Notation, обычно произносится как /ˈdʒeɪsən/ JAY-sən) — текстовый формат обмена данными, основанный на JavaScript).
            requestData = try! JSONSerialization.data(withJSONObject: note, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            break
        case .edit:
            requestMethod = "PUT"
            // в этом "case" мы берем тот идентификатор заметки которую мы изменяем
            identifier = self.note.identifier

            // создаем структуру которую мы передаем на сервер (в виде словаря)
            let note = ["notetext": self.note.text,
                        "userID": UserDefaults.standard.value(forKey: "UserIdentifier"),
                        "lastModified": "\(self.note.lastModified.timeIntervalSince1970)"]
            // тепере можем заполнить данные запроса с помощью JSON - (англ. JavaScript Object Notation, обычно произносится как /ˈdʒeɪsən/ JAY-sən) — текстовый формат обмена данными, основанный на JavaScript).
            requestData = try! JSONSerialization.data(withJSONObject: note, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            break
        case .delete:
            requestMethod = "Delete"
            identifier = self.note.identifier
            requestData = nil
            break
        }

        // создаём запрос который нужно отправить на сервер
        // например берём из:
        // https://docs.appbase.io/api/rest/quickstart/
        // раздел "Modify the Document"
        // https://$credentials@scalr.api.appbase.io/$app/books/1
        let request = NSMutableURLRequest(url: NSURL(string: "https://uc_itf31GmIK:bea8cd90-17b7-4cef-bd00-7f3335e55012@scalr.api.appbase.io/NotesApp/note/\(identifier)")! as URL)

        request.httpBody = requestData
        request.httpMethod = requestMethod

        // после этого мы должны отправить наш запрос
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            // делаем через (do/catch) проверку
            do {
                let str = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! [String: AnyObject]
                print(str)
            } catch {
                // в этом блоке обрабатываем ошибку
                print("json parse error: \(error)")
            }

            // у каждой операции есть свойство (isFinished)
            // сдесь важно в конце операции сказать что наша операция закончена
            self.isFinished = true
        }

        // для того чтобы наш запрос начал выполняться нужно его запустить с помощью команды "resume()"
        task.resume()
    }

}
