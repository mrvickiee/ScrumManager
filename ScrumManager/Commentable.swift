//
//  Commentable.swift
//  ScrumManager
//
//  Created by Ben Johnson on 4/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib


// Protocol for objects that contain comments from users
protocol Commentable {
    
    var comments: [Comment] {get set}
    
    mutating func addComment(comment: Comment)
}

extension Commentable where Self: DBManagedObject {
    mutating func addComment(comment: Comment) {
        
        comments.append(comment)
        
        // Update comments in database
        let commentsArray = comments.map { (comment) -> [String: Any] in
            return comment.dictionary
        }
        
        //    try! DatabaseManager().updateObject(self, updateValues:["$set": ["comments": commentsArray] as [String: Any]] as [String: Any])
        try! DatabaseManager().updateObject(self, updateValues:["comments": commentsArray] as [String: Any])
        
    }
    
    func loadCommentsFromDictionary(dictionary: [String: Any]) -> [Comment] {
        
        // Load Comments
        
        if let commentsArray = (dictionary["comments"] as? JSONArrayType)?.array {
            
            return commentsArray.map({ (commentDictionary) -> Comment in
                let comment = commentDictionary as! JSONDictionaryType
                return Comment(dictionary: comment.dictionary)
            })
        }
        
        return []
    }
    
    func loadCommentDetailsForMustahce(user:User)->[[String:Any]]{
        
        var commentList : [[String:Any]] = []
        
        var num = 0
        for comment in comments{
            if user.email == comment.user?.email{
                commentList.append(["comment":comment.dictionary, "visibility": "run-in", "commentIndicator": num, "initials": (comment.user?.initials)!, "name": (comment.user?.name)!])
            }else if user.role != .ScrumMaster && user.role != .Admin{
                commentList.append(["comment":comment.dictionary, "visibility": "none", "commentIndicator": num, "initials": (comment.user?.initials)!, "name": (comment.user?.name)!])
            }else{
                commentList.append(["comment":comment.dictionary, "visibility": "run-in","commentIndicator": num, "initials": (comment.user?.initials)!, "name": (comment.user?.name)!])
            }
            num += 1
        }
        
        return commentList

        
    }
}
