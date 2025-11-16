import CoreData

// MARK: - PersistenceController
// ============================================
// KEY SWIFTUI CONCEPT: Singleton Pattern
// ============================================
// A Singleton is a design pattern where only ONE instance of a class/struct exists
// Benefits:
// - Centralized data access: everywhere in the app accesses the SAME database
// - Thread-safe: Core Data's viewContext is main-thread only
// - Memory efficient: no duplicate database connections
//
// Usage: PersistenceController.shared (NOT PersistenceController())

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    // MARK: - Initializer with explanation
    init(inMemory: Bool = false) {
        // NSPersistentContainer is Apple's way to manage the Core Data stack
        // It handles: database creation, loading stores, managing contexts
        // "ExpenseManager" = name of your .xcdatamodeld file (without extension)
        container = NSPersistentContainer(name: "ExpenseManager")
        
        // For PREVIEWS and TESTING: use in-memory storage
        // In-memory = data exists only while app runs, not saved to disk
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // CRITICAL: Load the persistent stores from disk
        // Without this, your database won't actually load!
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // In production, you'd handle this more gracefully
                print("Core Data Load Error: \(error)")
                print("Error Info: \(error.userInfo)")
            }
        }
        
        // IMPORTANT for multi-threaded apps:
        // automaticallyMergesChangesFromParent = true means:
        // If data changes on a background thread, automatically update the UI
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Preview Helper (for SwiftUI previews)
    // ============================================
    // KEY CONCEPT: @MainActor
    // @MainActor = "this code MUST run on the main thread"
    // SwiftUI previews run on main thread, so we need this annotation
    //
    // This creates a temporary in-memory database for testing the UI
    // It's NOT saved to disk, only exists during preview
    
    @MainActor
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Add 5 sample expenses for preview
        for i in 0..<5 {
            let expense = Expense(context: viewContext)
            expense.id = UUID()
            expense.amount = Double.random(in: 500...5000)
            expense.category = ["食べ物", "電気代", "エンターテイメント", "衣類"].randomElement() ?? "その他"
            expense.date = Date().addingTimeInterval(TimeInterval(-86400 * i))
            expense.note = "Sample \(i)"
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Preview save failed: \(error)")
        }
        
        return controller
    }()
}
