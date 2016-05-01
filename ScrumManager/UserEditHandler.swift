//
//  UserEditHandler.swift
//  ScrumManager
//
//  Created by Fagan Ooi on 29/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib

class UserEditHandler: RequestHandler {
    // TODO: Show alert/get login user/what is identitfier needed for update
    func handleRequest(request: WebRequest, response: WebResponse) {
        let user = User.userWithEmail("wko232@gmail.com")
        if request.requestMethod() == "GET"{
            
            let templateURL = request.documentRoot + "/templates/template.mustache"
            let indexURL = request.documentRoot + "/templates/users/edit.mustache"
            var values = [:] as [String: Any]
            
            values["user"] = user?.asDictionary()
            
            let content = parseMustacheFromURL(indexURL, withValues: values)
            let templateContent = ["content": content] as [String: Any]
            
            response.appendBodyString(parseMustacheFromURL(templateURL, withValues: templateContent))
            response.requestCompletedCallback()
        }else{
            if let name = request.param("name"),
                email = request.param("email"),
                expertises = request.param("expertises"),
                password = request.param("password"),
                confirmPassword = request.param("password2"){
//                var profilePic = ""
//                if request.fileUploads.count > 0{
//                    let filePic = request.fileUploads
//                    profilePic = filePic[0].tmpFileName
//
//                }else{
//                    profilePic = (user?.profilePictureURL)!
//                }
                
                if name != user?.name || email != user?.email || expertises != user?.expertises || password != confirmPassword{
                }else{
//                    UserController.update(identifier: "??", request: request, response: response)
                }
            }

        }
    }
    
}