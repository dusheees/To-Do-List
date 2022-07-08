//
//  DateCell.swift
//  To Do List
//
//  Created by Андрей on 07.07.2022.
//

import UIKit

class DateCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    
    func setDate(_ date: Date) {
        label.text = date.formatedDate
    }
}
