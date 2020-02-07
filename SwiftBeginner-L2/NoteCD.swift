//
//  NoteCD.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 11/18/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import Foundation
import CoreData

extension NoteCD {
    @NSManaged var text: String
    @NSManaged var identifier: String
    @NSManaged var userID: String
    @NSManaged var lastModified: Date
}

class NoteCD: NSManagedObject {
    class func createInManagedObjectContext(moc: NSManagedObjectContext, note: Note) {
        let newItem = NoteCD(context: moc)
        
        newItem.text = note.text
        newItem.identifier = note.identifier
        newItem.userID = note.userID
        newItem.lastModified = note.lastModified
    }
    
    // создадим функции которые будут доставать наши заметки из базы данных
    // 1я функция класса для массива заметок
    class func getNotes(from managedObjectContext: NSManagedObjectContext, condition: NSPredicate?) -> [Note]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteCD")
        
        // проверяем было ли какое то условие по поиску заметок
        if let predicate = condition {
            fetchRequest.predicate = predicate
        }
        
        let notes: [Note]?
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            var buffer = [Note]()
            
            for record in records {
                if let noteCD = record as? NoteCD {
                    let note = Note(text: noteCD.text, identifier: noteCD.identifier, userID: noteCD.userID)
                    
                    buffer.append(note)
                }
            }
            
            notes = buffer
            
        } catch {
            let fetchError = error as NSError
            notes = nil
            
            print("\(fetchError),\(fetchError.userInfo)")
        }
        
        return notes
    }
    
    // 2я функция класса для одной заметки
    class func getNoteObject(from context: NSManagedObjectContext, where condition: NSPredicate?) -> NoteCD? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteCD")
        
        // проверяем было ли какое то условие по поиску заметок
        if let predicate = condition {
            fetchRequest.predicate = predicate
        }
        
        let note: NoteCD?
        
        do {
            let records = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            note = records.first as! NoteCD?
        } catch {
            let fetchError = error as NSError
            note = nil
            
            print("\(fetchError),\(fetchError.userInfo)")
        }
        
        return note
    }
    
    // 3я функция класса которая будет возвращать нам заметку по идентификатору
    class func getNote(from context: NSManagedObjectContext, by identifier: String) -> NoteCD? {
        let condition = NSPredicate(format: "identifier == %@", identifier)
        
        return NoteCD.getNoteObject(from: context, where: condition)
    }
    
}
