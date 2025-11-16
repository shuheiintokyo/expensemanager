//
//  OutputView.swift
//  ExpenseManager
//
//  This view demonstrates:
//  1. @State for month selection
//  2. Computed properties for calculations
//  3. ForEach loops with data transformation
//  4. Conditional rendering based on data
//  5. Formatting numbers for display
//

import SwiftUI

struct OutputView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    // MARK: - State for Month Selection
    // User can navigate between months
    @State private var selectedMonth: Date = {
        // Initialize to current month
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
                    }
                    
                    Spacer()
                    
                    // MARK: - Month Display
                    // DateFormatter converts Date to readable string
                    Text(selectedMonth, style: .date)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // MARK: - Main Content
                if expenses.isEmpty {
                    VStack {
                        Text("No expenses for this month")
                            .foregroundColor(.gray)
                        Text("Start by adding an expense in the 'Add' tab")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // MARK: - Total Summary Card
                            summaryCard
                            
                            // MARK: - Category Breakdown
                            categoryBreakdownSection
                            
                            // MARK: - Expense List
                            expenseListSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Analytics")
        }
    }
    
    // MARK: - Computed Properties
    // These recalculate automatically when dataManager.expenses changes
    
    /// Get expenses for selected month
    private var expenses: [ExpenseItem] {
        dataManager.getExpensesForMonth(selectedMonth)
    }
    
    /// Calculate total spending for the month
    private var monthlyTotal: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    /// Group expenses by category
    private var expensesByCategory: [String: [ExpenseItem]] {
        Dictionary(grouping: expenses, by: { $0.category })
    }
    
    /// Get all unique categories that have expenses this month
    private var categoriesWithExpenses: [String] {
        Array(expensesByCategory.keys).sorted()
    }
    
    // MARK: - Summary Card UI Component
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Spent")
                .font(.caption)
                .foregroundColor(.gray)
            
            // MARK: - Number Formatting
            // Format as currency with 2 decimal places
            Text("¥\(String(format: "%.2f", monthlyTotal))")
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Text("Transactions")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(expenses.count)")
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Category Breakdown Section
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.headline)
            
            // MARK: - ForEach with Calculated Values
            // Loop through categories and calculate totals
            ForEach(categoriesWithExpenses, id: \.self) { category in
                let categoryExpenses = expensesByCategory[category] ?? []
                let categoryTotal = categoryExpenses.reduce(0) { $0 + $1.amount }
                let percentage = (categoryTotal / monthlyTotal) * 100
                
                VStack(spacing: 8) {
                    HStack {
                        // Get category icon from dataManager
                        if let cat = dataManager.categories.first(where: { $0.name == category }) {
                            Text(cat.icon)
                                .font(.title3)
                        }
                        
                        Text(category)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("¥\(String(format: "%.2f", categoryTotal))")
                            .fontWeight(.semibold)
                    }
                    
                    // MARK: - Progress Bar
                    // Visual representation of category spending
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                            
                            // Filled bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * (percentage / 100))
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("\(Int(percentage))%")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(categoryExpenses.count) transactions")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Expense List Section
    private var expenseListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transactions")
                .font(.headline)
            
            // MARK: - Sort and Display
            // Sort by date (newest first)
            ForEach(expenses.sorted { $0.date > $1.date }) { expense in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // Category icon and name
                        if let category = dataManager.categories.first(where: { $0.name == expense.category }) {
                            HStack {
                                Text(category.icon)
                                Text(expense.category)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        // Notes if present
                        if !expense.notes.isEmpty {
                            Text(expense.notes)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Date
                        Text(expense.date, style: .date)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Amount
                    Text("¥\(String(format: "%.2f", expense.amount))")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Month Navigation Methods
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
}

#Preview {
    OutputView()
        .environmentObject(ExpenseDataManager())
}
