//
//  InputView.swift
//  ExpenseManager
//
//  This view demonstrates:
//  1. @State for form input management
//  2. @Binding to connect UI controls to state
//  3. Date selection (moved to first position)
//  4. Picker for hierarchical category selection with names
//  5. TextField for amount with thousand separators and ¥ symbol
//  6. TextField for notes with memo suggestions
//

import SwiftUI

struct InputView: View {
    // MARK: - Environment Object
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    // MARK: - Form State Variables
    @State private var amount: String = ""
    @State private var selectedLargeCategory: String = ""
    @State private var selectedMediumCategory: String = ""
    @State private var selectedDate: Date = Date()
    @State private var notes: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSuccess: Bool = false  // NEW: Track if success or error
    
    // MARK: - Focus Management (NEW: For auto-advancing)
    enum Field {
        case largeCategory
        case mediumCategory
        case amount
    }
    @FocusState private var focusedField: Field?
    
    // MARK: - Computed Properties
    private var availableLargeCategories: [String] {
        Array(Set(dataManager.categories.map { $0.largeClass })).sorted()
    }
    
    private var availableMediumCategories: [ExpenseCategory] {
        guard !selectedLargeCategory.isEmpty else { return [] }
        return dataManager.categories
            .filter { $0.largeClass == selectedLargeCategory }
            .sorted { $0.mediumClass < $1.mediumClass }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // MARK: - Date Section (FIRST)
                    Section(header: Text("日付").font(.headline)) {
                        DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                    }
                    
                    // MARK: - Large Category Section
                    Section(header: Text("大分類").font(.headline)) {
                        Picker("大分類を選択", selection: $selectedLargeCategory) {
                            Text("選択してください...").tag("")
                            ForEach(availableLargeCategories, id: \.self) { largeClass in
                                Text(largeClass).tag(largeClass)
                            }
                        }
                        .focused($focusedField, equals: .largeCategory)
                        .onChange(of: selectedLargeCategory) { _ in
                            selectedMediumCategory = ""
                            // NEW: Auto-focus to medium category when large category selected
                            if !selectedLargeCategory.isEmpty {
                                focusedField = .mediumCategory
                            }
                        }
                    }
                    
                    // MARK: - Medium Category Section
                    if !selectedLargeCategory.isEmpty {
                        Section(header: Text("中分類").font(.headline)) {
                            Picker("中分類を選択", selection: $selectedMediumCategory) {
                                Text("選択してください...").tag("")
                                ForEach(availableMediumCategories, id: \.id) { category in
                                    // Format: "icon name" (e.g., "🍕 レストラン")
                                    Text("\(category.icon) \(category.mediumClass)")
                                        .tag(category.mediumClass)
                                }
                            }
                            .focused($focusedField, equals: .mediumCategory)
                            .onChange(of: selectedMediumCategory) { _ in
                                // NEW: Auto-focus to amount when medium category selected
                                if !selectedMediumCategory.isEmpty {
                                    focusedField = .amount
                                }
                            }
                        }
                    }
                    
                    // MARK: - Amount Section (with ¥ symbol and thousand separators)
                    Section(header: Text("金額").font(.headline)) {
                        HStack(spacing: 8) {
                            Text("¥")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            TextField("0", text: $amount)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .amount)
                                .onChange(of: amount) { newValue in
                                    // Remove non-numeric characters and format
                                    let filtered = newValue.filter { $0.isNumber }
                                    if !filtered.isEmpty {
                                        if let number = Double(filtered) {
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .decimal
                                            formatter.groupingSeparator = ","
                                            formatter.maximumFractionDigits = 0
                                            amount = formatter.string(from: NSNumber(value: number)) ?? filtered
                                        }
                                    } else {
                                        amount = ""
                                    }
                                }
                            
                            // REMOVED: Duplicate number display (formattedAmount)
                        }
                    }
                    
                    // MARK: - Notes/Memo Section
                    Section(header: Text("メモ (任意)").font(.headline),
                             footer: Text("レシート番号や店名など、記録を残しておきたい情報を入力してください")) {
                        TextEditor(text: $notes)
                            .frame(height: 80)
                    }
                    
                    // MARK: - Submit Button
                    Section {
                        Button(action: addExpense) {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                Text("支出を追加")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.blue)
                        .foregroundColor(.white)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("支出を追加")
            
            // MARK: - Alert (FIXED: Different title for success/error)
            .alert(isSuccess ? "完了" : "入力エラー", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Business Logic
    private func addExpense() {
        // MARK: - Validation
        guard !amount.isEmpty else {
            isSuccess = false  // This is an error
            alertMessage = "金額を入力してください"
            showAlert = true
            return
        }
        
        // Remove commas from amount for conversion
        let cleanAmount = amount.replacingOccurrences(of: ",", with: "")
        guard let amountDouble = Double(cleanAmount) else {
            isSuccess = false  // This is an error
            alertMessage = "有効な金額を入力してください"
            showAlert = true
            return
        }
        
        guard !selectedLargeCategory.isEmpty else {
            isSuccess = false  // This is an error
            alertMessage = "大分類を選択してください"
            showAlert = true
            return
        }
        
        guard !selectedMediumCategory.isEmpty else {
            isSuccess = false  // This is an error
            alertMessage = "中分類を選択してください"
            showAlert = true
            return
        }
        
        // MARK: - Create and Save Expense
        let expense = ExpenseItem(
            amount: amountDouble,
            category: selectedMediumCategory,
            largeCategory: selectedLargeCategory,
            date: selectedDate,
            notes: notes
        )
        
        dataManager.addExpense(expense)
        
        // MARK: - Reset Form
        amount = ""
        selectedLargeCategory = ""
        selectedMediumCategory = ""
        selectedDate = Date()
        notes = ""
        focusedField = nil  // Reset focus
        
        // MARK: - Show Success Message (NEW: isSuccess = true)
        isSuccess = true  // This is SUCCESS
        alertMessage = "支出が追加されました！"
        showAlert = true
    }
}

#Preview {
    InputView()
        .environmentObject(ExpenseDataManager())
}
