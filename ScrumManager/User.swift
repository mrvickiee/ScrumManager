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
    var expertises = ""
    var project: String = ""
    var role: String = ""
    
    init(email: String, name: String, authKey: String, role: String) {
        self.email = email
        self.name = name
        self.authKey = authKey
        self.role = role
        
    }
    
    class func userWithEmail(email: String) -> User? {
        let database = try! DatabaseManager()
        let user = database.executeFetchRequest(User.self, predicate: ["email": email]).first
        return user
    }
  
    convenience init(dictionary: [String: Any]) {
        
        let email = dictionary["email"] as! String
        
        let name = dictionary["name"] as! String
        
        let authKey = dictionary["authKey"] as! String
        
        let pictureURL = dictionary["profilePicURL"] as? String ?? ""
        
        // Need further display to modify it
        let roleTemp = dictionary["role"] as? NSInteger
        var role = ""
        // roleTemp: 0 = Scrum Master. 1 = Scrum Member, 2: PO
        if roleTemp == 0 {
            role = "Scrum Master"
        }else if roleTemp == 1 {
            role = "Scrum Member"
        }else if roleTemp == 2{
            role = "Product Owner"
        }else{
            role = ""
        }
        let expertisesTemp = dictionary["expertises"] as? JSONArrayType
        var expertises = ""
        let jEncoder = JSONEncoder()
        do{
            var results = try jEncoder.encode(expertisesTemp!)
            // Replace the regex of '[ OR ] OR "' that get from database
            results = results.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            results = results.stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            results = results.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            expertises = results
        }catch{}
        
        let project = dictionary["currentProject"] as? String ?? ""
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        self.init(email: email, name: name, authKey: authKey, role: role)
        
        self.profilePictureURL = pictureURL
        
        self._objectID = id
        
        self.expertises = expertises
        
        self.project = project
        
    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        self.init(dictionary: dictionary)
        
    }
    
    convenience init?(identifier: String) {
        return nil
    }
}

extension User: DBManagedObject {
    
    static var collectionName = "user"
    
    static func create(name: String, email: String, password: String, pictureURL: String, roles: String) throws -> User {
        
        // Check Email uniqueness
        guard User.userWithEmail(email) == nil else {
            throw CreateUserError.EmailExists
        }
        
        guard password.length > 5 else {
            throw CreateUserError.InvalidPassword
        }
        
        let authKey = encodeRawPassword(email, password: password)
        let user = User(email: email, name: name, authKey: authKey, role: roles)
        
        do {
            try DatabaseManager().insertObject(user)
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
