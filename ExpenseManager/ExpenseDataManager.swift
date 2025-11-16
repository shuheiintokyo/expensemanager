import Foundation

// MARK: - Data Manager using UserDefaults
// This handles all local storage operations
// UserDefaults is simple key-value storage perfect for small app data
// For large datasets, you'd use CoreData or SQLite, but UserDefaults is great for learning

class ExpenseDataManager: ObservableObject {
    // MARK: Published Properties
    // @Published makes SwiftUI automatically update the UI when these change
    // ObservableObject allows this to be used with @StateObject
    
    @Published var expenses: [ExpenseItem] = []
    @Published var categories: [ExpenseCategory] = []
    
    private let expensesKey = "expensesData"
    private let categoriesKey = "categoriesData"
    
    init() {
        // Load data when the app starts
        loadExpenses()
        loadCategories()
    }
    
    // MARK: - Expense Operations
    
    /// Add a new expense and immediately save to UserDefaults
    func addExpense(_ expense: ExpenseItem) {
        expenses.append(expense)
        saveExpenses()
    }
    
    /// Delete an expense by removing it from array and saving
    func deleteExpense(at index: Int) {
        expenses.remove(at: index)
        saveExpenses()
    }
    
    /// Update an existing expense
    func updateExpense(_ expense: ExpenseItem, at index: Int) {
        expenses[index] = expense
        saveExpenses()
    }
    
    /// Get all expenses for a specific month
    func getExpensesForMonth(_ month: Date) -> [ExpenseItem] {
        let calendar = Calendar.current
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: month, toGranularity: .month)
        }
    }
    
    /// Get total spending for a category in a month
    func getCategoryTotal(category: String, for month: Date) -> Double {
        let monthExpenses = getExpensesForMonth(month)
        return monthExpenses
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Category Operations
    
    func addCategory(_ category: ExpenseCategory) {
        categories.append(category)
        saveCategories()
    }
    
    func deleteCategory(at index: Int) {
        categories.remove(at: index)
        saveCategories()
    }
    
    func updateCategory(_ category: ExpenseCategory, at index: Int) {
        categories[index] = category
        saveCategories()
    }
    
    // MARK: - Persistence Methods
    
    private func saveExpenses() {
        // Convert our expense structs to JSON data
        let encodedData = try? JSONEncoder().encode(
            expenses.map { (id: $0.id, amount: $0.amount, category: $0.category, date: $0.date, notes: $0.notes) }
        )
        
        // Store the JSON data in UserDefaults
        UserDefaults.standard.set(encodedData, forKey: expensesKey)
        print("✅ Expenses saved")
    }
    
    private func loadExpenses() {
        // Retrieve JSON data from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: expensesKey) else {
            print("No expenses found, starting fresh")
            return
        }
        
        // Decode JSON back into ExpenseItem objects
        do {
            let decoded = try JSONDecoder().decode(
                [(id: UUID, amount: Double, category: String, date: Date, notes: String)].self,
                from: data
            )
            expenses = decoded.map { ExpenseItem(id: $0.id, amount: $0.amount, category: $0.category, date: $0.date, notes: $0.notes) }
            print("✅ Expenses loaded: \(expenses.count) items")
        } catch {
            print("❌ Error loading expenses: \(error)")
        }
    }
    
    private func saveCategories() {
        let encodedData = try? JSONEncoder().encode(categories)
        UserDefaults.standard.set(encodedData, forKey: categoriesKey)
        print("✅ Categories saved")
    }
    
    private func loadCategories() {
        guard let data = UserDefaults.standard.data(forKey: categoriesKey) else {
            // First time? Load default categories
            categories = defaultCategories
            saveCategories()
            return
        }
        
        do {
            categories = try JSONDecoder().decode([ExpenseCategory].self, from: data)
            print("✅ Categories loaded: \(categories.count) items")
        } catch {
            print("❌ Error loading categories: \(error)")
            categories = defaultCategories
        }
    }
    
    // MARK: - Debug Helpers
    
    func clearAllData() {
        expenses.removeAll()
        categories = defaultCategories
        saveExpenses()
        saveCategories()
        print("🗑️ All data cleared")
    }
}
