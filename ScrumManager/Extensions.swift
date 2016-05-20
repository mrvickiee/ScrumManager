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

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
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

extension Int {
    static func randomNumber(max: Int, min: Int = 0) -> Int{
    
       return Int(arc4random_uniform(UInt32(max)) + UInt32(min))
    }
}

extension NSDate {
    
    func isSameDay(date:NSDate) -> Bool {
        
        let calender = NSCalendar.currentCalendar()
        let flags: NSCalendarUnit = [.Day, .Month, .Year]
        let compOne: NSDateComponents = calender.components(flags, fromDate: self)
        let compTwo: NSDateComponents = calender.components(flags, fromDate: date)
        
        return (compOne.day == compTwo.day && compOne.month == compTwo.month && compOne.year == compTwo.year);
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
