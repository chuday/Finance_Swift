//
//  SpendingModel.swift
//  Finance
//
//  Created by Mikhail Chudaev on 09.11.2021.
//

import RealmSwift

class Spending: Object {
    @objc dynamic var category = ""
    @objc dynamic var cost = 1
    @objc dynamic var date = NSDate()
}
