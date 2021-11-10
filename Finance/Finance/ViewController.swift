//
//  ViewController.swift
//  Finance
//
//  Created by Mikhail Chudaev on 08.11.2021.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try! Realm()
    
    var spendingArray: Results<Spending>!
    
    var stillTyping = false
    
    @IBOutlet weak var displayLabel: UILabel!
    
    @IBOutlet var numberFromKeyboards: [UIButton]! {
        didSet {
            for button in numberFromKeyboards {
                button.layer.cornerRadius = 11
            }
        }
    }
    
    var categoryName = ""
    var displayValue: Int = 1
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spendingArray = realm.objects(Spending.self)
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        let number = sender.titleLabel?.text
        
        if stillTyping == true {
            if displayLabel.text == "0" {
                displayLabel.text = ""
            }
            if displayLabel.text!.count < 15 {
                displayLabel.text = displayLabel.text! + number!
            }
        } else {
            displayLabel.text = number
            stillTyping = true
        }
    }
    
    @IBAction func resedButton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
        print("Resed button")
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        categoryName = (sender.titleLabel?.text)!
        displayValue = Int(displayLabel.text!)!
        
        displayLabel.text = "0"
        stillTyping = false
        
        let value = Spending(value: ["\(categoryName)", displayValue])
        try! realm.write {
            realm.add(value)
            
            print("File realm: \(realm.configuration.fileURL)")
            
        }
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray[indexPath.row]
        
        cell.recordCategory.text = spending.category
        cell.recordCost.text = "\(spending.cost)"
        
        switch spending.category {
            case "еда": cell.recordImage.image = UIImage(systemName: "circle.grid.cross")
            case "одежда": cell.recordImage.image = UIImage(systemName: "tshirt")
            case "связь": cell.recordImage.image = UIImage(systemName: "phone.connection")
            case "досуг": cell.recordImage.image = UIImage(systemName: "book")
            case "авто": cell.recordImage.image = UIImage(systemName: "car")
            case "красота": cell.recordImage.image = UIImage(systemName: "heart.square")
            
            default: cell.recordImage.image = UIImage(named: "pencil.slash")
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editingRow = spendingArray[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "удалить") { (_, _) in
            try! self.realm.write{
                self.realm.delete(editingRow)
                tableView.reloadData()
            }
        }
        
        return [deleteAction]
        
    }
}
