import Foundation
import Combine

// MARK: - Data Manager using UserDefaults
// Simple key-value storage for expenses and categories
// Perfect for learning SwiftUI without Core Data complexity

class ExpenseDataManager: ObservableObject {
    // MARK: - Published Properties
    // @Published makes SwiftUI update UI when these change
    @Published var expenses: [ExpenseItem] = []
    @Published var categories: [ExpenseCategory] = []
    
    private let expensesKey = "expensesData"
    private let categoriesKey = "categoriesData"
    
    init() {
        loadExpenses()
        loadCategories()
    }
    
    // MARK: - Expense Operations
    
    func addExpense(_ expense: ExpenseItem) {
        expenses.append(expense)
        saveExpenses()
    }
    
    func deleteExpense(at index: Int) {
        guard index >= 0 && index < expenses.count else { return }
        expenses.remove(at: index)
        saveExpenses()
    }
    
    func updateExpense(_ expense: ExpenseItem, at index: Int) {
        guard index >= 0 && index < expenses.count else { return }
        expenses[index] = expense
        saveExpenses()
    }
    
    func getExpensesForMonth(_ month: Date) -> [ExpenseItem] {
        let calendar = Calendar.current
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: month, toGranularity: .month)
        }
    }
    
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
        guard index >= 0 && index < categories.count else { return }
        categories.remove(at: index)
        saveCategories()
    }
    
    func updateCategory(_ category: ExpenseCategory, at index: Int) {
        guard index >= 0 && index < categories.count else { return }
        categories[index] = category
        saveCategories()
    }
    
    // MARK: - Persistence Methods
    
    private func saveExpenses() {
        do {
            let encodedData = try JSONEncoder().encode(expenses)
            UserDefaults.standard.set(encodedData, forKey: expensesKey)
            print("✅ Expenses saved: \(expenses.count) items")
        } catch {
            print("❌ Error saving expenses: \(error)")
        }
    }
    
    private func loadExpenses() {
        guard let data = UserDefaults.standard.data(forKey: expensesKey) else {
            print("📝 No expenses found, starting fresh")
            return
        }
        
        do {
            expenses = try JSONDecoder().decode([ExpenseItem].self, from: data)
            print("✅ Expenses loaded: \(expenses.count) items")
        } catch {
            print("❌ Error loading expenses: \(error)")
            expenses = []
        }
    }
    
    private func saveCategories() {
        do {
            let encodedData = try JSONEncoder().encode(categories)
            UserDefaults.standard.set(encodedData, forKey: categoriesKey)
            print("✅ Categories saved: \(categories.count) items")
        } catch {
            print("❌ Error saving categories: \(error)")
        }
    }
    
    private func loadCategories() {
        guard let data = UserDefaults.standard.data(forKey: categoriesKey) else {
            // First time? Load default categories
            categories = defaultCategories
            saveCategories()
            print("📝 Loaded default categories")
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
