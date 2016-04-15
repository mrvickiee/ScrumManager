//
//  Comment.swift
//  ScrumManager
//
//  Created by Ben Johnson on 15/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

class Comment {
    
    let comment: String
    
    let userID: String // User who made the comment
    
    init(comment: String, user: User) {
        self.comment = comment
        self.userID = user._objectID!
    }
    
}

