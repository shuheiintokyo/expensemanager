import SwiftUI

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
                        VStack(spacing: 20) {
                            // Tag Pie Chart
                            if !tagBreakdown.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("タグ別支出")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    tagChartSection
                                }
                                .padding(16)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                            }
                            
                            // Cumulative Daily Expense Chart
                            if !sortedDailyBreakdown.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("日別累積支出")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    cumulativeChartSection
                                }
                                .padding(16)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                            }
                            
                            // Daily Breakdown
                            if !sortedDailyBreakdown.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("日別支出詳細")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    dailyBreakdownCard
                                }
                                .padding(16)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("統計")
        }
    }
    
    // MARK: - Chart Views
    
    private var tagChartSection: some View {
        VStack(spacing: 12) {
            // Total
            HStack {
                Text("合計")
                    .foregroundColor(.gray)
                    .font(.caption)
                Spacer()
                HStack(spacing: 2) {
                    Text("¥")
                        .font(.caption2)
                    Text(formatCurrency(totalDailyAmount))
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            // Pie Chart Visual (Simple text-based breakdown)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(tagBreakdown.sorted(by: { $0.value > $1.value }), id: \.key) { tag, amount in
                    let percentage = (amount / totalDailyAmount) * 100
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(tag == "" ? "（タグなし）" : tag)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(Int(percentage))%")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(getTagColor(tag))
                                .frame(maxWidth: geometry.size.width * CGFloat(percentage / 100))
                        }
                        .frame(height: 8)
                        
                        HStack {
                            Spacer()
                            HStack(spacing: 2) {
                                Text("¥")
                                    .font(.caption2)
                                Text(formatCurrency(amount))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var cumulativeChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cumulative Chart (simplified bar representation)
            let maxAmount = (sortedDailyBreakdown.map { $0.amount }.max() ?? 0) * 1.1
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(sortedDailyBreakdown, id: \.date) { dateStr, amount in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(dateStr)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            HStack(spacing: 2) {
                                Text("¥")
                                    .font(.caption2)
                                Text(formatCurrency(amount))
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.blue)
                                .frame(maxWidth: geometry.size.width * CGFloat(amount / maxAmount))
                        }
                        .frame(height: 20)
                    }
                }
            }
            
            // Summary
            VStack(alignment: .leading, spacing: 4) {
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
            }
            .padding(.top, 8)
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(8)
        }
    }
    
    private var dailyBreakdownCard: some View {
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
    
    // MARK: - Computed Properties
    
    private var dailyExpenses: [DailyExpense] {
        dataManager.getDailyExpensesForMonth(selectedMonth)
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
            "スーパー": Color.green,
            "コンビニ": Color.blue,
            "レストラン": Color.red,
            "カフェ": Color.brown,
            "居酒屋": Color.purple,
            "交通": Color.cyan,
            "娯楽": Color.orange,
            "買い物": Color.pink,
            "その他": Color.gray,
        ]
        return colors[tag] ?? Color.blue
    }
}

#Preview {
    OutputView()
        .environmentObject(ExpenseDataManager())
}
