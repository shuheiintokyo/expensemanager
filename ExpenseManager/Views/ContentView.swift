import SwiftUI

// MARK: - ContentView (Main Tab Navigation - iPhone only)
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // TAB 1: Daily Expense Input
            DailyExpenseInputView()
                .tabItem {
                    Label("Daily", systemImage: "creditcard.fill")
                }
                .tag(0)
            
            // TAB 2: Recurring Expense Input
            RecurringExpenseInputView()
                .tabItem {
                    Label("Monthly", systemImage: "calendar")
                }
                .tag(1)
            
            // TAB 3: Dashboard (Analytics)
            OutputView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            // TAB 4: Settings
            SettingsView()
                .tabItem {
                    Label("Setting", systemImage: "gear")
                }
                .tag(3)
        }
        .onChange(of: selectedTab) { _ in
            // Dismiss keyboard when changing tabs
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ExpenseDataManager())
}
