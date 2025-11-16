//
//  SettingsView.swift
//  ExpenseManager
//
//  This view demonstrates:
//  1. List with edit capabilities
//  2. Adding new categories
//  3. Deleting items from list
//  4. Modal presentation with @State
//  5. Form for adding new categories
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    // MARK: - Modal State
    // Controls whether the "Add Category" sheet is shown
    @State private var showAddCategorySheet: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Categories")) {
                        // MARK: - ForEach with Deletion
                        // onDelete modifier enables swipe-to-delete
                        ForEach(Array(dataManager.categories.enumerated()), id: \.element.id) { index, category in
                            HStack {
                                Text(category.icon)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.name)
                                        .fontWeight(.semibold)
                                    
                                    // MARK: - Color Display
                                    Text("Color: \(category.color)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // Color indicator
                                Circle()
                                    .fill(colorFromString(category.color))
                                    .frame(width: 16, height: 16)
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete { indexSet in
                            deleteCategory(at: indexSet)
                        }
                    }
                }
                
                // MARK: - Add Button
                Button(action: { showAddCategorySheet = true }) {
                    Label("Add Category", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Settings")
            
            // MARK: - Sheet Modifier
            // .sheet presents a modal view
            // isPresented controls whether it's shown
            // onDismiss runs when modal closes
            .sheet(isPresented: $showAddCategorySheet) {
                AddCategoryView(isPresented: $showAddCategorySheet)
                    .environmentObject(dataManager)
            }
        }
    }
    
    // MARK: - Delete Function
    private func deleteCategory(at indexSet: IndexSet) {
        indexSet.forEach { index in
            dataManager.deleteCategory(at: index)
        }
    }
    
    // MARK: - Color Helper
    // Convert color names to SwiftUI Color
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
    
    // MARK: - Form State for New Category
    @State private var name: String = ""
    @State private var selectedIcon: String = "📦"
    @State private var selectedColor: String = "blue"
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    // Available icons and colors
    let availableIcons = ["🍽️", "⚡", "👕", "🚗", "🎬", "🏥", "📦", "💳", "🛍️", "✈️", "🎓", "💊"]
    let availableColors = ["red", "blue", "green", "orange", "yellow", "pink", "purple", "gray"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Name")) {
                    TextField("Enter category name", text: $name)
                }
                
                Section(header: Text("Icon")) {
                    // MARK: - Grid of Icon Buttons
                    VStack {
                        let columns = [GridItem(.adaptive(minimum: 50))]
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    Text(icon)
                                        .font(.title)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color(.systemGray6))
                                        .cornerRadius(8)
                                        .border(selectedIcon == icon ? Color.blue : Color.clear, width: 2)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Color")) {
                    Picker("Select Color", selection: $selectedColor) {
                        ForEach(availableColors, id: \.self) { color in
                            HStack {
                                Text(color.capitalized)
                                Circle()
                                    .fill(colorFromString(color))
                                    .frame(width: 20, height: 20)
                            }
                            .tag(color)
                        }
                    }
                }
                
                Section {
                    Button(action: addCategory) {
                        Text("Add Category")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Add Category")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Add Category Logic
    private func addCategory() {
        guard !name.isEmpty else {
            errorMessage = "Please enter a category name"
            showError = true
            return
        }
        
        // Check for duplicates
        if dataManager.categories.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            errorMessage = "Category already exists"
            showError = true
            return
        }
        
        let newCategory = ExpenseCategory(
            name: name,
            icon: selectedIcon,
            color: selectedColor
        )
        
        dataManager.addCategory(newCategory)
        isPresented = false
    }
    
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
