import SwiftUI

struct RecurringExpenseInputView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    @State private var editingIndex: Int? = nil
    @State private var editingAmount: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Total Info
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
                    
                    VStack(alignment: .center, spacing: 4) {
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
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("残予算")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack(spacing: 2) {
                            Text("¥")
                                .font(.caption2)
                            let remaining = dataManager.getTotalRecurringBudget() - dataManager.getTotalRecurringSpent()
                            Text(formatCurrency(remaining))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(remaining < 0 ? .red : .green)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Progress bar for total
                let totalBudget = dataManager.getTotalRecurringBudget()
                let totalSpent = dataManager.getTotalRecurringSpent()
                let progress = min(totalSpent / totalBudget, 1.0)
                
                VStack {
                    HStack {
                        Text("全体進捗")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(.systemGray6))
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(totalSpent > totalBudget ? Color.red : Color.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(maxWidth: CGFloat(progress) * 350)
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                Divider()
                
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
                TextField("金額を入力", text: $editingAmount)
                    .keyboardType(.numberPad)
                
                Button("キャンセル", role: .cancel) {
                    editingIndex = nil
                    editingAmount = ""
                }
                
                Button("保存") {
                    saveEditedAmount()
                }
            } message: {
                Text("このカテゴリの実績額を入力してください")
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func expenseRowContent(for expense: RecurringExpense, at index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            HStack {
                Text(expense.name)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if expense.isOverBudget {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.body)
                        .foregroundColor(.red)
                }
            }
            
            // Budget and Actual (side by side)
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("月間予算")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(expense.formattedBudget)
                            .font(.body)
                            .fontWeight(.bold)
                    }
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("実績")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Text("¥")
                            .font(.caption2)
                        Text(expense.formattedActualSpent)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(expense.isOverBudget ? .red : .blue)
                    }
                }
                
                Spacer()
                
                // Edit Button
                Button(action: {
                    editingIndex = index
                    editingAmount = String(Int(expense.actualSpent))
                    showAlert = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.body)
                        .foregroundColor(.blue)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                let progress = min(expense.actualSpent / expense.budget, 1.0)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray6))
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(expense.isOverBudget ? Color.red : Color.blue)
                        .frame(width: geometry.size.width * CGFloat(progress))
                }
                .frame(height: 6)
            }
            .frame(height: 6)
            
            // Status message
            HStack {
                if expense.isOverBudget {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("予算超過: ¥\(Int(expense.actualSpent - expense.budget))")
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                    let remaining = Int(expense.budget - expense.actualSpent)
                    Text("残り ¥\(remaining)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
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
            editingIndex = nil
            editingAmount = ""
            return
        }
        
        let cleanAmount = editingAmount.replacingOccurrences(of: ",", with: "")
        guard let amountDouble = Double(cleanAmount) else {
            showAlert = false
            editingIndex = nil
            editingAmount = ""
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
