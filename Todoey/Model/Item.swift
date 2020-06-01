//
//  Item.swift
//  Todoey
//
//  Created by Facundo Bogado on 29/04/2020.
//  Copyright © 2020 Facundo Bogado. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
   @objc dynamic var title: String = ""
    @objc dynamic var isChecked: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
