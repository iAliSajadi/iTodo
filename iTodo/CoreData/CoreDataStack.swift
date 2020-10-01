//
//  CoreDataStack.swift
//  iTodo
//
//  Created by Ali Sajadi on 9/29/20.
//  Copyright © 2020 Ali Sajadi. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "iTodo")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error loading Persistent Store")
                return
            }
        }
        return container
    }
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    
}
