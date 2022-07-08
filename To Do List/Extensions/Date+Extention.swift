//
//  Date+Extention.swift
//  To Do List
//
//  Created by Андрей on 07.07.2022.
//

import Foundation

extension Date {
    var formatedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
