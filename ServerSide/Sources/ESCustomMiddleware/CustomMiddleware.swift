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
import CouchDB
import SwiftyJSON
import Foundation

public class CustomMiddleware: RouterMiddleware {
  
  typealias JSONDictionary = [String: Any]
  var userDataHandler:IRUDataHandler?
  
  //MARK: Manadatory Default Methods :
  // to make this class to be initialized outside the module
  public init() {
    self.userDataHandler = IRUDataHandler(dBName: nil)
  }
  
  // Default protocol method to be added to use any custom middleware
  public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    next()
  }
  
  //MARK: Custom Handler Methods
  public func testConnection(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    do{
      try response.send("Test API").end()
    }
    catch{
      
    }
    next()
  }
  
  //MARK: Cloudant DB Handler Methods
  
  public func validate(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    let user = request.parameters["userName"] ?? "user"
    let pwd = request.parameters["password"] ?? "user"
    
    self.userDataHandler!.readAllData(onFetchSucess: {(result: JSON,error: Error?) in
      do{
        var resultToResponse:JSON?
        resultToResponse = self.validateForUser(username:user,password:pwd,fromResult: result)
        try response.send(resultToResponse!.description).end()
      }
      catch  {
        Log.info("Error Sending Response")
      }
    })
    next()
  }
  
  // Core functions
  func validateForUser(username:String,password:String,fromResult dbResult:JSON) -> JSON {
    for eachItem:JSON in dbResult["rows"].arrayValue {
      let document = JSON(eachItem["doc"].dictionaryValue)
      if(document["userName"].stringValue == username && document["password"].stringValue == password){
        return JSON(["result":"success"])
      }
    }
    return JSON(["result":"failure"])
  }
  
}

