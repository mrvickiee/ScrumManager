//
//  User.swift
//  ScrumManager
//
//  Created by Ben Johnson on 14/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import MongoDB
import PerfectLib

enum CreateUserError: ErrorType {
    case EmailExists
    case InvalidPassword
    case DatabaseError
}

final class User: Object {
    
    var email: String
    var authKey: String
    var profilePictureURL: String = ""
    var name: String
    
    init(email: String, name: String, authKey: String) {
        self.email = email
        self.name = name
        self.authKey = authKey
        
    }
    
    convenience init?(email: String) {
        let database = try! DatabaseManager().database
        let results = database.getCollection(User).find(["email": email])
        defer {
            results?.close()
        }
        
        guard let userBSON = results?.next() else {
            return nil
        }
        
        self.init(bson: userBSON)
    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        let email = dictionary["email"] as! String
        
        let name = dictionary["name"] as! String
        
        let authKey = dictionary["authKey"] as! String
        
        let pictureURL = dictionary["pictureURL"] as? String ?? ""
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        self.init(email: email, name: name, authKey: authKey)
        
        self.profilePictureURL = pictureURL
        
        self._objectID = id
    }
    
    convenience init?(identifier: String) {
        return nil
    }
}

extension User: DBManagedObject {
    
    static var collectionName = "user"
    
    static func create(name: String, email: String, password: String, pictureURL: String = "") throws -> User {
        
        // Check Email uniqueness
        guard User(email: email) == nil else {
            throw CreateUserError.EmailExists
        }
        
        guard password.length > 5 else {
            throw CreateUserError.InvalidPassword
        }
        
        let authKey = encodeRawPassword(email, password: password)
        let user = User(email: email, name: name, authKey: authKey)
        
        do {
            try DatabaseManager().database.insert(user)
            return user
        } catch {
            print(error)
            throw CreateUserError.DatabaseError
        }
    }
    
    static func encodeRawPassword(email: String, password: String, realm: String = AUTH_REALM) -> String {
        let bytes = "\(email):\(realm):\(password)".md5
        return toHex(bytes)
    }
 
    

    
    
    
    
}
