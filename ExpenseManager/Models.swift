import Foundation

// MARK: - ExpenseItem
// ============================================
// This represents a single expense record
// Codable = can convert to/from JSON (for UserDefaults)
// Identifiable = has unique id (for ForEach in SwiftUI)
// Hashable = can be used in Sets/Dictionaries

struct ExpenseItem: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var amount: Double
    var category: String
    var date: Date
    var notes: String = ""
    
    init(
        id: UUID = UUID(),
        amount: Double,
        category: String,
        date: Date,
        notes: String = ""
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
    }
    
    var formattedAmount: String {
        String(format: "¥%.2f", amount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - ExpenseCategory
// ============================================
// Represents a spending category (Food, Utilities, etc.)

struct ExpenseCategory: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var color: String
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: String
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
    }
}

// MARK: - Default Categories
// ============================================
// Initial categories loaded on first app launch
// Users can add/delete in Settings tab

let defaultCategories: [ExpenseCategory] = [
    ExpenseCategory(name: "食べ物", icon: "🍽️", color: "orange"),
    ExpenseCategory(name: "電気代", icon: "⚡", color: "yellow"),
    ExpenseCategory(name: "水道代", icon: "💧", color: "blue"),
    ExpenseCategory(name: "衣類", icon: "👕", color: "pink"),
    ExpenseCategory(name: "エンターテイメント", icon: "🎬", color: "purple"),
    ExpenseCategory(name: "交通費", icon: "🚗", color: "green"),
    ExpenseCategory(name: "その他", icon: "📦", color: "gray")
]
