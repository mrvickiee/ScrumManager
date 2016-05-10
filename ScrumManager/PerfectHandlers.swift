//
//  PerfectHandlers.swift
//  ScrumManager
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib
import MongoDB

// This is the function which all Perfect Server modules must expose.
// The system will load the module and call this function.
// In here, register any handlers or perform any one-time tasks.
let AUTH_REALM = "ScrumManager"

public func PerfectServerModuleInit() {
    
    // Register our handler class with the PageHandlerRegistry.
    // The name "TTHandler", which we supply here, is used within a mustache template to associate the template with the handler.
    
    
    
    // Do routing
    Routing.Handler.registerGlobally()
    
    Routing.addRoutesForRESTController(UserController())
    Routing.addRoutesForRESTController(ProductBacklogController())
    Routing.addRoutesForRESTController(ProjectController())
   // Routing.addRoutesForRESTController(SprintController())
    
    Routing.Routes["GET", "/"] = { _ in return ProductBacklogController() }
   
    // Add access to stylesheets
    Routing.Routes["GET", "/stylesheets/*"] = {_  in StaticFileHandler() }
    
    Routing.Routes["/login"] = { _ in LoginHandler() }
    Routing.Routes["/logout"] = { _ in LogoutHandler() }
   // Routing.Routes["/test"] = { _ in TestHandler() }
    
    
    Routing.Routes["GET", "/resources/*/*"] = {_  in StaticFileHandler() }
    
    print("\(Routing.Routes.description)")
    
    
}
