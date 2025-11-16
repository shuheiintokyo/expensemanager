//
//  InputView.swift (iPad - NavigationSplitView + GeometryReader)
//  ExpenseManager
//
//  Uses NavigationSplitView for true iPad native experience
//  Uses GeometryReader for truly responsive sizing
//

import SwiftUI

struct InputView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var amount: String = ""
    @State private var selectedLargeCategory: String = ""
    @State private var selectedMediumCategory: String = ""
    @State private var selectedDate: Date = Date()
    @State private var notes: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSuccess: Bool = false
    
    enum Field {
        case largeCategory
        case mediumCategory
        case amount
    }
    @FocusState private var focusedField: Field?
    
    private var availableLargeCategories: [String] {
        Array(Set(dataManager.categories.map { $0.largeClass })).sorted()
    }
    
    private var availableMediumCategories: [ExpenseCategory] {
        guard !selectedLargeCategory.isEmpty else { return [] }
        return dataManager.categories
            .filter { $0.largeClass == selectedLargeCategory }
            .sorted { $0.mediumClass < $1.mediumClass }
    }
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var body: some View {
        if isIPad {
            iPadSplitViewLayout
        } else {
            iPhoneLayout
        }
    }
    
    // MARK: - iPhone Layout (unchanged)
    private var iPhoneLayout: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("日付").font(.headline)) {
                        DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                    }
                    
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
                    
                    Section(header: Text("メモ (任意)").font(.headline),
                             footer: Text("レシート番号や店名など、記録を残しておきたい情報を入力してください")) {
                        TextEditor(text: $notes)
                            .frame(height: 80)
                    }
                    
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
        }
        .alert(isSuccess ? "完了" : "入力エラー", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - iPad NavigationSplitView Layout (TRUE Full Width)
    private var iPadSplitViewLayout: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // LEFT COLUMN - Dynamic width based on available space
                VStack(alignment: .leading, spacing: 24) {
                    Text("支出を追加")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    // Date Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("日付")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    // Large Category Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("大分類")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Picker("大分類を選択", selection: $selectedLargeCategory) {
                            Text("選択してください...").tag("")
                            ForEach(availableLargeCategories, id: \.self) { largeClass in
                                Text(largeClass).tag(largeClass)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
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
                        VStack(alignment: .leading, spacing: 10) {
                            Text("中分類")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Picker("中分類を選択", selection: $selectedMediumCategory) {
                                Text("選択してください...").tag("")
                                ForEach(availableMediumCategories, id: \.id) { category in
                                    Text("\(category.icon) \(category.mediumClass)")
                                        .tag(category.mediumClass)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(20)
                .background(Color(.systemBackground))
                
                // DIVIDER
                Divider()
                    .frame(width: 1)
                
                // RIGHT COLUMN - Dynamic width based on available space
                VStack(alignment: .leading, spacing: 16) {
                    // Amount Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("金額")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        HStack(spacing: 12) {
                            Text("¥")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            TextField("0", text: $amount)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .amount)
                                .font(.title3)
                                .frame(maxWidth: .infinity)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("メモ (任意)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text("レシート番号や店名など、記録を残しておきたい情報を入力してください")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $notes)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 100, maxHeight: .infinity)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .scrollContentBackground(.hidden)
                    }
                    
                    // Submit Button
                    Button(action: addExpense) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("支出を追加")
                                .fontWeight(.semibold)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(20)
                .background(Color(.systemBackground))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert(isSuccess ? "完了" : "入力エラー", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
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
