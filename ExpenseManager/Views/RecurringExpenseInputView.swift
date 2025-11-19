import SwiftUI

struct RecurringExpenseInputView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    @State private var editingIndex: Int? = nil
    @State private var editingAmount: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Total Budget Info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("月間予算")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack(spacing: 2) {
                            Text("¥")
                                .font(.caption2)
                            Text(formatCurrency(dataManager.getTotalRecurringBudget()))
                                .font(.headline)
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
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Recurring Expenses List
                List {
                    ForEach(Array(dataManager.recurringExpenses.enumerated()), id: \.element.id) { index, expense in
                        expenseRowContent(for: expense, at: index)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("固定支出")
            .alert("金額を入力", isPresented: $showAlert) {
                TextField("金額", text: $editingAmount)
                    .keyboardType(.numberPad)
                
                Button("キャンセル", role: .cancel) {
                    editingIndex = nil
                }
                
                Button("保存") {
                    saveEditedAmount()
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func expenseRowContent(for expense: RecurringExpense, at index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(expense.name)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(expense.formattedActualSpent)
                            .font(.body)
                            .fontWeight(.bold)
                    }
                    
                    Text("予算: \(expense.formattedBudget)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                let progress = min(expense.actualSpent / expense.budget, 1.0)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(expense.isOverBudget ? Color.red : Color.blue)
                        .frame(width: geometry.size.width * CGFloat(progress))
                }
                .frame(height: 6)
            }
            .frame(height: 6)
            
            // Last Month Info
            HStack {
                Text("先月")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                HStack(spacing: 2) {
                    Text("¥")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(expense.formattedLastMonthSpent)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
            }
            
            if expense.isOverBudget {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("予算超過: ¥\(Int(expense.actualSpent - expense.budget))")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            editingIndex = index
            editingAmount = String(Int(expense.actualSpent))
            showAlert = true
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    private func saveEditedAmount() {
        guard let index = editingIndex else { return }
        guard !editingAmount.isEmpty else {
            showAlert = false
            return
        }
        
        let cleanAmount = editingAmount.replacingOccurrences(of: ",", with: "")
        guard let amountDouble = Double(cleanAmount) else {
            showAlert = false
            return
        }
        
        var expense = dataManager.recurringExpenses[index]
        expense.actualSpent = amountDouble
        dataManager.updateRecurringExpense(expense, at: index)
        
        editingIndex = nil
        editingAmount = ""
        showAlert = false
    }
}

#Preview {
    RecurringExpenseInputView()
        .environmentObject(ExpenseDataManager())
}
