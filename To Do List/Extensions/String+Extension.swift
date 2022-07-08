//
//  String+Extension.swift
//  To Do List
//
//  Created by Андрей on 07.07.2022.
//

extension String {
    var capitilizedWithSpaces: String {
        let withSpaces = reduce("") { result, character in
            character.isUppercase ? "\(result) \(character)" : "\(result)\(character)"
        }
        
        return withSpaces.capitalized
    }
}
