//
//  InputView.swift
//  ExpenseManager
//
//  This view demonstrates:
//  1. @State for form input management
//  2. @Binding to connect UI controls to state
//  3. Date selection
//  4. Picker for category selection
//  5. TextField for amount and notes input
//

import SwiftUI

struct InputView: View {
    // MARK: - Environment Object
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    // MARK: - Form State Variables
    // @State creates local state that SwiftUI watches
    // When these change, the view automatically re-renders
    @State private var amount: String = ""
    @State private var selectedCategory: String = ""
    @State private var selectedDate: Date = Date()
    @State private var notes: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Amount Section
                Section(header: Text("Amount")) {
                    // MARK: - TextField Binding Explanation
                    // $amount creates a Binding<String>
                    // The $ symbol is syntactic sugar for Binding()
                    // This two-way binding means:
                    // - User types → amount updates → view redraws
                    // - amount changes → text field updates
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                // MARK: - Category Section
                Section(header: Text("Category")) {
                    // MARK: - Picker Explanation
                    // Picker provides a selector
                    // $selectedCategory binds to the selected value
                    // ForEach loops through categories
                    // .tag() identifies each option
                    Picker("Select category", selection: $selectedCategory) {
                        Text("Choose...").tag("")
                        ForEach(dataManager.categories, id: \.id) { category in
                            // HStack to show icon + name
                            HStack {
                                Text(category.icon)
                                Text(category.name)
                            }
                            .tag(category.name)
                        }
                    }
                }
                
                // MARK: - Date Section
                Section(header: Text("Date")) {
                    // MARK: - DatePicker
                    // DatePicker handles date selection with native iOS UI
                    // $selectedDate binds the selected date
                    DatePicker("Select date", selection: $selectedDate, displayedComponents: .date)
                }
                
                // MARK: - Notes Section
                Section(header: Text("Notes")) {
                    // MARK: - TextEditor for multiline input
                    // Similar to TextField but allows multiple lines
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                // MARK: - Submit Button
                Section {
                    Button(action: addExpense) {
                        Text("Add Expense")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Add Expense")
            .alert("Input Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Business Logic
    private func addExpense() {
        // MARK: - Validation
        // Check if required fields are filled
        guard !amount.isEmpty else {
            alertMessage = "Please enter an amount"
            showAlert = true
            return
        }
        
        guard let amountDouble = Double(amount) else {
            alertMessage = "Please enter a valid amount"
            showAlert = true
            return
        }
        
        guard !selectedCategory.isEmpty else {
            alertMessage = "Please select a category"
            showAlert = true
            return
        }
        
        // MARK: - Create and Save Expense
        // Create new ExpenseItem with validated data
        let expense = ExpenseItem(
            amount: amountDouble,
            category: selectedCategory,
            date: selectedDate,
            notes: notes
        )
        
        // Add to data manager (which saves to UserDefaults)
        dataManager.addExpense(expense)
        
        // MARK: - Reset Form
        // Clear all fields for next input
        amount = ""
        selectedCategory = ""
        selectedDate = Date()
        notes = ""
        
        // Show confirmation
        alertMessage = "Expense added successfully!"
        showAlert = true
    }
}

#Preview {
    InputView()
        .environmentObject(ExpenseDataManager())
}
