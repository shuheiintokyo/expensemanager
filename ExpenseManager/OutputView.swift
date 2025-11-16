//
//  OutputView.swift
//  ExpenseManager
//
//  This view demonstrates:
//  1. Pie chart visualization by large category
//  2. Daily expense summary
//  3. Hierarchical category breakdown
//  4. Month navigation
//

import SwiftUI

struct OutputView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    // MARK: - State for Month Selection
    @State private var selectedMonth: Date = {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now)
        return calendar.date(from: components) ?? now
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Month Navigation Header
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Text(monthString(selectedMonth))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // MARK: - Main Content
                if expenses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("支出データがありません")
                            .font(.headline)
                        Text("入力タブで支出を追加してください")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // MARK: - Pie Chart by Large Category
                            pieChartSection
                            
                            // MARK: - Daily Breakdown
                            dailyBreakdownSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("統計")
        }
    }
    
    // MARK: - Computed Properties
    
    private var expenses: [ExpenseItem] {
        dataManager.getExpensesForMonth(selectedMonth)
    }
    
    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    private var expensesByLargeCategory: [String: Double] {
        var totals: [String: Double] = [:]
        expenses.forEach { expense in
            totals[expense.largeCategory, default: 0] += expense.amount
        }
        return totals
    }
    
    private var sortedLargeCategories: [(category: String, amount: Double)] {
        expensesByLargeCategory
            .sorted { $0.value > $1.value }
            .map { (category: $0.key, amount: $0.value) }
    }
    
    private var expensesByDay: [String: Double] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        
        var dailyTotals: [String: Double] = [:]
        expenses.forEach { expense in
            let dateKey = formatter.string(from: expense.date)
            dailyTotals[dateKey, default: 0] += expense.amount
        }
        return dailyTotals
    }
    
    private var sortedDailyBreakdown: [(date: String, amount: Double)] {
        expensesByDay
            .sorted { dateA, dateB in
                guard let dateAObj = dateStringToDate(dateA.key),
                      let dateBObj = dateStringToDate(dateB.key) else {
                    return false
                }
                return dateAObj < dateBObj
            }
            .map { (date: $0.key, amount: $0.value) }
    }
    
    // MARK: - Pie Chart Section
    private var pieChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリー別支出 (By Category)")
                .font(.headline)
                .fontWeight(.semibold)
            
            // MARK: - Summary Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("合計")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("¥\(String(format: "%.0f", totalAmount))")
                        .fontWeight(.bold)
                        .font(.title3)
                }
            }
            .padding(12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            // MARK: - Pie Chart Visual
            HStack(spacing: 20) {
                // Pie Chart Circle
                ZStack {
                    ForEach(Array(sortedLargeCategories.enumerated()), id: \.element.category) { index, item in
                        let percentage = item.amount / totalAmount
                        let angle = calculateAngle(for: index, categories: sortedLargeCategories, total: totalAmount)
                        
                        PieSlice(
                            startAngle: angle.start,
                            endAngle: angle.end,
                            color: getCategoryColor(item.category)
                        )
                    }
                }
                .frame(width: 120, height: 120)
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(sortedLargeCategories, id: \.category) { item in
                        let percentage = (item.amount / totalAmount) * 100
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(getCategoryColor(item.category))
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.category)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("\(Int(percentage))%")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("¥\(String(format: "%.0f", item.amount))")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Daily Breakdown Section
    private var dailyBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別支出 (Daily Breakdown)")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(sortedDailyBreakdown, id: \.date) { date, amount in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(date)
                                .font(.body)
                                .fontWeight(.semibold)
                            
                            // Show categories for this day
                            let dayExpenses = expenses.filter { dateFormatter($0.date) == date }
                            let categoriesForDay = Dictionary(grouping: dayExpenses, by: { $0.largeCategory })
                            
                            HStack(spacing: 8) {
                                ForEach(categoriesForDay.keys.sorted(), id: \.self) { category in
                                    Text(category)
                                        .font(.caption)
                                        .padding(4)
                                        .background(getCategoryColor(category).opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("¥\(String(format: "%.0f", amount))")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            let percentage = (amount / totalAmount) * 100
                            Text("\(Int(percentage))%")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Helper Functions
    
    private func monthString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }
    
    private func nextMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }
    
    private func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func dateStringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.date(from: dateString)
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category {
        case "住宅": return .orange
        case "光熱費": return .yellow
        case "食費": return .green
        case "外出": return .red
        case "交通費": return .blue
        case "美容": return .pink
        case "教育": return .purple
        case "医療": return .red
        case "娯楽": return .purple
        case "買い物": return .pink
        default: return .gray
        }
    }
    
    private func calculateAngle(
        for index: Int,
        categories: [(category: String, amount: Double)],
        total: Double
    ) -> (start: Angle, end: Angle) {
        let startAngle = categories.prefix(index).reduce(0.0) { sum, item in
            sum + (item.amount / total) * 360
        }
        let endAngle = startAngle + (categories[index].amount / total) * 360
        
        return (
            start: .degrees(startAngle - 90),
            end: .degrees(endAngle - 90)
        )
    }
}

// MARK: - Pie Slice Shape
struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    OutputView()
        .environmentObject(ExpenseDataManager())
}
