//
//  Category.swift
//  Todoey
//
//  Created by Facundo Bogado on 29/04/2020.
//  Copyright © 2020 Facundo Bogado. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
