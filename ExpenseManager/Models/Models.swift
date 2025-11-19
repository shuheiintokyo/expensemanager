import Foundation

// MARK: - Daily Expense (日常支出)
struct DailyExpense: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var amount: Double
    var tag: String?  // Optional tag (e.g., "スーパー", "カフェ")
    var tagNote: String = ""  // Note for specific tag (when selecting "その他" etc)
    var date: Date
    
    var formattedAmount: String {
        String(format: "¥%.0f", amount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Recurring Expense (固定支出 / 月次支出)
struct RecurringExpense: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String  // e.g., "住宅", "電気代", "携帯"
    var budget: Double  // Monthly budget
    var actualSpent: Double  // Actual amount spent this month
    var lastMonthSpent: Double?  // Last month's spent amount
    
    var formattedBudget: String {
        String(format: "¥%.0f", budget)
    }
    
    var formattedActualSpent: String {
        String(format: "¥%.0f", actualSpent)
    }
    
    var formattedLastMonthSpent: String {
        guard let lastMonth = lastMonthSpent else { return "-" }
        return String(format: "¥%.0f", lastMonth)
    }
    
    var budgetRemaining: Double {
        budget - actualSpent
    }
    
    var isOverBudget: Bool {
        actualSpent > budget
    }
}

// MARK: - Expense Tag (タグ用)
struct ExpenseTag: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: - Default Recurring Expenses (固定支出のデフォルト)
let defaultRecurringExpenses: [RecurringExpense] = [
    RecurringExpense(name: "住宅", budget: 100000, actualSpent: 0, lastMonthSpent: 98000),
    RecurringExpense(name: "電気", budget: 5000, actualSpent: 0, lastMonthSpent: 4800),
    RecurringExpense(name: "ガス", budget: 4000, actualSpent: 0, lastMonthSpent: 3900),
    RecurringExpense(name: "携帯", budget: 5000, actualSpent: 0, lastMonthSpent: 5000),
    RecurringExpense(name: "水道", budget: 3000, actualSpent: 0, lastMonthSpent: 2950),
    RecurringExpense(name: "新聞", budget: 2000, actualSpent: 0, lastMonthSpent: 2000),
    RecurringExpense(name: "ヘアカット", budget: 5000, actualSpent: 0, lastMonthSpent: nil),
]

// MARK: - Default Tags (デフォルトタグ)
let defaultTags: [ExpenseTag] = [
    ExpenseTag(name: "スーパー"),
    ExpenseTag(name: "コンビニ"),
    ExpenseTag(name: "レストラン"),
    ExpenseTag(name: "カフェ"),
    ExpenseTag(name: "居酒屋"),
    ExpenseTag(name: "交通"),
    ExpenseTag(name: "娯楽"),
    ExpenseTag(name: "買い物"),
    ExpenseTag(name: "その他"),
]
