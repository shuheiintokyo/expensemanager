import Foundation
import CoreData

// MARK: - Expense Core Data Entity
// This file defines the Expense model that represents each expense record
// Core Data automatically creates these entities in the database

@objc(Expense)
public class Expense: NSManagedObject {
    
}

// MARK: - Extension with SwiftUI-friendly properties
extension Expense {
    @NSManaged public var id: UUID
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var note: String
    
    // MARK: - Computed Properties (not stored in database, calculated on the fly)
    // These make displaying expenses easier in the UI
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
}
