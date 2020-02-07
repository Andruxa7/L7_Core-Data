//
//  DataController.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 7/29/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

protocol DataControllerDelegate {
    func dataSourseChanged(dataSourse: [Note]?, error: Error?)
}

enum NoteModificationTask {
    case create
    case edit
    case delete
}

import Foundation

class DataController {
    var notes: [Note]?
    var delegate: DataControllerDelegate?
    
    // создаем и инициализируем очередь для операций
    var modifyNotesQueue = OperationQueue()
    var getNotesQueue = OperationQueue()
    
    // создаем "CoreDataManager"
    var coreDataManager: CoreDataManager!
    
    // создаем очередь для загрузки из сети
    let loadNotesQueue = DispatchQueue(label: "com.NotesApp.getNotes")

    
    func getNotes() {
        // загрузка заметок из памяти телефона будет происходить синхронно (почти мгновенно!), ещё до того как мы обратимся к сети
        if let notes = NoteCD.getNotes(from: coreDataManager.privateChildManagedObjectContext(), condition: nil) {
            self.notes = notes.sorted(by: {$0.lastModified < $1.lastModified})
            self.delegate?.dataSourseChanged(dataSourse: self.notes, error: nil)
        }
        
        // а загрузка заметок из сети (интернет) будет происходить асинхронно
        loadNotesQueue.async {
            let fetchNotes = GetNotesOperation()
            let parseNotesJSONOperation = ParseNotesJSONOperation(managedObjectContext: self.coreDataManager.privateChildManagedObjectContext())
            
            let adapterOperation = BlockOperation {
                // print("fetch notes data = \(fetchNotes.data!)")
                parseNotesJSONOperation.data = fetchNotes.data
                parseNotesJSONOperation.error = fetchNotes.error
            }

            /*let finishOperation = BlockOperation {
                // в этом блоке мы проверяем получилось ли у нас распарсить наши данные
                self.notes = parseNotesJSONOperation.notes
                // и оповестим об этом наш делегат
                self.delegate?.dataSourseChanged(dataSourse: self.notes, error: parseNotesJSONOperation.error)
                
                // проверяем и сохраняем
                if let notes = self.notes {
                    // сохраняем наши заметки скачаные из интернета в CoreData
                    let saveNotesOperation = SaveNotesOperation(notes: notes, context: self.coreDataManager.privateChildManagedObjectContext())
                    // добавляем операцию сохранения заметок в очередь
                    self.getNotesQueue.addOperation(saveNotesOperation)
                }
            }*/
            
            let finishOperation = BlockOperation {
                // в этом блоке мы проверяем получилось ли у нас распарсить наши данные
                if let notes = parseNotesJSONOperation.notes {
                    // если да, то мы их присвоим нашему массиву "self.notes" (DataController)
                    self.notes = notes
                    // и оповестим об этом наш делегат
                    self.delegate?.dataSourseChanged(dataSourse: self.notes, error: nil)
                    
                    // сохраняем наши заметки скачаные из интернета в CoreData
                    let saveNotesOperation = SaveNotesOperation(notes: notes, context: self.coreDataManager.privateChildManagedObjectContext())
                    // добавляем операцию сохранения заметок в очередь
                    self.getNotesQueue.addOperation(saveNotesOperation)
                }
            }

            // создаём зависимость операций. Говорим что "adapterOperation" зависит от "fetchNotes"
            adapterOperation.addDependency(fetchNotes)
            parseNotesJSONOperation.addDependency(adapterOperation)
            finishOperation.addDependency(parseNotesJSONOperation)

            // фармируем очередь операций. Перечисляем операции в массиве, первой операцией будет "fetchNotes" а следующей "fetchNotes"
            self.getNotesQueue.addOperations([fetchNotes, adapterOperation, parseNotesJSONOperation, finishOperation], waitUntilFinished: true)
        }
        
    }

    func modify(note: Note, task: NoteModificationTask) {
        
        let context = coreDataManager.privateChildManagedObjectContext()
        
        if var notes = self.notes {
            switch task {
            case .create:
                NoteCD.createInManagedObjectContext(moc: context, note: note)
                notes.insert(note, at: 0)
                break
            case .edit:
                // тут мы говорим что верни нам индекс который равен заметке "note"
                if let index = notes.firstIndex(where: {$0 == note}) {
                    notes[index] = note
                }
                
                // для изменения заметки в CoreData используем сущность NoteCD и её метод getNote(from:, by:) и ищем заметку в контексте по идентификатору
                if let noteCD = NoteCD.getNote(from: context, by: note.identifier) {
                    // записываем текст заметки в базу данных (CoreData)
                    noteCD.text = note.text
                }
                break
            case .delete:
                // тут мы говорим что нужно удалить заметку по индексу который равен заметке "note"
                if let index = notes.firstIndex(where: {$0 == note}) {
                    notes.remove(at: index)
                }
                
                // для удаления заметки из CoreData используем сущность NoteCD и её метод getNote(from:, by:) и ищем заметку в контексте по идентификатору
                if let noteCD = NoteCD.getNote(from: context, by: note.identifier) {
                    // удаляем заметку из базы данных (CoreData)
                    context.delete(noteCD)
                }
                break
            }
            
            self.notes = notes
            
            // теперь нам нужно оповестить об обновлении значений нашего подписчика (делегата)
            self.delegate?.dataSourseChanged(dataSourse: self.notes, error: nil)
            
            // теперь нам нужно сохранить наш "context"
            context.performAndWait {
                do {
                    if context.hasChanges { // если есть изменения в этом контексте то...
                        try context.save() // то сохраняем эти изменения
                    }
                } catch {
                    // если появилась какая-то ошибка, то мы её распечатаем
                    let saveError = error as NSError
                    print("Unable to Save Changes of Managed Object Context")
                    print("\(saveError), \(error.localizedDescription)")
                }
            }
        }

        // создаем операцию, например под названием "modification"
        let modification = ModifyNoteOperation(note: note, task: task)

        // в нашу очередь добавляем операцию "modification" и заметка будет (добавляться, изменяться или удаляться)!!!!!
        modifyNotesQueue.addOperation(modification)
    }

}
