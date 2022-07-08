//
//  ToDo.swift
//  To Do List
//
//  Created by Андрей on 07.07.2022.
//

import UIKit

@objcMembers class ToDo: NSObject, Codable {
    var title: String
    var isComplete: Bool
    var dueDate: Date
    var notes: String?
    var image: Data?
    
    init(
        title: String = "",
        isComplete: Bool = false,
        dueDate: Date = Date(),
        notes: String? = String(),
        image: UIImage = UIImage()
    ) {
        self.title = title
        self.isComplete = isComplete
        self.dueDate = dueDate
        self.notes = notes
        self.image = image.pngData() ?? Data()
    }
    
    var capitalizedKeys: [String] {
        return keys.map { $0.capitilizedWithSpaces }
    }
    
    var keys: [String] {
        return Mirror(reflecting: self).children.compactMap { $0.label }
    }
    
    var values: [Any?] {
        return Mirror(reflecting: self).children.map { $0.value }
    }
    
    override func copy() -> Any {
        let newToDo = ToDo(
            title: title,
            isComplete: isComplete,
            dueDate: dueDate,
            notes: notes,
            image: UIImage(data: image ?? Data()) ?? UIImage()
        )
        return newToDo
    }
}

