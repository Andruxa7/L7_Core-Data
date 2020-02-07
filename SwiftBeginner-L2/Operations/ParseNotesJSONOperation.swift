//
//  ParseNotesJSONOperation.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 10/16/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import Foundation
import CoreData

class ParseNotesJSONOperation: OperationWhithFinished {
    
    var data: Data?
    var error: Error?
    
    var notes: [Note]?
    
    private let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext:NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    override func main() {
        
        print("ParseNotesJSONOperation started")
        
        // выходим из операции если она была отменена
        if isCancelled {
            return
        }

        // распаковываем нашу дату
        guard let responseData = data else {
            print("parse Notes failed - no data to parse")
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                if let notes = Notes(JSON: json) {
                    print("json parsed Notes: \(notes)")

                    self.notes = notes.notes.sorted(by: {$0.lastModified < $1.lastModified})
                }
            }
        } catch {
            print("json error: \(error)")
        }

        self.isFinished = true
    }

}
