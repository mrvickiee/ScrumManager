//
//  Callout.swift
//  ScrumManager
//
//  Created by Ben Johnson on 27/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

enum CalloutType: String {
    case None = ""
    case Secondary = "secondary"
    case Success = "success"
    case Warning = "warning"
    case Alert = "alert"
}


struct Callout: CustomDictionaryConvertible {
    
    let type: CalloutType
    let message: String
    
    var dictionary: [String : Any] {
        return [
            "type": type.rawValue,
            "message": message
        ]
    }
    
    
    
}