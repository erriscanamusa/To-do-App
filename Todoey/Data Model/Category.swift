//
//  Category.swift
//  Todoey
//
//  Created by Erris Canamusa on 7/18/19.
//  Copyright © 2019 Erris Canamusa. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
    
    // let array : Array<Int> = [1,2,3]
    // let array = Array<Int>()
}


