//
//  ToDoTableViewController.swift
//  To Do List
//
//  Created by Андрей on 07.07.2022.
//

import UIKit
import UserNotifications

class ToDoTableViewController: UITableViewController {
    
    let dataManager = DataManager()
    let notificationCenter = UNUserNotificationCenter.current()
    
    var todos = [ToDo]() {
        didSet {
            dataManager.saveToDos(todos)
        }
    }
    
    // MARK: - UIView Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        todos = dataManager.loadToDos() ?? [
            ToDo(title: "Купить хлеб", image: UIImage(named: "bread")!),
            ToDo(title: "Записать ребенка в школу", image: UIImage(named: "scool")!),
            ToDo(title: "Подготовить питч", image: UIImage(named: "pitch")!),
        ]
        navigationItem.leftBarButtonItem = editButtonItem
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (permissionGranted, error) in
            if(!permissionGranted)
            {
                print("Permission Denied")
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as! ToDoCell
        let todo = todos[indexPath.row]
        configure(cell, with: todo)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedToDo = todos.remove(at: sourceIndexPath.row)
        todos.insert(movedToDo, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .insert:
            break
        case .none:
            break
        @unknown default:
            print(#line, #function, "Unknown case in file \(#file)")
            break
        }
        
    }
    
    // MARK: - Cell Content
    func configure(_ cell: ToDoCell, with todo: ToDo) {
        guard let stackView = cell.stackView else { return }

        stackView.arrangedSubviews.forEach { subview in
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        for index in 0 ..< todo.keys.count {
            let key = todo.capitalizedKeys[index]
            let value = todo.values[index]
            
            if let stringValue = value as? String {
                
                let label = UILabel()
                label.text = "\(key): \(stringValue)"
                stackView.addArrangedSubview(label)
                if stringValue == "" && key.lowercased() == todo.keys[3] {
                    label.isHidden = true 
                }
                
            } else if let dateValue = value as? Date {
                
                let label = UILabel()
                label.text = "\(key): \(dateValue.formatedDate)"
                stackView.addArrangedSubview(label)
                
            } else if let boolValue = value as? Bool {
                
                let label = UILabel()
                label.text = "\(key): \(boolValue ? "✅" : "⬜️")"
                stackView.addArrangedSubview(label)
                
            } else if let imageValue = value as? Data {
                
                let imageView = UIImageView(image: UIImage(data: imageValue))
                imageView.contentMode = .scaleAspectFit
                let heightConstraint = NSLayoutConstraint(
                    item: imageView,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .height,
                    multiplier: 1,
                    constant: 200
                )
                imageView.addConstraint(heightConstraint)
                if imageView.image == nil {
                    imageView.isHidden = true
                }
                stackView.addArrangedSubview(imageView)
                
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndex = tableView.indexPathForSelectedRow else { return }
        let destination = segue.destination as! ToDoItemTableViewController
        destination.todo = todos[selectedIndex.row].copy() as! ToDo
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "SaveSegue" else { return }
        let source = segue.source as! ToDoItemTableViewController
        for index in 0 ..< source.todo.keys.count {
            let value = source.todo.values[index]
            if let dateValue = value as? Date {
                sendNotifications(dateValue: dateValue, todo: source.todo)
            }
        }
        guard let selectedIndex = tableView.indexPathForSelectedRow else {
            todos.append(source.todo)
            tableView.reloadData()
            return
        }
        todos[selectedIndex.row] = source.todo
        if let toDoCell = tableView.cellForRow(at: selectedIndex) as? ToDoCell {
            if let stackView = toDoCell.stackView {
                stackView.arrangedSubviews.forEach { subview in
                    stackView.removeArrangedSubview(subview)
                    subview.removeFromSuperview()
                }
            }
        }

        tableView.reloadRows(at: [selectedIndex], with: .automatic)
    }
}

// MARK: - Notifications
extension ToDoTableViewController {
    func sendNotifications(dateValue: Date, todo: ToDo) {
        notificationCenter.getNotificationSettings { (settings) in
            
            DispatchQueue.main.async
            {
                let title = "To Do List"
                let message = todo.title
                let date = dateValue
                print(date)
                
                if(settings.authorizationStatus == .authorized)
                {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request) { (error) in
                        if(error != nil)
                        {
                            print("Error " + error.debugDescription)
                            return
                        }
                    }
                    let ac = UIAlertController(title: "Уведомление запланировано", message: "На " + date.formatedDate, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in}))
                    self.present(ac, animated: true)
                }
                else
                {
                    let ac = UIAlertController(title: "Разрешить уведомления?", message: "Чтобы использовать эту функцию, вы должны включить уведомления в настройках", preferredStyle: .alert)
                    let goToSettings = UIAlertAction(title: "Настройки", style: .default)
                    { (_) in
                        guard let setttingsURL = URL(string: UIApplication.openSettingsURLString)
                        else
                        {
                            return
                        }
                        
                        if(UIApplication.shared.canOpenURL(setttingsURL))
                        {
                            UIApplication.shared.open(setttingsURL) { (_) in}
                        }
                    }
                    ac.addAction(goToSettings)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in}))
                    self.present(ac, animated: true)
                }
            }
        }
    }
}
