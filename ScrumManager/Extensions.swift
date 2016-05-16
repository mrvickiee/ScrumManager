//
//  Extensions.swift
//  SwiftBlog
//
//  Created by Ben Johnson on 7/03/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

extension String {
    var length: Int {
        return characters.count
    }
}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}


extension JSONArrayType {
    var stringArray: [String] {
        let stringArray = array.map { (element) -> String in
            return element as! String
        }
        
        return stringArray
    }
}

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}
