//
//  Routable.swift
//  ScrumManager
//
//  Created by Benjamin Johnson on 16/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

// Protocol that provides route information to actions for an object. These vars are used when creating hyperlinks to show, edit or delete an object
protocol Routable {
    var pathURL: String { get }
    var editURL: String { get }
    func urlsAsDictionary() -> [String: String]
}

extension Routable {
    func urlsAsDictionary() -> [String: String]
    {
        return [
            "pathURL": pathURL,
            "editURL": editURL
        ]
    }
    
    func testFunc() {
        
    }
}
