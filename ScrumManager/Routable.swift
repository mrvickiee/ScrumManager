//
//  Routable.swift
//  ScrumManager
//
//  Created by Benjamin Johnson on 16/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

// Protocol that provides route information to actions for an object. These vars are used when creating hyperlinks to show, edit or delete an object
protocol Routable {
    var pathURL: String { get }
    var editURL: String { get }
    func urlsAsDictionary() -> [String: String]
}

protocol RoutableController {
    var newURL: String { get }
    var createURL: String { get }
}


extension RoutableController where Self: RESTController {
    
    var newURL: String {
        return "/\(modelPluralName)/new"
    }
    
    var createURL: String {
        return "/\(modelPluralName)"
    }
    
    var routeDictionary: [String: Any] {
        return [
            "newURL": newURL,
            "createURL": createURL
        ]
        
    }
    
}

extension Routable {
    func urlsAsDictionary() -> [String: String]
    {
        return [
            "pathURL": pathURL,
            "editURL": editURL
        ]
    }
    
}


extension DBManagedObject where Self: Routable {
    
    var dictionary:[String: Any] {
        var dictionary = keyValues
        dictionary["urlPath"] = pathURL
        
        return dictionary
    }
    
}
    