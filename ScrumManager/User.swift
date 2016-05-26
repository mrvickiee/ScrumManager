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
    
    var name: String
    
    var expertises = [String]()
    
    var assignedTaskIDs = [String]()
    
    var project: String = "-"
    
    var projectIDs: [String] = []
    
    var role: UserRole = UserRole.TeamMember
    
    var isActive: Bool = true
    
    var username: String!
    
    init(email: String, name: String, authKey: String, role: Int) {
        self.email = email
        self.name = name
        self.authKey = authKey
        self.role = UserRole(rawValue: role)!
    }
    
    class func userWithEmail(email: String) -> User? {
        let database = try! DatabaseManager()
        let user = database.executeFetchRequest(User.self, predicate: ["email": email, "isActive": true]).first
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
                
        let username = dictionary["username"] as? String ?? User.usernameFromName(name)
        
        // Need further display to modify it
        let roleTypeRaw = dictionary["role"] as! Int
    
        let expertises = (dictionary["expertises"] as? JSONArrayType)?.stringArray ?? []
        
        let project = dictionary["currentProject"] as? String ?? ""
        
        let taskIDsArray = (dictionary["assignedTaskIDs"]  as! JSONArrayType).stringArray ?? []
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        let isActive = dictionary["isActive"] as? Bool ?? true
        
        
        self.init(email: email, name: name, authKey: authKey, role: roleTypeRaw)
                
        self._objectID = id
        
        self.expertises = expertises
        
        self.username = username
        
        self.assignedTaskIDs = taskIDsArray
        
        self.projectIDs = (dictionary["projectIDs"]  as? JSONArrayType)?.stringArray ?? []
        
        if project != "" {
            self.project = project
        }
        
        self.isActive = isActive
        
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
    
    static func create(name: String, email: String, password: String, role: UserRole) throws -> User {
        
        // Check Email uniqueness
        guard User.userWithEmail(email) == nil else {
            throw CreateUserError.EmailExists
        }
        
        
        guard password.length > 5 else {
            throw CreateUserError.InvalidPassword
        }
        
        let authKey = encodeRawPassword(email, password: password)
        let user = User(email: email, name: name, authKey: authKey, role: role.rawValue)
        user.username = User.usernameFromName(name)
        do {
            try DatabaseManager.sharedManager.insertObject(user)
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
    
    func addProject(project: Project) {
        
        projectIDs.append(project._objectID!)
        
        DatabaseManager.sharedManager.updateObject(self, updateValues: ["projectIDs": projectIDs])
    }
    
    var projects: [Project] {
        let db = try! DatabaseManager()
        return db.getObjectsWithIDs(Project.self, objectIDs: projectIDs)
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
    
    var viewDictionary: [String: Any] {
        var userDictionary = ["name": name, "pathURL": pathURL] as [String : Any]
        switch(role) {
        case .TeamMember:
            userDictionary["isTeamMember"] = "YES"
        case .ScrumMaster:
            userDictionary["isScrumMaster"] = "YES"
        case .Admin:
            userDictionary["isAdmin"] = "YES"
        case .ProductOwner:
            userDictionary["isProductOwner"] = "YES"
        }
        
         return userDictionary
    }
    
    var isAdmin: Bool {
        return role == .Admin
    }
    
}

extension User: Routable {
    
    var pathURL: String { return "/users/\(username)" }
    
    var editURL: String { return "/users/\(username)/edit" }
    
    var destoryURL: String { return "/users/\(username)/destroy" }

}

