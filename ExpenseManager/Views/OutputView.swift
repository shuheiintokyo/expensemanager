//
//  OutputView.swift (iPad - Same GeometryReader Pattern as InputView)
//  ExpenseManager
//
//  Uses same GeometryReader approach as InputView for consistent full-width layout
//

import SwiftUI

struct OutputView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var selectedMonth: Date = {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now)
        return calendar.date(from: components) ?? now
    }()
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month Navigation Header
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
                
                // Content
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
                    // iPad: Same GeometryReader pattern as InputView
                    GeometryReader { geometry in
                        let columnWidth = geometry.size.width / 2
                        
                        HStack(spacing: 0) {
                            // LEFT COLUMN - 50% - Chart
                            VStack(alignment: .leading, spacing: 16) {
                                Text("カテゴリー別支出")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                // Summary Card
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("合計")
                                            .foregroundColor(.gray)
                                            .font(.body)
                                        Spacer()
                                        HStack(spacing: 2) {
                                            Text("¥")
                                                .font(.caption)
                                            Text(formatCurrency(totalAmount))
                                                .fontWeight(.bold)
                                                .font(.title2)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                
                                // Pie Chart
                                HStack(spacing: 20) {
                                    ZStack {
                                        ForEach(Array(sortedLargeCategories.enumerated()), id: \.element.category) { index, item in
                                            let angle = calculateAngle(for: index, categories: sortedLargeCategories, total: totalAmount)
                                            
                                            PieSlice(
                                                startAngle: angle.start,
                                                endAngle: angle.end,
                                                color: getCategoryColor(item.category)
                                            )
                                        }
                                    }
                                    .frame(width: 160, height: 160)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(sortedLargeCategories, id: \.category) { item in
                                            let percentage = (item.amount / totalAmount) * 100
                                            
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(getCategoryColor(item.category))
                                                    .frame(width: 10, height: 10)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(item.category)
                                                        .font(.caption)
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
                                }
                                .padding(16)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                
                                Spacer()
                            }
                            .frame(width: columnWidth, height: geometry.size.height)
                            .padding(20)
                            .background(Color(.systemBackground))
                            
                            // DIVIDER
                            Divider()
                                .frame(width: 1)
                            
                            // RIGHT COLUMN - 50% - Daily List
                            VStack(alignment: .leading, spacing: 16) {
                                Text("日別支出")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                ScrollView {
                                    VStack(spacing: 12) {
                                        ForEach(sortedDailyBreakdown, id: \.date) { date, amount in
                                            HStack {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text(date)
                                                        .font(.body)
                                                        .fontWeight(.semibold)
                                                    
                                                    let dayExpenses = expenses.filter { dateFormatter($0.date) == date }
                                                    let categoriesForDay = Dictionary(grouping: dayExpenses, by: { $0.largeCategory })
                                                    
                                                    HStack(spacing: 8) {
                                                        ForEach(categoriesForDay.keys.sorted(), id: \.self) { category in
                                                            Text(category)
                                                                .font(.caption2)
                                                                .padding(5)
                                                                .background(getCategoryColor(category).opacity(0.15))
                                                                .cornerRadius(4)
                                                        }
                                                    }
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .trailing, spacing: 4) {
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
                                            .padding(12)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .frame(width: columnWidth, height: geometry.size.height)
                            .padding(20)
                            .background(Color(.systemBackground))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    // iPhone: Vertical scroll layout
                    ScrollView {
                        VStack(spacing: 16) {
                            iPhoneChartSection
                            iPhoneDailySection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("統計")
        }
    }
    
    // MARK: - iPhone Sections
    private var iPhoneChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリー別支出")
                .font(.headline)
                .fontWeight(.semibold)
            
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
            
            HStack(spacing: 16) {
                ZStack {
                    ForEach(Array(sortedLargeCategories.enumerated()), id: \.element.category) { index, item in
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
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.category)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("\(Int(percentage))%")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(formatCurrency(item.amount))
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
    }
    
    private var iPhoneDailySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別支出")
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
                                        .font(.caption2)
                                        .padding(4)
                                        .background(getCategoryColor(category).opacity(0.15))
                                        .cornerRadius(4)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
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
            }
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
