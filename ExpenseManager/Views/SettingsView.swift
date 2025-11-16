//
//  SettingsView.swift (iPad - GeometryReader Dynamic)
//  ExpenseManager
//
//  Uses GeometryReader for truly responsive sizing on iPad
//  Category management with full-width 50/50 layout
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var showAddCategorySheet: Bool = false
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var body: some View {
        NavigationView {
            if isIPad {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
    }
    
    // MARK: - iPhone Layout
    private var iPhoneLayout: some View {
        VStack {
            List {
                ForEach(getLargeCategories(), id: \.self) { largeClass in
                    Section(header: Text(largeClass).font(.headline)) {
                        let mediumCategories = getMediumCategories(for: largeClass)
                        
                        ForEach(Array(mediumCategories.enumerated()), id: \.element.id) { index, category in
                            HStack(spacing: 12) {
                                Text(category.icon)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.mediumClass)
                                        .fontWeight(.semibold)
                                    
                                    Text("色: \(category.color)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
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
            
            // Add Button
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
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategoryView(isPresented: $showAddCategorySheet)
                .environmentObject(dataManager)
        }
    }
    
    // MARK: - iPad Layout (Full Width GeometryReader)
    private var iPadLayout: some View {
        GeometryReader { geometry in
            let columnWidth = geometry.size.width / 2
            
            HStack(spacing: 0) {
                // LEFT COLUMN - Category List (50%)
                VStack(alignment: .leading, spacing: 16) {
                    Text("設定")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    List {
                        ForEach(getLargeCategories(), id: \.self) { largeClass in
                            Section(header: Text(largeClass).font(.headline)) {
                                let mediumCategories = getMediumCategories(for: largeClass)
                                
                                ForEach(Array(mediumCategories.enumerated()), id: \.element.id) { index, category in
                                    HStack(spacing: 12) {
                                        Text(category.icon)
                                            .font(.title3)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(category.mediumClass)
                                                .font(.body)
                                                .fontWeight(.semibold)
                                            
                                            Text(largeClass)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Circle()
                                            .fill(colorFromString(category.color))
                                            .frame(width: 12, height: 12)
                                    }
                                    .padding(.vertical, 6)
                                }
                                .onDelete { indexSet in
                                    deleteCategory(from: largeClass, at: indexSet)
                                }
                            }
                        }
                    }
                    
                    // Add Button
                    Button(action: { showAddCategorySheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("追加")
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
                .frame(width: columnWidth, height: geometry.size.height)
                .background(Color(.systemBackground))
                
                // DIVIDER
                Divider()
                    .frame(width: 1)
                
                // RIGHT COLUMN - Statistics & Info (50%)
                VStack(alignment: .leading, spacing: 20) {
                    Text("カテゴリー統計")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(getLargeCategories(), id: \.self) { largeClass in
                                let mediumCategories = getMediumCategories(for: largeClass)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(largeClass)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        Text("\(mediumCategories.count)個")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(mediumCategories.prefix(3), id: \.id) { category in
                                            HStack(spacing: 8) {
                                                Text(category.icon)
                                                    .frame(width: 24)
                                                Text(category.mediumClass)
                                                    .font(.caption)
                                                    .lineLimit(1)
                                                Spacer()
                                                Circle()
                                                    .fill(colorFromString(category.color))
                                                    .frame(width: 8, height: 8)
                                            }
                                        }
                                        
                                        if mediumCategories.count > 3 {
                                            Text("他 \(mediumCategories.count - 3) 個")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                                .padding(.top, 4)
                                        }
                                    }
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            
                            Spacer()
                            
                            // Info Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("情報")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    Text("全カテゴリー数")
                                    Spacer()
                                    Text("\(dataManager.categories.count)")
                                        .fontWeight(.semibold)
                                }
                                .font(.body)
                                
                                HStack {
                                    Text("大分類数")
                                    Spacer()
                                    Text("\(getLargeCategories().count)")
                                        .fontWeight(.semibold)
                                }
                                .font(.body)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: columnWidth, height: geometry.size.height)
                .padding(16)
                .background(Color(.systemBackground))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategoryView(isPresented: $showAddCategorySheet)
                .environmentObject(dataManager)
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
    
    // MARK: - Helper Functions
    private func getLargeCategories() -> [String] {
        Array(Set(dataManager.categories.map { $0.largeClass })).sorted()
    }
    
    private func getMediumCategories(for largeClass: String) -> [ExpenseCategory] {
        dataManager.categories
            .filter { $0.largeClass == largeClass }
            .sorted { $0.mediumClass < $1.mediumClass }
    }
    
    private func colorFromString(_ color: String) -> Color {
        switch color.lowercased() {
        case "red": return Color(red: 1.0, green: 0.3, blue: 0.3)
        case "blue": return Color(red: 0.0, green: 0.5, blue: 1.0)
        case "green": return Color(red: 0.2, green: 0.8, blue: 0.2)
        case "orange": return Color(red: 1.0, green: 0.6, blue: 0.0)
        case "yellow": return Color(red: 1.0, green: 0.85, blue: 0.0)
        case "pink": return Color(red: 1.0, green: 0.4, blue: 0.7)
        case "purple": return Color(red: 0.6, green: 0.4, blue: 1.0)
        case "gray": return .gray
        default: return .blue
        }
    }
}

// MARK: - Add Category Modal
struct AddCategoryView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @Binding var isPresented: Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var selectedLargeClass: String = "その他"
    @State private var mediumClassName: String = ""
    @State private var selectedIcon: String = "📦"
    @State private var selectedColor: String = "blue"
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    let availableIcons = [
        "🏠", "💰", "🚗", "🍽️", "🛒", "⚡", "💡", "💧", "🔥", "❄️",
        "👕", "👔", "👗", "👞", "🎒", "🚌", "🚆", "✈️", "🚢", "🚕",
        "🎬", "🎮", "🎵", "🎨", "📚", "🏥", "💊", "🩺", "🏋️", "🧘",
        "🛍️", "💳", "💰", "💸", "📊", "🏠", "🛋️", "🛏️", "🪴", "🖼️",
        "📱", "💻", "⌚", "📷", "🎧", "📦", "📝", "✏️", "🔧", "⚙️",
        "🍕", "🍔", "🍜", "🍱", "🌮", "🍺", "🍶", "🍸", "☕", "🧃"
    ]
    
    let availableColors = ["red", "blue", "green", "orange", "yellow", "pink", "purple", "gray"]
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var body: some View {
        NavigationView {
            if isIPad {
                // iPad: Two-column layout
                GeometryReader { geometry in
                    let columnWidth = geometry.size.width / 2
                    
                    HStack(spacing: 0) {
                        // Left: Form
                        VStack {
                            formContent
                        }
                        .frame(width: columnWidth)
                        .padding()
                        .background(Color(.systemBackground))
                        
                        Divider()
                            .frame(width: 1)
                        
                        // Right: Preview
                        VStack(alignment: .leading, spacing: 20) {
                            Text("プレビュー")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            previewCard
                            
                            Spacer()
                        }
                        .frame(width: columnWidth)
                        .padding()
                        .background(Color(.systemGray6))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .navigationTitle("カテゴリーを追加")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("キャンセル") { isPresented = false }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("追加", action: addCategory)
                            .fontWeight(.semibold)
                    }
                }
            } else {
                // iPhone: Scrollable form
                Form {
                    formContent
                }
                .navigationTitle("カテゴリーを追加")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("キャンセル") { isPresented = false }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("追加", action: addCategory)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Form Content
    private var formContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Large Class Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("大分類 (Large Category)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Picker("大分類を選択", selection: $selectedLargeClass) {
                    ForEach(getLargeCategories(), id: \.self) { largeClass in
                        Text(largeClass).tag(largeClass)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onChange(of: selectedLargeClass) { _ in
                    mediumClassName = ""
                }
            }
            
            // Medium Class Name
            VStack(alignment: .leading, spacing: 8) {
                Text("中分類 (Medium Category)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextField("カテゴリー名を入力", text: $mediumClassName)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Icon Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("アイコン (Icon)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
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
            
            // Color Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("色 (Color)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
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
                .pickerStyle(.menu)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Preview Card
    private var previewCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text(selectedIcon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mediumClassName.isEmpty ? "New Category" : mediumClassName)
                        .fontWeight(.semibold)
                    Text(selectedLargeClass)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                Text("色: \(selectedColor.capitalized)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Circle()
                    .fill(colorFromString(selectedColor))
                    .frame(width: 16, height: 16)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .border(Color.blue, width: 1)
    }
    
    // MARK: - Add Category Logic
    private func addCategory() {
        guard !mediumClassName.isEmpty else {
            errorMessage = "カテゴリー名を入力してください"
            showError = true
            return
        }
        
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
    
    // MARK: - Helper Functions
    private func getLargeCategories() -> [String] {
        Array(Set(dataManager.categories.map { $0.largeClass })).sorted()
    }
    
    private func colorFromString(_ color: String) -> Color {
        switch color.lowercased() {
        case "red": return Color(red: 1.0, green: 0.3, blue: 0.3)
        case "blue": return Color(red: 0.0, green: 0.5, blue: 1.0)
        case "green": return Color(red: 0.2, green: 0.8, blue: 0.2)
        case "orange": return Color(red: 1.0, green: 0.6, blue: 0.0)
        case "yellow": return Color(red: 1.0, green: 0.85, blue: 0.0)
        case "pink": return Color(red: 1.0, green: 0.4, blue: 0.7)
        case "purple": return Color(red: 0.6, green: 0.4, blue: 1.0)
        case "gray": return .gray
        default: return .blue
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ExpenseDataManager())
}
