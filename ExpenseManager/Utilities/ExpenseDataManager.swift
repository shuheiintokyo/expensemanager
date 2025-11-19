import Foundation
import Combine

// MARK: - Data Manager using UserDefaults
class ExpenseDataManager: ObservableObject {
    // MARK: - Published Properties
    @Published var dailyExpenses: [DailyExpense] = []
    @Published var recurringExpenses: [RecurringExpense] = []
    @Published var tags: [ExpenseTag] = []
    
    private let dailyExpensesKey = "dailyExpensesData"
    private let recurringExpensesKey = "recurringExpensesData"
    private let tagsKey = "tagsData"
    
    init() {
        loadDailyExpenses()
        loadRecurringExpenses()
        loadTags()
    }
    
    // MARK: - Daily Expense Operations
    
    func addDailyExpense(_ expense: DailyExpense) {
        dailyExpenses.append(expense)
        saveDailyExpenses()
    }
    
    func deleteDailyExpense(at index: Int) {
        guard index >= 0 && index < dailyExpenses.count else { return }
        dailyExpenses.remove(at: index)
        saveDailyExpenses()
    }
    
    func updateDailyExpense(_ expense: DailyExpense, at index: Int) {
        guard index >= 0 && index < dailyExpenses.count else { return }
        dailyExpenses[index] = expense
        saveDailyExpenses()
    }
    
    func getDailyExpensesForMonth(_ month: Date) -> [DailyExpense] {
        let calendar = Calendar.current
        return dailyExpenses.filter { expense in
            calendar.isDate(expense.date, equalTo: month, toGranularity: .month)
        }
    }
    
    // MARK: - Recurring Expense Operations
    
    func updateRecurringExpense(_ expense: RecurringExpense, at index: Int) {
        guard index >= 0 && index < recurringExpenses.count else { return }
        recurringExpenses[index] = expense
        saveRecurringExpenses()
    }
    
    func addRecurringExpense(_ expense: RecurringExpense) {
        recurringExpenses.append(expense)
        saveRecurringExpenses()
    }
    
    func deleteRecurringExpense(at index: Int) {
        guard index >= 0 && index < recurringExpenses.count else { return }
        recurringExpenses.remove(at: index)
        saveRecurringExpenses()
    }
    
    func getTotalRecurringBudget() -> Double {
        recurringExpenses.reduce(0) { $0 + $1.budget }
    }
    
    func getTotalRecurringSpent() -> Double {
        recurringExpenses.reduce(0) { $0 + $1.actualSpent }
    }
    
    // MARK: - Tag Operations
    
    func addTag(_ tag: ExpenseTag) {
        // Check if tag already exists
        guard !tags.contains(where: { $0.name.lowercased() == tag.name.lowercased() }) else {
            return
        }
        tags.append(tag)
        saveTags()
    }
    
    func deleteTag(at index: Int) {
        guard index >= 0 && index < tags.count else { return }
        tags.remove(at: index)
        saveTags()
    }
    
    func getAvailableTags() -> [String] {
        tags.map { $0.name }.sorted()
    }
    
    // MARK: - Persistence Methods (Daily Expenses)
    
    private func saveDailyExpenses() {
        do {
            let encodedData = try JSONEncoder().encode(dailyExpenses)
            UserDefaults.standard.set(encodedData, forKey: dailyExpensesKey)
            print("✅ Daily expenses saved: \(dailyExpenses.count) items")
        } catch {
            print("❌ Error saving daily expenses: \(error)")
        }
    }
    
    private func loadDailyExpenses() {
        guard let data = UserDefaults.standard.data(forKey: dailyExpensesKey) else {
            print("📝 No daily expenses found, starting fresh")
            return
        }
        
        do {
            dailyExpenses = try JSONDecoder().decode([DailyExpense].self, from: data)
            print("✅ Daily expenses loaded: \(dailyExpenses.count) items")
        } catch {
            print("❌ Error loading daily expenses: \(error)")
            dailyExpenses = []
        }
    }
    
    // MARK: - Persistence Methods (Recurring Expenses)
    
    private func saveRecurringExpenses() {
        do {
            let encodedData = try JSONEncoder().encode(recurringExpenses)
            UserDefaults.standard.set(encodedData, forKey: recurringExpensesKey)
            print("✅ Recurring expenses saved: \(recurringExpenses.count) items")
        } catch {
            print("❌ Error saving recurring expenses: \(error)")
        }
    }
    
    private func loadRecurringExpenses() {
        guard let data = UserDefaults.standard.data(forKey: recurringExpensesKey) else {
            // First time? Load default recurring expenses
            recurringExpenses = defaultRecurringExpenses
            saveRecurringExpenses()
            print("📝 Loaded default recurring expenses")
            return
        }
        
        do {
            recurringExpenses = try JSONDecoder().decode([RecurringExpense].self, from: data)
            print("✅ Recurring expenses loaded: \(recurringExpenses.count) items")
        } catch {
            print("❌ Error loading recurring expenses: \(error)")
            recurringExpenses = defaultRecurringExpenses
        }
    }
    
    // MARK: - Persistence Methods (Tags)
    
    func saveTags() {
        do {
            let encodedData = try JSONEncoder().encode(tags)
            UserDefaults.standard.set(encodedData, forKey: tagsKey)
            print("✅ Tags saved: \(tags.count) items")
        } catch {
            print("❌ Error saving tags: \(error)")
        }
    }
    
    private func loadTags() {
        guard let data = UserDefaults.standard.data(forKey: tagsKey) else {
            // First time? Load default tags
            tags = defaultTags
            saveTags()
            print("📝 Loaded default tags")
            return
        }
        
        do {
            tags = try JSONDecoder().decode([ExpenseTag].self, from: data)
            print("✅ Tags loaded: \(tags.count) items")
        } catch {
            print("❌ Error loading tags: \(error)")
            tags = defaultTags
        }
    }
    
    // MARK: - Debug Helpers
    
    func clearAllData() {
        dailyExpenses.removeAll()
        recurringExpenses = defaultRecurringExpenses
        tags = defaultTags
        saveDailyExpenses()
        saveRecurringExpenses()
        saveTags()
        print("🗑️ All data cleared")
    }
}
