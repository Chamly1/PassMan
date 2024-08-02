//
//  SortingEnums.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 02.08.2024.
//

import Foundation

enum SortOptions: String, CaseIterable, Identifiable {
    case dateCreated = "Date Created"
    case dateEdited = "Date Edited"
    case title = "Title"
    
    var id: String { self.rawValue}
}

enum SortOrders: String, CaseIterable, Identifiable {
    case ascending = "Ascending"
    case descending = "Descending"
    
    var id: String { self.rawValue }
}
