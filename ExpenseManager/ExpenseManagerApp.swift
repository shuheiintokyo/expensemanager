//
//  ExpenseManagerApp.swift
//  ExpenseManager
//
//  Created by Shuhei Kinugasa on 2025/11/16.
//

import SwiftUI
import CoreData

@main
struct ExpenseManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
