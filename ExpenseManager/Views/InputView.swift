//
//  InputView.swift (iPad Responsive Version)
//  ExpenseManager
//
//  This view demonstrates:
//  1. @State for form input management
//  2. @Binding to connect UI controls to state
//  3. Date selection (moved to first position)
//  4. Picker for hierarchical category selection
//  5. TextField for amount with thousand separators and ¥ symbol
//  6. TextField for notes with memo suggestions
//  7. 🆕 iPad responsive layout using size classes
//

import SwiftUI

struct InputView: View {
    // MARK: - Environment Object
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    // MARK: - Size Class Detection (iPad responsive)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // MARK: - Form State Variables
    @State private var amount: String = ""
    @State private var selectedLargeCategory: String = ""
    @State private var selectedMediumCategory: String = ""
    @State private var selectedDate: Date = Date()
    @State private var notes: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSuccess: Bool = false
    
    // MARK: - Focus Management
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
    
    // MARK: - Responsive Layout Detection
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var body: some View {
        NavigationView {
            if isIPad {
                // MARK: - iPad Layout (Horizontal Two-Column)
                iPadLayout
            } else {
                // MARK: - iPhone Layout (Vertical)
                iPhoneLayout
            }
        }
    }
    
    // MARK: - iPhone Vertical Layout
    private var iPhoneLayout: some View {
        VStack {
            Form {
                // MARK: - Date Section
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
                                Text("\(category.icon) \(category.mediumClass)")
                                    .tag(category.mediumClass)
                            }
                        }
                        .focused($focusedField, equals: .mediumCategory)
                        .onChange(of: selectedMediumCategory) { _ in
                            if !selectedMediumCategory.isEmpty {
                                focusedField = .amount
                            }
                        }
                    }
                }
                
                // MARK: - Amount Section
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
                    }
                }
                
                // MARK: - Notes Section
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
        .alert(isSuccess ? "完了" : "入力エラー", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - iPad Horizontal Layout (Two Columns)
    private var iPadLayout: some View {
        VStack {
            HStack(spacing: 0) {
                // MARK: - Left Column (Categories & Date)
                VStack(alignment: .leading, spacing: 20) {
                    Text("支出を追加")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    // Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("日付")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Large Category Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("大分類")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Picker("大分類を選択", selection: $selectedLargeCategory) {
                            Text("選択してください...").tag("")
                            ForEach(availableLargeCategories, id: \.self) { largeClass in
                                Text(largeClass).tag(largeClass)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($focusedField, equals: .largeCategory)
                        .onChange(of: selectedLargeCategory) { _ in
                            selectedMediumCategory = ""
                            if !selectedLargeCategory.isEmpty {
                                focusedField = .mediumCategory
                            }
                        }
                    }
                    
                    // Medium Category Section
                    if !selectedLargeCategory.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("中分類")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Picker("中分類を選択", selection: $selectedMediumCategory) {
                                Text("選択してください...").tag("")
                                ForEach(availableMediumCategories, id: \.id) { category in
                                    Text("\(category.icon) \(category.mediumClass)")
                                        .tag(category.mediumClass)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .focused($focusedField, equals: .mediumCategory)
                            .onChange(of: selectedMediumCategory) { _ in
                                if !selectedMediumCategory.isEmpty {
                                    focusedField = .amount
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(.systemBackground))
                
                // MARK: - Divider
                Divider()
                    .frame(height: 500)
                
                // MARK: - Right Column (Amount & Notes & Button)
                VStack(alignment: .leading, spacing: 20) {
                    // Amount Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("金額")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        HStack(spacing: 8) {
                            Text("¥")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            TextField("0", text: $amount)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .amount)
                                .onChange(of: amount) { newValue in
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
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("メモ (任意)")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("レシート番号や店名など")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $notes)
                            .frame(height: 120)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Submit Button
                    Button(action: addExpense) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("支出を追加")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle("支出を追加")
        .alert(isSuccess ? "完了" : "入力エラー", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Business Logic
    private func addExpense() {
        guard !amount.isEmpty else {
            isSuccess = false
            alertMessage = "金額を入力してください"
            showAlert = true
            return
        }
        
        let cleanAmount = amount.replacingOccurrences(of: ",", with: "")
        guard let amountDouble = Double(cleanAmount) else {
            isSuccess = false
            alertMessage = "有効な金額を入力してください"
            showAlert = true
            return
        }
        
        guard !selectedLargeCategory.isEmpty else {
            isSuccess = false
            alertMessage = "大分類を選択してください"
            showAlert = true
            return
        }
        
        guard !selectedMediumCategory.isEmpty else {
            isSuccess = false
            alertMessage = "中分類を選択してください"
            showAlert = true
            return
        }
        
        let expense = ExpenseItem(
            amount: amountDouble,
            category: selectedMediumCategory,
            largeCategory: selectedLargeCategory,
            date: selectedDate,
            notes: notes
        )
        
        dataManager.addExpense(expense)
        
        amount = ""
        selectedLargeCategory = ""
        selectedMediumCategory = ""
        selectedDate = Date()
        notes = ""
        focusedField = nil
        
        isSuccess = true
        alertMessage = "支出が追加されました！"
        showAlert = true
    }
}

#Preview {
    InputView()
        .environmentObject(ExpenseDataManager())
}
