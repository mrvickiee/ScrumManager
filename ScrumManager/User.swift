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

enum UserRole: Int {
    case TeamMember     //0
    case ScrumMaster    //1
    case ProductOwner   //2
    case Admin          //3
    
  
}

final class User: Object {
    
    var email: String
    
    var authKey: String
    
    var profilePictureURL: String = ""
    
    var name: String
    
    var expertises = [String]()
    
    var assignedTaskIDs = [String]()
    
    var project: String = "-"
    
    var role: UserRole = UserRole.TeamMember
    
    var username: String!
    
    init(email: String, name: String, authKey: String, role: Int, profilePictureURL: String) {
        self.email = email
        self.name = name
        self.authKey = authKey
        self.role = UserRole(rawValue: role)!
        self.profilePictureURL = profilePictureURL
    }
    
    class func userWithEmail(email: String) -> User? {
        let database = try! DatabaseManager()
        let user = database.executeFetchRequest(User.self, predicate: ["email": email]).first
        return user
    }
    
    class func userWithUsername(username: String) -> User? {
        let database = try! DatabaseManager()
        let user = database.executeFetchRequest(User.self, predicate: ["username": username]).first
        return user
    }
    
    class func userWithRole(role: UserRole) -> [User] {
        let database = try! DatabaseManager()
        let users = database.executeFetchRequest(User.self, predicate: ["role": role.rawValue])
        return users
    }
  
    convenience init(dictionary: [String: Any]) {
        
        let email = dictionary["email"] as! String
        
        let name = dictionary["name"] as! String
        
        let authKey = dictionary["authKey"] as! String
        
        let pictureURL = dictionary["profilePictureURL"] as? String ?? ""
        
        let username = dictionary["username"] as? String ?? User.usernameFromName(name)
        
        // Need further display to modify it
        let roleTypeRaw = dictionary["role"] as! Int
    
        let expertises = (dictionary["expertises"] as? JSONArrayType)?.stringArray ?? []
        
        let project = dictionary["currentProject"] as? String ?? ""
        
        let taskIDsArray = (dictionary["assignedTaskIDs"]  as! JSONArrayType).stringArray ?? []
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        self.init(email: email, name: name, authKey: authKey, role: roleTypeRaw, profilePictureURL: pictureURL)
                
        self._objectID = id
        
        self.expertises = expertises
        
        self.username = username
        
        self.assignedTaskIDs = taskIDsArray
        
        if project != "" {
            self.project = project
        }
        
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
    
    static func usernameFromName(name: String) -> String {
        
        let username = name.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: ".")
        var userWithExistingNameCount = 1
        
        guard let _ = User.userWithUsername(username) else  {
            return username
        }
        
        while let _ = User.userWithUsername("\(username)\(userWithExistingNameCount)")  {
            userWithExistingNameCount += 1
        }
        
        return "\(username)\(userWithExistingNameCount)"
        
    }
    
    static func create(name: String, email: String, password: String, pictureURL: String, role: Int) throws -> User {
        
        // Check Email uniqueness
        guard User.userWithEmail(email) == nil else {
            throw CreateUserError.EmailExists
        }
        
        
        guard password.length > 5 else {
            throw CreateUserError.InvalidPassword
        }
        
        let authKey = encodeRawPassword(email, password: password)
        let user = User(email: email, name: name, authKey: authKey, role: role, profilePictureURL: pictureURL)
        user.username = User.usernameFromName(name)
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

extension User {
    var tasks: [Task] {
        let db = try! DatabaseManager()
        return db.getObjectsWithIDs(Task.self, objectIDs: assignedTaskIDs)
    }
    
    func addTask(task: Task) {
        assignedTaskIDs.append(task._objectID!)
    }
    
    func removeTask(task: Task) {
        assignedTaskIDs.removeObject(task._objectID!)
    }
    
    var initials: String {
        // Split name into first and last
        let names = name.componentsSeparatedByString(" ")
        var initialsRaw = ""
        for name in names {
            initialsRaw += name[0]
        }
        
        return initialsRaw
    }
    
    
    
}

extension User: Routable {
    
    var pathURL: String { return "/users/\(username)" }
    
    var editURL: String { return "/users/\(username)/edit" }
    
    var destoryURL: String { return "/users/\(username)/destroy" }

}

