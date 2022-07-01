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
    
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var howMoneyCanSpend: UILabel!
    @IBOutlet weak var spendByCheck: UILabel!
    @IBOutlet weak var allSpending: UILabel!
    
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
        leftLabels()
        spendingAllTime()
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
        leftLabels()
        spendingAllTime()
        tableView.reloadData()
    }
    
    @IBAction func limitPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Установить лимит",
                                                message: "Введите сумму и количество дней",
                                                preferredStyle: .alert)
        
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { action in
            
            let textFieldSum = alertController.textFields?[0].text
            
            let textFieldDate = alertController.textFields?[1].text
            
            guard textFieldDate != "" && textFieldSum != "" else { return }
            
            self.limitLabel.text = textFieldSum
            
            if let day = textFieldDate {
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60 * 60 * 24 * Double(day)!)
                
                let limit = self.realm.objects(Limit.self)
                
                if limit.isEmpty == true {
                    let value = Limit(value: [self.limitLabel.text, dateNow, lastDay])
                    try! self.realm.write {
                        self.realm.add(value)
                        
                        print("File realm: \(self.realm.configuration.fileURL)")
                    }
                    
                } else {
                    try! self.realm.write{
                        limit[0].limitSum = self.self.limitLabel.text!
                        limit[0].limitDate = dateNow as NSDate
                        limit[0].limitLastDay = lastDay as NSDate
                    }
                }
            }
            self.leftLabels()
        }
        
        alertController.addTextField { (money) in
            money.placeholder = "Сумма"
            money.keyboardType = .asciiCapableNumberPad
        }
        
        alertController.addTextField { (day) in
            day.placeholder = "Количество дней"
            day.keyboardType = .asciiCapableNumberPad
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { _ in }
        
        alertController.addAction(alertInstall)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func leftLabels() {
        
        let limit = self.realm.objects(Limit.self)
        
        guard limit.isEmpty == false else { return }
                
        limitLabel.text = limit[0].limitSum
        
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].limitLastDay as Date
        
        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)
        
        let startDate = formatter.date(from: "\(firstComponents.year!)/\(firstComponents.month!)/\(firstComponents.day!) 00:00") as Any
        let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59") as Any
        
        let filtredLimit: Int = realm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDate, endDate).sum(ofProperty: "cost")
        
        spendByCheck.text = "\(filtredLimit)"
        
        let a = Int(limitLabel.text!)!
        let b = Int(spendByCheck.text!)!
        let c = a - b
        
        howMoneyCanSpend.text = "\(c)"
        
        // расходы за месяц
/*
        let dateNow = Date()
        
        let dateComponentsNow = calendar.dateComponents([.year, .month, .day], from: dateNow)
        
        let lastDayMonth: Int
        if Int(dateComponentsNow.year!) % 4 == 0 && dateComponentsNow.month == 2 {
            lastDayMonth = 29
            
        } else {
            switch dateComponentsNow.month {
            case 1: lastDayMonth = 31
            case 2: lastDayMonth = 28
            case 3: lastDayMonth = 31
            case 4: lastDayMonth = 30
            case 5: lastDayMonth = 31
            case 6: lastDayMonth = 31
            case 7: lastDayMonth = 31
            case 8: lastDayMonth = 31
            case 9: lastDayMonth = 30
            case 10: lastDayMonth = 31
            case 11: lastDayMonth = 30
            case 12: lastDayMonth = 31
                
            default: return
                
            }
        }
        
        let startDateMonth = formatter.date(from: "\(dateComponentsNow.year!)/\(dateComponentsNow.month!)/01 00:00") as Any
        let endDateMonth = formatter.date(from: "\(dateComponentsNow.year!)/\(dateComponentsNow.month!)/\(lastDayMonth) 23:59") as Any
        
        let filtredMonth: Int = realm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDateMonth, endDateMonth).sum(ofProperty: "cost")
        
        print(filtredMonth)
*/
        
    }

    
    func spendingAllTime() {
        
        let allSpend: Int = realm.objects(Spending.self).sum(ofProperty: "cost")
        allSpending.text = "\(allSpend)"
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray.reversed()[indexPath.row]
//        let spending = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]

        
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
        
        let editingRow = spendingArray.reversed()[indexPath.row]
//        let editingRow = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]

        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "удалить") { (_, _) in
            try! self.realm.write{
                self.realm.delete(editingRow)
                self.leftLabels()
                self.spendingAllTime()
                tableView.reloadData()
            }
        }
        
        return [deleteAction]
    }
}
