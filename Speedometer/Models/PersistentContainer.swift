//
//  PersistentContainer.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/12.
//

import CoreData


class PersistentContainer: NSPersistentContainer {

    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
}
