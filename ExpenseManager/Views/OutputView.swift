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
                            
                            // Line Chart - Daily Trend (Cumulative)
                            if !cumulativeDailyData.isEmpty {
                                lineChartSection
                            }
                            
                            // Daily Breakdown Details with colors
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
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("日数")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(uniqueDays)")
                        .font(.headline)
                        .fontWeight(.bold)
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
    
    // MARK: - Line Chart Section (Cumulative Trend)
    private var lineChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別支出推移（累計）")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Line Chart with cumulative data
            Chart(cumulativeDailyData) { item in
                LineMark(
                    x: .value("日付", item.day),
                    y: .value("金額", item.cumulativeAmount)
                )
                .foregroundStyle(Color.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                PointMark(
                    x: .value("日付", item.day),
                    y: .value("金額", item.cumulativeAmount)
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
            .chartYScale(domain: [0, (cumulativeDailyData.map { $0.cumulativeAmount }.max() ?? 0) * 1.2])
            
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
                        Text(formatCurrency(totalDailyAmount / Double(uniqueDays)))
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
                        Text(formatCurrency(dailyAmounts.map { $0.value }.max() ?? 0))
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
    
    // MARK: - Daily Breakdown Details with day coloring
    private var dailyBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別支出一覧")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(allDaysOfMonth, id: \.self) { dayInfo in
                    let amount = dailyAmounts[dayInfo.dateString] ?? 0
                    let dayColor = getDayBackgroundColor(dayInfo.dayOfWeek, isHoliday: dayInfo.isHoliday)
                    
                    if amount > 0 || amount == 0 {  // Show all days
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dayInfo.dateString)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(dayInfo.dayName)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            if amount > 0 {
                                HStack(spacing: 2) {
                                    Text("¥")
                                        .font(.caption2)
                                    Text(formatCurrency(amount))
                                        .font(.body)
                                        .fontWeight(.bold)
                                }
                            } else {
                                Text("-")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(10)
                        .background(dayColor)
                        .cornerRadius(8)
                    }
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
    
    struct CumulativeDailyData: Identifiable {
        let id = UUID()
        let day: Int
        let cumulativeAmount: Double
    }
    
    struct DayInfo: Hashable {
        let dateString: String  // "11/19"
        let dayName: String     // "火" (Tuesday)
        let dayOfWeek: Int      // 1=Sunday, 2=Monday, etc.
        let isHoliday: Bool
    }
    
    // MARK: - Computed Properties
    
    private var dailyExpenses: [DailyExpense] {
        dataManager.getDailyExpensesForMonth(selectedMonth)
    }
    
    private var totalDailyAmount: Double {
        dailyExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var uniqueDays: Int {
        Set(dailyExpenses.map { expense in
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: expense.date)
        }).count
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
    
    private var dailyAmounts: [String: Double] {
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
        dailyAmounts
            .sorted { dateA, dateB in
                guard let dateAObj = dateStringToDate(dateA.key),
                      let dateBObj = dateStringToDate(dateB.key) else {
                    return false
                }
                return dateAObj < dateBObj
            }
            .map { (date: $0.key, amount: $0.value) }
    }
    
    private var cumulativeDailyData: [CumulativeDailyData] {
        var cumulative: Double = 0
        var result: [CumulativeDailyData] = []
        
        for day in 1...getDaysInMonth(selectedMonth) {
            let dateString = String(format: "%02d/%02d", Calendar.current.component(.month, from: selectedMonth), day)
            if let amount = dailyAmounts[dateString] {
                cumulative += amount
            }
            result.append(CumulativeDailyData(day: day, cumulativeAmount: cumulative))
        }
        
        return result
    }
    
    private var allDaysOfMonth: [DayInfo] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        let daysInMonth = range.count
        let month = calendar.component(.month, from: selectedMonth)
        let year = calendar.component(.year, from: selectedMonth)
        
        var days: [DayInfo] = []
        
        for day in 1...daysInMonth {
            let components = DateComponents(year: year, month: month, day: day)
            guard let date = calendar.date(from: components) else { continue }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            let dateString = formatter.string(from: date)
            
            let dayOfWeek = calendar.component(.weekday, from: date)
            let dayNames = ["日", "月", "火", "水", "木", "金", "土"]
            let dayName = dayNames[dayOfWeek - 1]
            
            let isHoliday = isJapaneseHoliday(date)
            
            days.append(DayInfo(dateString: dateString, dayName: dayName, dayOfWeek: dayOfWeek, isHoliday: isHoliday))
        }
        
        return days
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
    
    private func getDaysInMonth(_ date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
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
    
    private func getDayBackgroundColor(_ dayOfWeek: Int, isHoliday: Bool) -> Color {
        if isHoliday {
            return Color(red: 1.0, green: 0.85, blue: 0.85)  // Light pink for holidays
        }
        
        switch dayOfWeek {
        case 1:  // Sunday
            return Color(red: 1.0, green: 0.92, blue: 0.76)  // Light orange
        case 7:  // Saturday
            return Color(red: 1.0, green: 1.0, blue: 0.85)   // Light yellow
        default:
            return Color(.systemGray6)  // Default gray for weekdays
        }
    }
    
    private func getTagColor(_ tag: String) -> Color {
        let tagObject = dataManager.tags.first { $0.name == tag }
        return tagObject?.getColor() ?? Color.gray
    }
    
    private func isJapaneseHoliday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        // Japanese holidays in 2025
        let holidays: [(Int, Int)] = [
            (1, 1),    // New Year's Day
            (1, 13),   // Coming of Age Day
            (2, 11),   // National Foundation Day
            (3, 21),   // Vernal Equinox Day (approx)
            (4, 29),   // Showa Day
            (5, 3),    // Constitution Day
            (5, 4),    // Greenery Day
            (5, 5),    // Children's Day
            (7, 21),   // Marine Day
            (8, 11),   // Mountain Day
            (9, 15),   // Respect for the Aged Day
            (9, 23),   // Autumnal Equinox Day (approx)
            (10, 13),  // Sports Day
            (11, 3),   // Culture Day
            (11, 23),  // Labor Thanksgiving Day
        ]
        
        for (hMonth, hDay) in holidays {
            if month == hMonth && day == hDay {
                return true
            }
        }
        
        // Also mark days after holidays as affected
        return false
    }
}

#Preview {
    OutputView()
        .environmentObject(ExpenseDataManager())
}
