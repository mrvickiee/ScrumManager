//
//  DBManagedObject.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 16/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

/*
 ManagedObject protocol is for objects that are inserted and retrieved from mongoDB. 
 
 The function keyValues converts the objects properties into a key value dictionary representation for saving to mongo (Uses property names as keys).
 asDictionary is used for generating the key values for our controllers (pages), this exists to expand upon the object properties so that urls can be added in here and is seperate from keyValues as we don't want to write these urls to the database.
 Document creates the special BSON format that MongoDB uses, by encoding the keyValues() result.
 */

import MongoDB
import PerfectLib

protocol DBManagedObject: CustomDictionaryConvertible, DictionarySerializable, JSONConvertible {
    
    static var collectionName: String { get }
    
    var keyValues:[String: Any] { get }
    
    func document() throws -> BSON
    
    static var ignoredProperties: [String] { get }
    
    init(bson: BSON)
    
    static var primaryKey: String? { get }
    
 //   var urlPath: String { get }
    
}

typealias ObjectID = Dictionary<JSONKey, JSONValue>

extension DBManagedObject where Self: DictionarySerializable {
    var jsonValue: JSONConvertible {
        return dictionary
    }
}


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
        
        var documentData = self.keyValues
    
        if let object = self as? Object, objectID = object._objectID {
            
            let identifierDict = ["$oid": objectID] as Dictionary<JSONKey, JSONValue>
            documentData["_id"] = identifierDict
        }
        
        let json = try JSON().encode(documentData)
        let bson = try BSON(json: json)
        
        return bson
    }
    
    var dictionary:[String: Any] {
        return keyValues
    }
    
    var keyValues:[String: Any] {
        
        var properties: [String: Any] = [:]
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            
            if let key = child.label where key.characters[key.startIndex] != "_" && !Self.ignoredProperties.contains(key) {
                
                if let value = child.value as? CustomDictionaryConvertible {
                    properties[key] = value.dictionary
                } else if let array = child.value as? Array<Any>  {
                     let dictionaryConvertibleArray = array.map({ (element) -> [String: Any] in
                        let dictionaryConvertible = element as! CustomDictionaryConvertible
                    
                        return dictionaryConvertible.dictionary
                    })
                    properties[key] =  dictionaryConvertibleArray
                    
                   
                } else {
                    let mi = Mirror(reflecting: child.value)
                    if mi.displayStyle != .Optional {
                        properties[key] = child.value as Any
                    }
                    else if mi.children.count == 0 { properties[key] = NSNull() }
                    else {
                        let (_, some) = mi.children.first!
                        properties[key] = some
                    }
                   
                }
            
            }
        }
        
        return properties
        
    }
    
}

extension DBManagedObject where Self: Object {
    var primaryKey: String? { return "_objectID" }
}
