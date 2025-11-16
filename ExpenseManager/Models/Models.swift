import Foundation

// MARK: - ExpenseItem (unchanged)
struct ExpenseItem: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var amount: Double
    var category: String          // This will be the mediumClass
    var largeCategory: String     // NEW: The parent large category
    var date: Date
    var notes: String = ""
    
    init(
        id: UUID = UUID(),
        amount: Double,
        category: String,
        largeCategory: String,
        date: Date,
        notes: String = ""
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.largeCategory = largeCategory
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

// MARK: - ExpenseCategory (Hierarchical)
struct ExpenseCategory: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var largeClass: String      // e.g., "Housing", "Utilities", "Food"
    var mediumClass: String     // e.g., "Rent Fee", "Electricity", "Supermarket"
    var smallClass: String?     // Optional: e.g., "Monthly", "Weekly"
    var icon: String
    var color: String
    
    init(
        id: UUID = UUID(),
        largeClass: String,
        mediumClass: String,
        smallClass: String? = nil,
        icon: String,
        color: String
    ) {
        self.id = id
        self.largeClass = largeClass
        self.mediumClass = mediumClass
        self.smallClass = smallClass
        self.icon = icon
        self.color = color
    }
}

// MARK: - Default Categories (Hierarchical Structure)
let defaultCategories: [ExpenseCategory] = [
    // MARK: - Housing (住宅)
    ExpenseCategory(largeClass: "住宅", mediumClass: "家賃", icon: "🏠", color: "orange"),
    ExpenseCategory(largeClass: "住宅", mediumClass: "ローン", icon: "🏠", color: "orange"),
    ExpenseCategory(largeClass: "住宅", mediumClass: "管理費", icon: "🏠", color: "orange"),
    
    // MARK: - Utilities (光熱費・通信費)
    ExpenseCategory(largeClass: "光熱費", mediumClass: "電気", icon: "⚡", color: "yellow"),
    ExpenseCategory(largeClass: "光熱費", mediumClass: "ガス", icon: "🔥", color: "yellow"),
    ExpenseCategory(largeClass: "光熱費", mediumClass: "水道", icon: "💧", color: "yellow"),
    ExpenseCategory(largeClass: "光熱費", mediumClass: "携帯", icon: "📱", color: "yellow"),
    ExpenseCategory(largeClass: "光熱費", mediumClass: "インターネット", icon: "📡", color: "yellow"),
    ExpenseCategory(largeClass: "光熱費", mediumClass: "その他", icon: "📶", color: "yellow"),
    
    // MARK: - Food (食費)
    ExpenseCategory(largeClass: "食費", mediumClass: "スーパー", icon: "🛒", color: "green"),
    ExpenseCategory(largeClass: "食費", mediumClass: "コンビニ", icon: "🏪", color: "green"),
    ExpenseCategory(largeClass: "食費", mediumClass: "その他", icon: "🍽️", color: "green"),
    
    // MARK: - Outing (外出費)
    ExpenseCategory(largeClass: "外出", mediumClass: "レストラン", icon: "🍽️", color: "red"),
    ExpenseCategory(largeClass: "外出", mediumClass: "バー", icon: "🍺", color: "red"),
    ExpenseCategory(largeClass: "外出", mediumClass: "居酒屋", icon: "🍶", color: "red"),
    ExpenseCategory(largeClass: "外出", mediumClass: "ファストフード", icon: "🍔", color: "red"),
    
    // MARK: - Transport (交通費)
    ExpenseCategory(largeClass: "交通費", mediumClass: "電車", icon: "🚆", color: "blue"),
    ExpenseCategory(largeClass: "交通費", mediumClass: "タクシー", icon: "🚕", color: "blue"),
    ExpenseCategory(largeClass: "交通費", mediumClass: "ガソリン", icon: "⛽", color: "blue"),
    ExpenseCategory(largeClass: "交通費", mediumClass: "その他", icon: "🚗", color: "blue"),
    
    // MARK: - Cosmetics (美容)
    ExpenseCategory(largeClass: "美容", mediumClass: "スキンケア", icon: "💅", color: "pink"),
    ExpenseCategory(largeClass: "美容", mediumClass: "ヘアケア", icon: "💇", color: "pink"),
    ExpenseCategory(largeClass: "美容", mediumClass: "その他", icon: "💄", color: "pink"),
    
    // MARK: - Education (教育)
    ExpenseCategory(largeClass: "教育", mediumClass: "本", icon: "📚", color: "purple"),
    ExpenseCategory(largeClass: "教育", mediumClass: "講座", icon: "🎓", color: "purple"),
    ExpenseCategory(largeClass: "教育", mediumClass: "その他", icon: "📖", color: "purple"),
    
    // MARK: - Healthcare (医療)
    ExpenseCategory(largeClass: "医療", mediumClass: "病院", icon: "🏥", color: "red"),
    ExpenseCategory(largeClass: "医療", mediumClass: "薬", icon: "💊", color: "red"),
    ExpenseCategory(largeClass: "医療", mediumClass: "その他", icon: "🩺", color: "red"),
    
    // MARK: - Entertainment (娯楽)
    ExpenseCategory(largeClass: "娯楽", mediumClass: "映画", icon: "🎬", color: "purple"),
    ExpenseCategory(largeClass: "娯楽", mediumClass: "ゲーム", icon: "🎮", color: "purple"),
    ExpenseCategory(largeClass: "娯楽", mediumClass: "その他", icon: "🎨", color: "purple"),
    
    // MARK: - Shopping (買い物)
    ExpenseCategory(largeClass: "買い物", mediumClass: "衣類", icon: "👕", color: "pink"),
    ExpenseCategory(largeClass: "買い物", mediumClass: "家用品", icon: "🛋️", color: "pink"),
    ExpenseCategory(largeClass: "買い物", mediumClass: "その他", icon: "🛍️", color: "pink"),
    
    // MARK: - Other (その他)
    ExpenseCategory(largeClass: "その他", mediumClass: "その他", icon: "📦", color: "gray"),
]

// MARK: - Helper to get large categories
func getLargeCategories() -> [String] {
    Array(Set(defaultCategories.map { $0.largeClass })).sorted()
}

// MARK: - Helper to get medium categories for a large class
func getMediumCategories(for largeClass: String) -> [ExpenseCategory] {
    defaultCategories.filter { $0.largeClass == largeClass }.sorted { $0.mediumClass < $1.mediumClass }
}
