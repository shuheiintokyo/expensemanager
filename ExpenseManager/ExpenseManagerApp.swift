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
