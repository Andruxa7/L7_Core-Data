//
//  CoreDataManager.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 11/13/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        // Fetch Model URL
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            return nil
        }
        
        // Initialize Managed Object Model
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        
        return managedObjectModel
    }()
    
    
    // ============= Создаём Core Data Stack =============
    
    // persistentStore
    private var persistentStoreURL: NSURL {
        // Helpers
        let storeName = "\(modelName).sqlite"
        let fileManager = FileManager.default
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        return documentsDirectoryURL.appendingPathComponent(storeName) as NSURL
    }
    
    // persistentStoreCoordinator
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = self.managedObjectModel else {
            return nil
        }
        
        // Helper
        let persistentStoreURL = self.persistentStoreURL
        
        // Initialize Persistent Store Coordinators
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL as URL, options: options)
            
        } catch {
            let addPersistentStoreError = error as NSError
            
            print("Unable to Add Persistent Store")
            print("\(addPersistentStoreError.localizedDescription)")
        }
        
        return persistentStoreCoordinator
    }()
    
    // privateManagedObjectContext
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType) // на отдельном от главного потока
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    // mainManagedObjectContext
    internal private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType) // на главном потоке
        
        // Configure Managed Object Context
        managedObjectContext.parent = self.privateManagedObjectContext
        
        return managedObjectContext
    }()
    
    // privateChildManagedObjectContext
    internal func privateChildManagedObjectContext() -> NSManagedObjectContext {
        // Initialize Managed Object Context
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType) // на отдельном от главного потока
        
        // Configure Managed Object Context
        managedObjectContext.parent = self.mainManagedObjectContext
        
        return managedObjectContext
    }
    
    // функция которая будет сохранять наши изменения
    func saveChanges() {
        // mainManagedObjectContext
        mainManagedObjectContext.performAndWait({ // мы хотим СИНХРОННО выполнить этот код (передать информацию)
            do {
                if self.mainManagedObjectContext.hasChanges { // если есть изменения в главном контексте то...
                    try self.mainManagedObjectContext.save() // то сохраняем эти изменения
                }
            } catch {
                // если появилась какая-то ошибка, то мы её распечатаем
                let saveError = error as NSError
                print("Unable to Save Changes of Main Managed Object Context")
                print("\(saveError), \(error.localizedDescription)")
            }
        })
        
        // privateManagedObjectContext
        privateManagedObjectContext.perform({ // мы хотим АСИНХРОННО выполнить этот код (передать информацию)
            do {
                if self.privateManagedObjectContext.hasChanges { // если есть изменения в главном контексте то...
                    try self.privateManagedObjectContext.save() // то сохраняем эти изменения
                }
            } catch {
                // если появилась какая-то ошибка, то мы её распечатаем
                let saveError = error as NSError
                print("Unable to Save Changes of Private Managed Object Context")
                print("\(saveError), \(error.localizedDescription)")
            }
        })
    }
    
}
