//
//  DBManagedObject.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 16/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import MongoDB
import PerfectLib

protocol DBManagedObject {
    
    static var collectionName: String { get }
    
    func keyValues() -> [String: Any]
    
    func asDictionary() -> [String: Any]
    
    func document() throws -> BSON
    
    static var ignoredProperties: [String] { get }
    
    init(bson: BSON)
    
    init?(identifier: String)
    
    static var primaryKey: String? { get }
    
 //   var urlPath: String { get }
    
}

typealias ObjectID = Dictionary<JSONKey, JSONValue>

extension DBManagedObject {
    
    static var ignoredProperties: [String] {
        return [] //["urlPath"]
    }
    
    static var primaryKey: String? { return nil }
    
    var identifierDictionary: ObjectID? {
        
        if let object = self as? Object, objectID = object._objectID {
            return ["$oid": objectID] as Dictionary<JSONKey, JSONValue>
        } else {
            return nil
        }
    }
    
    
    func document() throws -> BSON {
        
        var documentData = self.keyValues()
    
        if let object = self as? Object, objectID = object._objectID {
            
            let identifierDict = ["$oid": objectID] as Dictionary<JSONKey, JSONValue>
            documentData["_id"] = identifierDict
        }
        
        let json = try JSONEncoder().encode(documentData)
        let bson = try BSON(json: json)
        
        return bson
    }
    
    func asDictionary() -> [String: Any] {
        return keyValues()
    }
    
    func keyValues() -> [String: Any] {
        
        var properties: [String: Any] = [:]
        
        for child in Mirror(reflecting: self).children {
            
            if let key = child.label where key.characters[key.startIndex] != "_" && !Self.ignoredProperties.contains(key) {
                properties[key] = child.value as Any
            }
        }
        
        return properties
        
    }
    
}

extension DBManagedObject where Self: Object {
    var primaryKey: String? { return "_objectID" }
}
