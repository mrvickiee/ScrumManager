//
//  CustomJSONConvertible.swift
//  Jay
//
//  Created by Ben Johnson on 4/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

// Protocol for supported types that can be converted into JsonValue
protocol JSONConvertible {}

protocol CustomJSONConvertible {
    var jsonValue: JSONConvertible { get }
}

extension Double : JSONConvertible {}
extension Float: JSONConvertible {}
extension Int: JSONConvertible {}
extension Bool: JSONConvertible {}
extension NSNumber: JSONConvertible {}
extension String: JSONConvertible {}
extension Dictionary: JSONConvertible {}
extension Array: JSONConvertible {}

extension NSDate: CustomJSONConvertible {
    var jsonValue: JSONConvertible {
        return self.timeIntervalSince1970
    }
}



class Vehicle {
    var numberOfWheels: Int = 4
    
}

extension Vehicle: CustomJSONConvertible {
    var jsonValue: JSONConvertible {
        return ["wheels": numberOfWheels]
    }
}

 