//
//  Comment.swift
//  ScrumManager
//
//  Created by Ben Johnson on 15/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

// Protocol for objects that contain comments from users
protocol Commentable {
    
    var comments: [Comment] {get set}
    
    mutating func addComment(comment: Comment)
}

protocol DictionarySerializable {
    
    init(dictionary: [String: Any]) 
    
}

extension Commentable {
    mutating func addComment(comment: Comment) {
        
        comments.append(comment)
        
        // Save comments to database 
        
    }
}


final class Comment: Object, DictionarySerializable {
    
    let comment: String
    
    private let userID: String // User who made the comment
    
    lazy var user: User? = User(identifier: self.userID)
    
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
    
}



