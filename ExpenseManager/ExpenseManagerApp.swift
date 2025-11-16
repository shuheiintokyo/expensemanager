//
//  ExpenseManagerApp.swift
//  ExpenseManager
//
//  Created by Shuhei Kinugasa on 2025/11/16.
//

import SwiftUI

@main
struct ExpenseManagerApp: App {
    @StateObject private var dataManager = ExpenseDataManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
