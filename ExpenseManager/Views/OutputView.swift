import SwiftUI
import Charts

struct OutputView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    @State private var selectedMonth: Date = {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now)
        return calendar.date(from: components) ?? now
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month Navigation
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
                if dailyExpenses.isEmpty {
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
                        VStack(spacing: 24) {
                            // Summary Card
                            summaryCard
                            
                            // Pie Chart - Tag Breakdown
                            if !tagBreakdown.isEmpty {
                                pieChartSection
                            }
                            
                            // Line Chart - Daily Trend
                            if !sortedDailyBreakdown.isEmpty {
                                lineChartSection
                            }
                            
                            // Fixed Expenses Summary
                            if !recurringExpenses.isEmpty {
                                fixedExpensesSummary
                            }
                            
                            // Daily Breakdown Details
                            if !sortedDailyBreakdown.isEmpty {
                                dailyBreakdownCard
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("統計")
        }
    }
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("日常支出")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(formatCurrency(totalDailyAmount))
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("固定支出")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(formatCurrency(dataManager.getTotalRecurringSpent()))
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("合計")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(formatCurrency(totalDailyAmount + dataManager.getTotalRecurringSpent()))
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
            }
            .padding(12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Pie Chart Section
    private var pieChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("タグ別支出内訳")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Pie Chart
            Chart(tagChartData) { item in
                SectorMark(
                    angle: .value("金額", item.amount),
                    innerRadius: .ratio(0.5)
                )
                .foregroundStyle(by: .value("タグ", item.tag))
                .opacity(0.8)
            }
            .frame(height: 250)
            
            // Legend with details
            VStack(alignment: .leading, spacing: 8) {
                ForEach(sortedTagBreakdown, id: \.key) { tag, amount in
                    let percentage = (amount / totalDailyAmount) * 100
                    
                    HStack {
                        Circle()
                            .fill(getTagColor(tag))
                            .frame(width: 12, height: 12)
                        
                        Text(tag.isEmpty ? "（タグなし）" : tag)
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 1) {
                            HStack(spacing: 2) {
                                Text("¥")
                                    .font(.caption2)
                                Text(formatCurrency(amount))
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            Text("\(Int(percentage))%")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .border(Color(.systemGray6), width: 1)
    }
    
    // MARK: - Line Chart Section (Trend)
    private var lineChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別支出推移")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Line Chart with X and Y axis
            Chart(dailyChartData) { item in
                LineMark(
                    x: .value("日付", item.dateLabel),
                    y: .value("金額", item.amount)
                )
                .foregroundStyle(Color.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                PointMark(
                    x: .value("日付", item.dateLabel),
                    y: .value("金額", item.amount)
                )
                .foregroundStyle(Color.blue)
                .symbolSize(100)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                        .font(.caption)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .chartYScale(domain: [0, (dailyChartData.map { $0.amount }.max() ?? 0) * 1.2])
            
            // Statistics
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("合計")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(formatCurrency(totalDailyAmount))
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                
                HStack {
                    Text("平均")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(formatCurrency(totalDailyAmount / Double(sortedDailyBreakdown.count)))
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                
                HStack {
                    Text("最高")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(formatCurrency(sortedDailyBreakdown.map { $0.amount }.max() ?? 0))
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(6)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .border(Color(.systemGray6), width: 1)
    }
    
    // MARK: - Fixed Expenses Summary
    private var fixedExpensesSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("固定支出進捗")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("月間予算")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(formatCurrency(dataManager.getTotalRecurringBudget()))
                            .font(.body)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("実績")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(formatCurrency(dataManager.getTotalRecurringSpent()))
                            .font(.body)
                            .fontWeight(.bold)
                    }
                }
            }
            .padding(12)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            
            // Progress bar
            let totalBudget = dataManager.getTotalRecurringBudget()
            let totalSpent = dataManager.getTotalRecurringSpent()
            let progress = min(totalSpent / totalBudget, 1.0)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("使用率")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(totalSpent > totalBudget ? Color.red : Color.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxWidth: CGFloat(progress) * 280)
                }
                .frame(height: 8)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .border(Color(.systemGray6), width: 1)
    }
    
    // MARK: - Daily Breakdown Details
    private var dailyBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別支出一覧")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(sortedDailyBreakdown, id: \.date) { date, amount in
                    HStack {
                        Text(date)
                            .font(.body)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Text("¥")
                                .font(.caption2)
                            Text(formatCurrency(amount))
                                .font(.body)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .border(Color(.systemGray6), width: 1)
    }
    
    // MARK: - Data Models for Charts
    
    struct TagChartData: Identifiable {
        let id = UUID()
        let tag: String
        let amount: Double
    }
    
    struct DailyChartData: Identifiable {
        let id = UUID()
        let dateLabel: String
        let amount: Double
    }
    
    // MARK: - Computed Properties
    
    private var dailyExpenses: [DailyExpense] {
        dataManager.getDailyExpensesForMonth(selectedMonth)
    }
    
    private var recurringExpenses: [RecurringExpense] {
        dataManager.recurringExpenses
    }
    
    private var totalDailyAmount: Double {
        dailyExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var tagBreakdown: [String: Double] {
        var totals: [String: Double] = [:]
        dailyExpenses.forEach { expense in
            let tag = expense.tag ?? ""
            totals[tag, default: 0] += expense.amount
        }
        return totals
    }
    
    private var sortedTagBreakdown: [(key: String, value: Double)] {
        tagBreakdown.sorted { $0.value > $1.value }
    }
    
    private var tagChartData: [TagChartData] {
        sortedTagBreakdown.map { tag, amount in
            TagChartData(tag: tag.isEmpty ? "（タグなし）" : tag, amount: amount)
        }
    }
    
    private var expensesByDay: [String: Double] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        var dailyTotals: [String: Double] = [:]
        dailyExpenses.forEach { expense in
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
    
    private var dailyChartData: [DailyChartData] {
        sortedDailyBreakdown.map { date, amount in
            DailyChartData(dateLabel: date, amount: amount)
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    private func getTagColor(_ tag: String) -> Color {
        let colors: [String: Color] = [
            "スーパー": Color(red: 0.2, green: 0.8, blue: 0.2),
            "コンビニ": Color(red: 0.0, green: 0.5, blue: 1.0),
            "レストラン": Color(red: 1.0, green: 0.3, blue: 0.3),
            "カフェ": Color(red: 0.6, green: 0.3, blue: 0.0),
            "居酒屋": Color(red: 0.6, green: 0.4, blue: 1.0),
            "交通": Color(red: 0.0, green: 0.8, blue: 1.0),
            "娯楽": Color(red: 1.0, green: 0.6, blue: 0.0),
            "買い物": Color(red: 1.0, green: 0.4, blue: 0.7),
            "その他": Color.gray,
            "（タグなし）": Color.gray,
        ]
        return colors[tag] ?? Color.blue
    }
}

#Preview {
    OutputView()
        .environmentObject(ExpenseDataManager())
}
