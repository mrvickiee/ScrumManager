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

extension Commentable {
    mutating func addComment(comment: Comment) {
        
        comments.append(comment)
    }
}


class Comment: Object {
    
    let comment: String
    
    let userID: String // User who made the comment
    
    init(comment: String, user: User) {
        self.comment = comment
        self.userID = user._objectID!
    }
    
}

