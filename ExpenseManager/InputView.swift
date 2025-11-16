//
//  InputView.swift
//  ExpenseManager
//
//  This view demonstrates:
//  1. @State for form input management
//  2. @Binding to connect UI controls to state
//  3. Date selection
//  4. Picker for hierarchical category selection (large → medium)
//  5. TextField for amount and notes input
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
            Form {
                // MARK: - Amount Section
                Section(header: Text("金額")) {
                    TextField("金額を入力", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                // MARK: - Large Category Section
                Section(header: Text("大分類")) {
                    Picker("大分類を選択", selection: $selectedLargeCategory) {
                        Text("選択してください...").tag("")
                        ForEach(availableLargeCategories, id: \.self) { largeClass in
                            Text(largeClass).tag(largeClass)
                        }
                    }
                    .onChange(of: selectedLargeCategory) { _ in
                        selectedMediumCategory = ""
                    }
                }
                
                // MARK: - Medium Category Section
                if !selectedLargeCategory.isEmpty {
                    Section(header: Text("中分類")) {
                        Picker("中分類を選択", selection: $selectedMediumCategory) {
                            Text("選択してください...").tag("")
                            ForEach(availableMediumCategories, id: \.id) { category in
                                HStack {
                                    Text(category.icon)
                                    Text(category.mediumClass)
                                }
                                .tag(category.mediumClass)
                            }
                        }
                    }
                }
                
                // MARK: - Date Section
                Section(header: Text("日付")) {
                    DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                }
                
                // MARK: - Notes Section
                Section(header: Text("メモ")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                // MARK: - Submit Button
                Section {
                    Button(action: addExpense) {
                        Text("支出を追加")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("支出を追加")
            .alert("入力エラー", isPresented: $showAlert) {
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
            alertMessage = "金額を入力してください"
            showAlert = true
            return
        }
        
        guard let amountDouble = Double(amount) else {
            alertMessage = "有効な金額を入力してください"
            showAlert = true
            return
        }
        
        guard !selectedLargeCategory.isEmpty else {
            alertMessage = "大分類を選択してください"
            showAlert = true
            return
        }
        
        guard !selectedMediumCategory.isEmpty else {
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
        
        alertMessage = "支出が追加されました！"
        showAlert = true
    }
}

#Preview {
    InputView()
        .environmentObject(ExpenseDataManager())
}
