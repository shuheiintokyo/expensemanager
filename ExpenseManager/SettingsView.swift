//
//  SettingsView.swift
//  ExpenseManager
//
//  This view demonstrates:
//  1. Hierarchical category management (Large Class → Medium Class)
//  2. Grouped category display
//  3. Adding new categories with hierarchy
//  4. Deleting categories
//  5. Color and icon selection
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    // MARK: - Modal State
    @State private var showAddCategorySheet: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // MARK: - Group by Large Category
                    ForEach(getLargeCategories(), id: \.self) { largeClass in
                        Section(header: Text(largeClass).font(.headline)) {
                            let mediumCategories = getMediumCategories(for: largeClass)
                            
                            ForEach(Array(mediumCategories.enumerated()), id: \.element.id) { index, category in
                                HStack(spacing: 12) {
                                    // MARK: - Category Icon
                                    Text(category.icon)
                                        .font(.title2)
                                    
                                    // MARK: - Category Info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(category.mediumClass)
                                            .fontWeight(.semibold)
                                        
                                        Text("色: \(category.color)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    // MARK: - Color Indicator
                                    Circle()
                                        .fill(colorFromString(category.color))
                                        .frame(width: 16, height: 16)
                                }
                                .padding(.vertical, 8)
                            }
                            .onDelete { indexSet in
                                deleteCategory(from: largeClass, at: indexSet)
                            }
                        }
                    }
                }
                
                // MARK: - Add Button
                Button(action: { showAddCategorySheet = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("カテゴリーを追加")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("設定")
            
            // MARK: - Sheet Modifier
            .sheet(isPresented: $showAddCategorySheet) {
                AddCategoryView(isPresented: $showAddCategorySheet)
                    .environmentObject(dataManager)
            }
        }
    }
    
    // MARK: - Delete Function
    private func deleteCategory(from largeClass: String, at indexSet: IndexSet) {
        let mediumCategories = getMediumCategories(for: largeClass)
        indexSet.forEach { index in
            if let categoryIndex = dataManager.categories.firstIndex(where: { $0.id == mediumCategories[index].id }) {
                dataManager.deleteCategory(at: categoryIndex)
            }
        }
    }
    
    // MARK: - Color Helper
    private func colorFromString(_ color: String) -> Color {
        switch color.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "yellow": return .yellow
        case "pink": return .pink
        case "purple": return .purple
        case "gray": return .gray
        default: return .blue
        }
    }
}

// MARK: - Add Category Modal
struct AddCategoryView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @Binding var isPresented: Bool
    
    // MARK: - Form State
    @State private var selectedLargeClass: String = "その他"
    @State private var mediumClassName: String = ""
    @State private var selectedIcon: String = "📦"
    @State private var selectedColor: String = "blue"
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    // MARK: - Available Options
    let availableIcons = [
        "🏠", "💰", "🚗", "🍽️", "🛒", "⚡", "💡", "💧", "🔥", "❄️",
        "👕", "👔", "👗", "👞", "🎒", "🚌", "🚆", "✈️", "🚢", "🚕",
        "🎬", "🎮", "🎵", "🎨", "📚", "🏥", "💊", "🩺", "🏋️", "🧘",
        "🛍️", "💳", "💰", "💸", "📊", "🏠", "🛋️", "🛏️", "🪴", "🖼️",
        "📱", "💻", "⌚", "📷", "🎧", "📦", "📝", "✏️", "🔧", "⚙️",
        "🍕", "🍔", "🍜", "🍱", "🌮", "🍺", "🍶", "🍸", "☕", "🧃"
    ]
    
    let availableColors = ["red", "blue", "green", "orange", "yellow", "pink", "purple", "gray"]
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Large Class Selection
                Section(header: Text("大分類 (Large Category)")) {
                    Picker("大分類を選択", selection: $selectedLargeClass) {
                        ForEach(getLargeCategories(), id: \.self) { largeClass in
                            Text(largeClass).tag(largeClass)
                        }
                    }
                    .onChange(of: selectedLargeClass) { _ in
                        mediumClassName = ""
                    }
                }
                
                // MARK: - Medium Class Name
                Section(header: Text("中分類 (Medium Category)")) {
                    TextField("カテゴリー名を入力", text: $mediumClassName)
                }
                
                // MARK: - Icon Selection
                Section(header: Text("アイコン (Icon)")) {
                    VStack(alignment: .leading, spacing: 12) {
                        let columns = [GridItem(.adaptive(minimum: 50), spacing: 8)]
                        
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    Text(icon)
                                        .font(.title)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(
                                            selectedIcon == icon
                                                ? Color.blue.opacity(0.2)
                                                : Color(.systemGray6)
                                        )
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    selectedIcon == icon ? Color.blue : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                }
                            }
                        }
                        
                        Text("選択中: \(selectedIcon)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // MARK: - Color Selection with Preview
                Section(header: Text("色 (Color)")) {
                    VStack(spacing: 12) {
                        Picker("色を選択", selection: $selectedColor) {
                            ForEach(availableColors, id: \.self) { color in
                                HStack {
                                    Text(color.capitalized)
                                    Circle()
                                        .fill(colorFromString(color))
                                        .frame(width: 16, height: 16)
                                }
                                .tag(color)
                            }
                        }
                        
                        // MARK: - Preview Card
                        VStack(spacing: 12) {
                            Text("プレビュー (Preview)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Text(selectedIcon)
                                            .font(.title2)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(mediumClassName.isEmpty ? "New Category" : mediumClassName)
                                                .fontWeight(.semibold)
                                            Text(selectedLargeClass)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    HStack {
                                        Text("色: \(selectedColor.capitalized)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Circle()
                                            .fill(colorFromString(selectedColor))
                                            .frame(width: 12, height: 12)
                                    }
                                }
                                
                                Spacer()
                                
                                Circle()
                                    .fill(colorFromString(selectedColor))
                                    .frame(width: 20, height: 20)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // MARK: - Action Buttons
                Section {
                    Button(action: addCategory) {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                            Text("カテゴリーを追加")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                    
                    Button(action: { isPresented = false }) {
                        HStack {
                            Spacer()
                            Image(systemName: "xmark.circle.fill")
                            Text("キャンセル")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.gray)
                }
            }
            .navigationTitle("カテゴリーを追加")
            .navigationBarTitleDisplayMode(.inline)
            .alert("エラー", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Add Category Logic
    private func addCategory() {
        guard !mediumClassName.isEmpty else {
            errorMessage = "カテゴリー名を入力してください"
            showError = true
            return
        }
        
        // Check for duplicates within the same large class
        let existingInClass = dataManager.categories.filter {
            $0.largeClass == selectedLargeClass && $0.mediumClass.lowercased() == mediumClassName.lowercased()
        }
        
        if !existingInClass.isEmpty {
            errorMessage = "このカテゴリーは既に存在します"
            showError = true
            return
        }
        
        let newCategory = ExpenseCategory(
            largeClass: selectedLargeClass,
            mediumClass: mediumClassName,
            icon: selectedIcon,
            color: selectedColor
        )
        
        dataManager.addCategory(newCategory)
        isPresented = false
    }
    
    // MARK: - Color Helper
    private func colorFromString(_ color: String) -> Color {
        switch color.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "yellow": return .yellow
        case "pink": return .pink
        case "purple": return .purple
        case "gray": return .gray
        default: return .blue
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ExpenseDataManager())
}
