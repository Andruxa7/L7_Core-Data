//
//  SaveNotesOperation.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 11/20/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import Foundation
import CoreData

class SaveNotesOperation: OperationWhithFinished {
    let notes: [Note]
    
    private let managedObjectContext: NSManagedObjectContext
    
    init(notes: [Note], context: NSManagedObjectContext) {
        self.notes = notes
        self.managedObjectContext = context
    }
    
    override func main() {
        
        for note in notes {
            NoteCD.createInManagedObjectContext(moc: managedObjectContext, note: note)
        }
        
        saveChanges()
        
        self.isFinished = true
    }
    
    // функция которая будет сохранять наши изменения
    private func saveChanges() {
        // managedObjectContext
        managedObjectContext.performAndWait({ // мы хотим СИНХРОННО выполнить этот код (передать информацию)
            do {
                if self.managedObjectContext.hasChanges { // если есть изменения в этом контексте то...
                    try self.managedObjectContext.save() // то сохраняем эти изменения
                }
            } catch {
                // если появилась какая-то ошибка, то мы её распечатаем
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(error.localizedDescription)")
            }
        })
    }
    
}
