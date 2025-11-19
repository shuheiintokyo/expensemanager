import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    @State private var showAddTagSheet: Bool = false
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selection
                Picker("", selection: $selectedTab) {
                    Text("タグ").tag(0)
                    Text("固定支出").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(16)
                
                if selectedTab == 0 {
                    tagManagementView
                } else {
                    recurringExpenseManagementView
                }
            }
            .navigationTitle("設定")
        }
    }
    
    // MARK: - Tag Management View
    
    private var tagManagementView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(Array(dataManager.tags.enumerated()), id: \.element.id) { index, tag in
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.blue)
                            .font(.body)
                        
                        Text(tag.name)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        dataManager.deleteTag(at: index)
                    }
                }
            }
            
            // Add Button
            Button(action: { showAddTagSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("タグを追加")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .padding(16)
        }
        .sheet(isPresented: $showAddTagSheet) {
            AddTagView(isPresented: $showAddTagSheet)
                .environmentObject(dataManager)
        }
    }
    
    // MARK: - Recurring Expense Management View
    
    private var recurringExpenseManagementView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(Array(dataManager.recurringExpenses.enumerated()), id: \.element.id) { index, expense in
                    NavigationLink(destination: EditRecurringExpenseView(expense: .constant(expense), index: index)
                        .environmentObject(dataManager)
                    ) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(expense.name)
                                    .fontWeight(.semibold)
                                
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("予算")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        HStack(spacing: 2) {
                                            Text("¥")
                                                .font(.caption2)
                                            Text(expense.formattedBudget)
                                                .font(.body)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("実績")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        HStack(spacing: 2) {
                                            Text("¥")
                                                .font(.caption2)
                                            Text(expense.formattedActualSpent)
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(expense.isOverBudget ? .red : .blue)
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        dataManager.deleteRecurringExpense(at: index)
                    }
                }
            }
        }
    }
}

// MARK: - Edit Recurring Expense View

struct EditRecurringExpenseView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @Binding var expense: RecurringExpense
    @State var index: Int
    @Environment(\.presentationMode) var presentationMode
    
    @State private var budgetInput: String = ""
    @State private var categoryNameInput: String = ""
    @State private var isEditingBudget: Bool = false
    @State private var isEditingName: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Category Name
            VStack(alignment: .leading, spacing: 10) {
                Text("カテゴリー名")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                if isEditingName {
                    HStack {
                        TextField("カテゴリー名", text: $categoryNameInput)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("完了") {
                            if !categoryNameInput.isEmpty {
                                expense.name = categoryNameInput
                                dataManager.updateRecurringExpense(expense, at: index)
                                isEditingName = false
                            }
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                } else {
                    HStack {
                        Text(expense.name)
                            .font(.body)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: {
                            categoryNameInput = expense.name
                            isEditingName = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Budget
            VStack(alignment: .leading, spacing: 10) {
                Text("月間予算")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                if isEditingBudget {
                    HStack {
                        Text("¥")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        TextField("予算額", text: $budgetInput)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                        
                        Button("完了") {
                            if let budget = Double(budgetInput) {
                                expense.budget = budget
                                dataManager.updateRecurringExpense(expense, at: index)
                                isEditingBudget = false
                            }
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                } else {
                    HStack {
                        HStack(spacing: 2) {
                            Text("¥")
                                .font(.caption2)
                            Text(expense.formattedBudget)
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            budgetInput = String(Int(expense.budget))
                            isEditingBudget = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Current Spent
            VStack(alignment: .leading, spacing: 10) {
                Text("今月の実績")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                HStack(spacing: 2) {
                    Text("¥")
                        .font(.caption2)
                    Text(expense.formattedActualSpent)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(expense.isOverBudget ? .red : .blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
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
            
            // Last Month Info
            VStack(alignment: .leading, spacing: 10) {
                Text("先月の実績")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                HStack(spacing: 2) {
                    Text("¥")
                        .font(.caption2)
                    Text(expense.formattedLastMonthSpent)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(16)
        .navigationTitle("編集: \(expense.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Add Tag View

struct AddTagView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @Binding var isPresented: Bool
    
    @State private var tagName: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("新しいタグ").font(.headline)) {
                    TextField("タグ名を入力", text: $tagName)
                }
                
                Section {
                    Button(action: addTag) {
                        HStack {
                            Spacer()
                            Text("追加")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("タグを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { isPresented = false }
                }
            }
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func addTag() {
        guard !tagName.isEmpty else {
            errorMessage = "タグ名を入力してください"
            showError = true
            return
        }
        
        guard !dataManager.tags.contains(where: { $0.name.lowercased() == tagName.lowercased() }) else {
            errorMessage = "このタグは既に存在します"
            showError = true
            return
        }
        
        let newTag = ExpenseTag(name: tagName)
        dataManager.addTag(newTag)
        isPresented = false
    }
}

#Preview {
    SettingsView()
        .environmentObject(ExpenseDataManager())
}
