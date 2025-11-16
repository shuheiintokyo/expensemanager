import SwiftUI

// MARK: - ContentView (Main Tab Navigation)
// ============================================
// This is the root view that manages three tabs
// KEY CONCEPT: @State for tab selection
// @State = SwiftUI's way to manage LOCAL state (only this view cares about it)

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        // TabView creates the bottom tab bar
        // selection: binding connects to @State selectedTab
        TabView(selection: $selectedTab) {
            
            // TAB 1: Input View (Add expenses)
            InputView()
                .tabItem {
                    Label("入力", systemImage: "plus.circle.fill")
                }
                .tag(0)
            
            // TAB 2: Output View (View analytics)
            OutputView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            // TAB 3: Settings View (Manage categories)
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .tag(2)
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
