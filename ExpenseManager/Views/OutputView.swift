//
//  OutputView.swift (iPad Responsive Version)
//  ExpenseManager
//
//  Features:
//  1. Responsive layout for iPad and iPhone
//  2. Side-by-side layout for iPad
//  3. Adaptive chart sizing
//  4. Full dark mode support
//

import SwiftUI

struct OutputView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // MARK: - State for Month Selection
    @State private var selectedMonth: Date = {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now)
        return calendar.date(from: components) ?? now
    }()
    
    // MARK: - Responsive Layout Detection
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
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
                } else if isIPad {
                    // MARK: - iPad: Side-by-side layout
                    HStack(spacing: 16) {
                        // Left: Chart
                        VStack(alignment: .leading, spacing: 16) {
                            Text("カテゴリー別支出")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            pieChartContent
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right: Daily breakdown
                        VStack(alignment: .leading, spacing: 16) {
                            Text("日別支出")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(sortedDailyBreakdown, id: \.date) { date, amount in
                                        dailyBreakdownRow(date: date, amount: amount)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                } else {
                    // MARK: - iPhone: Vertical layout
                    ScrollView {
                        VStack(spacing: 16) {
                            pieChartSection
                            dailyBreakdownSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("統計")
        }
    }
    
    // MARK: - Pie Chart Content (for iPad)
    private var pieChartContent: some View {
        VStack(spacing: 12) {
            // Summary Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("合計")
                        .foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption)
                        Text(formatCurrency(totalAmount))
                            .fontWeight(.bold)
                            .font(.title3)
                    }
                }
            }
            .padding(12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Pie Chart
            HStack(spacing: 12) {
                // Chart Circle
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
                .frame(maxWidth: 120, maxHeight: 120)
                
                // Legend (Compact for iPad)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(sortedLargeCategories, id: \.category) { item in
                        let percentage = (item.amount / totalAmount) * 100
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(getCategoryColor(item.category))
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.category)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                Text("\(Int(percentage))%")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(formatCurrency(item.amount))
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Pie Chart Section (iPhone)
    private var pieChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリー別支出 (By Category)")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Summary Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("合計")
                        .foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption)
                        Text(formatCurrency(totalAmount))
                            .fontWeight(.bold)
                            .font(.title3)
                    }
                }
            }
            .padding(12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            // Pie Chart Visual
            HStack(spacing: 20) {
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
                            
                            HStack(spacing: 1) {
                                Text("¥")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                Text(formatCurrency(item.amount))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Daily Breakdown Row (iPad)
    private func dailyBreakdownRow(date: String, amount: Double) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(date)
                    .font(.body)
                    .fontWeight(.semibold)
                
                let dayExpenses = expenses.filter { dateFormatter($0.date) == date }
                let categoriesForDay = Dictionary(grouping: dayExpenses, by: { $0.largeCategory })
                
                HStack(spacing: 4) {
                    ForEach(categoriesForDay.keys.sorted(), id: \.self) { category in
                        Text(category)
                            .font(.caption2)
                            .padding(3)
                            .background(getCategoryColor(category).opacity(0.2))
                            .cornerRadius(3)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 2) {
                    Text("¥")
                        .font(.caption2)
                        .fontWeight(.bold)
                    Text(formatCurrency(amount))
                        .font(.body)
                        .fontWeight(.bold)
                }
                
                let percentage = (amount / totalAmount) * 100
                Text("\(Int(percentage))%")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Daily Breakdown Section (iPhone)
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
                            HStack(spacing: 2) {
                                Text("¥")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Text(formatCurrency(amount))
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
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
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category {
        case "住宅": return Color(red: 1.0, green: 0.6, blue: 0.0)
        case "光熱費": return Color(red: 1.0, green: 0.85, blue: 0.0)
        case "食費": return Color(red: 0.2, green: 0.8, blue: 0.2)
        case "外出": return Color(red: 1.0, green: 0.3, blue: 0.3)
        case "交通費": return Color(red: 0.0, green: 0.5, blue: 1.0)
        case "美容": return Color(red: 1.0, green: 0.4, blue: 0.7)
        case "教育": return Color(red: 0.6, green: 0.4, blue: 1.0)
        case "医療": return Color(red: 1.0, green: 0.3, blue: 0.3)
        case "娯楽": return Color(red: 0.6, green: 0.4, blue: 1.0)
        case "買い物": return Color(red: 1.0, green: 0.4, blue: 0.7)
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

extension PieSlice: View {
    var body: some View {
        self
            .fill(color)
    }
}

#Preview {
    OutputView()
        .environmentObject(ExpenseDataManager())
}
