//
//  DataManager.swift
//  Table View
//
//  Created by Андрей on 06.07.2022.
//

import Foundation

class DataManager {
    var archiveURL: URL? {
        guard let documetDirector = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documetDirector.appendingPathComponent("todos").appendingPathExtension("plist")

    }
    
    func loadToDos() -> [ToDo]? {
        guard let archiveURL = archiveURL else { return nil }
        guard let encodedToDo = try? Data(contentsOf: archiveURL) else { return nil }
        
        let decoder = PropertyListDecoder()
        return try? decoder.decode([ToDo].self, from: encodedToDo)
    }
    
    func saveToDos(_ todos: [ToDo]) {
        guard let archiveURL = archiveURL else { return }

        let encoder = PropertyListEncoder()
        guard let encodedToDo = try? encoder.encode(todos) else { return }
        
        try? encodedToDo.write(to: archiveURL, options: .noFileProtection)
        print(archiveURL)
    }
}

