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
                    NavigationLink(destination: EditTagView(tagIndex: index)
                        .environmentObject(dataManager)
                    ) {
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundColor(tag.getColor())
                                .font(.body)
                            
                            Text(tag.name)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Circle()
                                .fill(tag.getColor())
                                .frame(width: 16, height: 16)
                        }
                        .padding(.vertical, 6)
                    }
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

// MARK: - Edit Tag View (with color picker)

struct EditTagView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State var tagIndex: Int
    @State private var tagName: String = ""
    @State private var selectedColor: Color = Color.blue
    
    var body: some View {
        Form {
            Section(header: Text("タグ情報").font(.headline)) {
                TextField("タグ名", text: $tagName)
                
                HStack {
                    Text("色")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    NavigationLink(destination: ColorPickerView(selectedColor: $selectedColor)) {
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    }
                }
            }
            
            Section {
                Button(action: saveTag) {
                    HStack {
                        Spacer()
                        Text("保存")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("タグを編集")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if tagIndex >= 0 && tagIndex < dataManager.tags.count {
                let tag = dataManager.tags[tagIndex]
                tagName = tag.name
                selectedColor = tag.getColor()
            }
        }
    }
    
    private func saveTag() {
        guard tagIndex >= 0 && tagIndex < dataManager.tags.count else { return }
        
        var tag = dataManager.tags[tagIndex]
        tag.name = tagName
        tag.colorHex = selectedColor.toHex()
        
        dataManager.tags[tagIndex] = tag
        dataManager.saveTags()
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Color Picker View

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Environment(\.presentationMode) var presentationMode
    
    let colors: [Color] = [
        Color(red: 0.22, green: 0.80, blue: 0.22),   // Green
        Color(red: 0.24, green: 0.52, blue: 1.0),    // Blue
        Color(red: 0.94, green: 0.27, blue: 0.27),   // Red
        Color(red: 0.63, green: 0.39, blue: 0.0),    // Brown
        Color(red: 0.65, green: 0.33, blue: 0.97),   // Purple
        Color(red: 0.03, green: 0.74, blue: 0.83),   // Cyan
        Color(red: 0.98, green: 0.62, blue: 0.1),    // Orange
        Color(red: 0.92, green: 0.29, blue: 0.44),   // Pink
        Color(red: 0.42, green: 0.44, blue: 0.50),   // Gray
    ]
    
    let colorNames = ["緑", "青", "赤", "茶", "紫", "シアン", "オレンジ", "ピンク", "グレー"]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("色を選択")
                .font(.headline)
                .fontWeight(.semibold)
                .padding()
            
            VStack(spacing: 16) {
                ForEach(0..<colors.count, id: \.self) { index in
                    HStack(spacing: 16) {
                        Button(action: {
                            selectedColor = colors[index]
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Circle()
                                .fill(colors[index])
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedColor.toHex() == colors[index].toHex() ? Color.black : Color.gray,
                                            lineWidth: selectedColor.toHex() == colors[index].toHex() ? 3 : 1
                                        )
                                )
                        }
                        
                        Text(colorNames[index])
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
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
            
            Spacer()
        }
        .padding(16)
        .navigationTitle("編集: \(expense.name)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            categoryNameInput = expense.name
            budgetInput = String(Int(expense.budget))
        }
    }
}

// MARK: - Add Tag View

struct AddTagView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @Binding var isPresented: Bool
    
    @State private var tagName: String = ""
    @State private var selectedColor: Color = Color.blue
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("新しいタグ").font(.headline)) {
                    TextField("タグ名を入力", text: $tagName)
                    
                    HStack {
                        Text("色")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        NavigationLink(destination: ColorPickerView(selectedColor: $selectedColor)) {
                            Circle()
                                .fill(selectedColor)
                                .frame(width: 30, height: 30)
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        }
                    }
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
        
        let newTag = ExpenseTag(name: tagName, colorHex: selectedColor.toHex())
        dataManager.addTag(newTag)
        isPresented = false
    }
}

#Preview {
    SettingsView()
        .environmentObject(ExpenseDataManager())
}
