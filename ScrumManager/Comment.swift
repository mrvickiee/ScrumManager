 //
//  Comment.swift
//  ScrumManager
//
//  Created by Ben Johnson on 15/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib



protocol DictionarySerializable {
    
    init(dictionary: [String: Any])
}
 
 
 protocol CustomDictionaryConvertible {
    var dictionary: [String: Any] { get }
 }



final class Comment: Object, DictionarySerializable, CustomDictionaryConvertible {
    
    let comment: String
    
    private let userID: String // User who made the comment
    
    lazy var user: User? = try! DatabaseManager().getObjectWithID(User.self, objectID: self.userID)
    
    init(comment: String, userID: String) {
        self.comment = comment
        self.userID = userID
    }
    
   convenience init(comment: String, user: User) {
        self.init(comment: comment, userID: user._objectID!)
    }
    
    convenience init(dictionary: [String: Any]) {
        
        let comment = dictionary["comment"] as! String
        let userID = dictionary["userID"] as! String
        
        self.init(comment: comment, userID: userID)
    }
    
    var dictionary: [String : Any] {
        var dict = ["comment": comment, "userID": userID] as [String: Any]
        if let user = user {
            dict["user"] = user.dictionary
        }
        
        return dict
    }
    
}



