import SwiftUI

struct DailyExpenseInputView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    @State private var amount: String = ""
    @State private var selectedTag: String? = nil
    @State private var tagNote: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var isSuccess: Bool = false
    
    enum Field {
        case amount
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("日付")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(16)
                
                Divider()
                
                // Amount Section (Large, on right)
                VStack(alignment: .trailing, spacing: 12) {
                    Text("金額")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 8) {
                        Text("¥")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        TextField("0", text: $amount)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .amount)
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .onChange(of: amount) { newValue in
                                amount = formatNumberInput(newValue)
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(16)
                
                Divider()
                
                // Tags Section
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("タグを選択")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        // Tag Grid
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                ForEach(Array(dataManager.tags.prefix(3)), id: \.id) { tag in
                                    tagButton(tag)
                                }
                            }
                            
                            if dataManager.tags.count > 3 {
                                HStack(spacing: 10) {
                                    ForEach(Array(dataManager.tags.dropFirst(3).prefix(3)), id: \.id) { tag in
                                        tagButton(tag)
                                    }
                                }
                            }
                            
                            if dataManager.tags.count > 6 {
                                HStack(spacing: 10) {
                                    ForEach(Array(dataManager.tags.dropFirst(6)), id: \.id) { tag in
                                        tagButton(tag)
                                    }
                                }
                            }
                        }
                        
                        // Note Input (only if "その他" selected)
                        if selectedTag == "その他" || selectedTag == nil && !tagNote.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("補足（オプション）")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                TextField("詳細を入力...", text: $tagNote)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(height: 40)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                }
                
                Divider()
                
                // Add Button
                Button(action: addExpense) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("支出を追加")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(16)
            }
            .navigationTitle("日常支出を追加")
        }
        .overlay(alignment: .bottom) {
            if showToast {
                ToastView(message: toastMessage, isSuccess: isSuccess)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Tag Button
    private func tagButton(_ tag: ExpenseTag) -> some View {
        Button(action: {
            if selectedTag == tag.name {
                selectedTag = nil
                tagNote = ""
            } else {
                selectedTag = tag.name
                if tag.name != "その他" {
                    tagNote = ""
                }
            }
        }) {
            VStack(spacing: 4) {
                Text(tag.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                selectedTag == tag.name
                    ? tag.getColor().opacity(0.8)  // Strong opacity when selected
                    : tag.getColor().opacity(0.2)  // Light opacity when unselected
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        selectedTag == tag.name ? tag.getColor() : Color.clear,
                        lineWidth: 2
                    )
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatNumberInput(_ input: String) -> String {
        let filtered = input.filter { $0.isNumber }
        if !filtered.isEmpty {
            if let number = Double(filtered) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.groupingSeparator = ","
                formatter.maximumFractionDigits = 0
                return formatter.string(from: NSNumber(value: number)) ?? filtered
            }
        }
        return ""
    }
    
    private func addExpense() {
        guard !amount.isEmpty else {
            isSuccess = false
            toastMessage = "金額を入力してください"
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showToast = false
                }
            }
            return
        }
        
        let cleanAmount = amount.replacingOccurrences(of: ",", with: "")
        guard let amountDouble = Double(cleanAmount) else {
            isSuccess = false
            toastMessage = "有効な金額を入力してください"
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showToast = false
                }
            }
            return
        }
        
        let expense = DailyExpense(
            amount: amountDouble,
            tag: selectedTag,
            tagNote: tagNote,
            date: selectedDate
        )
        
        dataManager.addDailyExpense(expense)
        
        // Reset form
        amount = ""
        selectedTag = nil
        tagNote = ""
        selectedDate = Date()
        focusedField = nil
        
        isSuccess = true
        toastMessage = "支出が追加されました！"
        showToast = true
        
        // Auto-dismiss toast after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showToast = false
            }
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let message: String
    let isSuccess: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.body)
                .foregroundColor(.white)
            
            Text(message)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(12)
        .background(isSuccess ? Color.green : Color.red)
        .cornerRadius(10)
    }
}

#Preview {
    DailyExpenseInputView()
        .environmentObject(ExpenseDataManager())
}
