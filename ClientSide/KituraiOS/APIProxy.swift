/*
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Kitura
import HeliumLogger
import LoggerAPI
import ESCustomMiddleware
import Foundation

class APIManager{
  
  var delegate:MainControllerDelegate?
  var mainRouter:Router?
  init(with mainRouter:Router?) {
    guard let router = mainRouter else{
      return
    }
    self.mainRouter = router
  }
  
  func addServices(){
    //DB Operation
    let myMiddleware = CustomMiddleware()
    addCrudServcies(dbMiddleware:myMiddleware)
    
  }
  
  //Add DB CRUD Services
  func addCrudServcies(dbMiddleware:CustomMiddleware){
    //GET
    self.mainRouter!.all("/data/*",middleware: dbMiddleware)
    self.mainRouter!.get("/data/validate/:userName/:password", handler:self.notifyRequest,dbMiddleware.validate,self.handleApiHits)
    
    //Test API
    mainRouter!.get("/data/test", handler:self.notifyRequest,dbMiddleware.testConnection,self.handleApiHits);
  }
  
 func handleApiHits(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
     DispatchQueue.main.async {
      self.delegate!.didHitApi()
     }
     next()
  }
  
  func notifyRequest(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    DispatchQueue.main.async {
      self.delegate!.didReceiveRequest(info: request.originalURL)
    }
    next()
  }
}
