import Foundation
import SwiftUI

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
    var colorHex: String = "#3B82F6"  // Default blue color
    
    init(id: UUID = UUID(), name: String, colorHex: String = "#3B82F6") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
    
    func getColor() -> Color {
        return Color(hex: colorHex) ?? Color.blue
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6 else { return nil }
        
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    func toHex() -> String {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else {
            return "#3B82F6"
        }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
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

// MARK: - Default Tags (デフォルトタグ) with colors
let defaultTags: [ExpenseTag] = [
    ExpenseTag(name: "スーパー", colorHex: "#22C55E"),      // Green
    ExpenseTag(name: "コンビニ", colorHex: "#3B82F6"),      // Blue
    ExpenseTag(name: "レストラン", colorHex: "#EF4444"),    // Red
    ExpenseTag(name: "カフェ", colorHex: "#A16207"),        // Brown
    ExpenseTag(name: "居酒屋", colorHex: "#A855F7"),        // Purple
    ExpenseTag(name: "交通", colorHex: "#06B6D4"),          // Cyan
    ExpenseTag(name: "娯楽", colorHex: "#F97316"),          // Orange
    ExpenseTag(name: "買い物", colorHex: "#EC4899"),        // Pink
    ExpenseTag(name: "その他", colorHex: "#6B7280"),        // Gray
]
