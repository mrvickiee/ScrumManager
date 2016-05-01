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
