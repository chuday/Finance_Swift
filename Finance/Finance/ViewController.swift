//
//  ViewController.swift
//  Finance
//
//  Created by Mikhail Chudaev on 08.11.2021.
//

import UIKit

class ViewController: UIViewController {
    
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
    var displayValue = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        let number = sender.titleLabel?.text
        
        if stillTyping {
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
        displayValue = displayLabel.text!
        
        displayLabel.text = "0"
        stillTyping = false
        
        print(categoryName)
        print(displayValue)
        
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
    
}
