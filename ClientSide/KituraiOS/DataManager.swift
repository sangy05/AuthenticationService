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

import UIKit

class DataManager: NSObject {

  func registerDevice(urlEndPoint:String, deviceID:String, completionHandler: @escaping(_ status:Bool) -> ()) {
    
    let defaultPostData = [
      "serviceType":"authentication",
      "URL":urlEndPoint,
      "deviceID":deviceID,
      "nodesConnected":"0",
      "status":"available"
    ]
    
    let requestUrl:URL =  URL(string: "https://sangy-iosserver-main.mybluemix.net/data/addEntry/device")!
    let config = URLSessionConfiguration.default
    
    let session = URLSession(configuration: config)
    
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    
    do {
      let data = try JSONSerialization.data(withJSONObject: defaultPostData, options: .prettyPrinted)
      request.httpBody = data
    }
    catch{
      completionHandler(false)
    }
    let task = session.dataTask(with: request) { (data, response, error) in
      if(error == nil) {
        completionHandler(true)
      }
      else {
        completionHandler(false)
      }
    }
    task.resume()
  }
  
  func updateDevice(urlEndPoint:String,status:String, deviceID:String, completionHandler: @escaping(_ status:Bool) -> ()) {
    
    let defaultPostData = [
      "serviceType":"authentication",
      "URL":urlEndPoint,
      "deviceID":deviceID,
      "status":status
    ]
    
    let requestUrl:URL =  URL(string: "https://sangy-iosserver-main.mybluemix.net/data/updateDeviceEntry/"+deviceID)!
    let config = URLSessionConfiguration.default
    
    let session = URLSession(configuration: config)
    
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    
    do {
      let data = try JSONSerialization.data(withJSONObject: defaultPostData, options: .prettyPrinted)
      request.httpBody = data
    }
    catch{
      completionHandler(false)
    }
    let task = session.dataTask(with: request) { (data, response, error) in
      if(error == nil) {
        completionHandler(true)
      }
      else {
        completionHandler(false)
      }
    }
    task.resume()
  }
  
  func checkForDeviceEntry(deviceID:String,completionHandler: @escaping(_ status:Bool) -> ()) {
    let requestUrl:URL =  URL(string: "https://sangy-iosserver-main.mybluemix.net/data/checkDevice/"+deviceID)!
    let config = URLSessionConfiguration.default
    
    let session = URLSession(configuration: config)
    
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "GET"
    
    let task = session.dataTask(with: request) { (data, response, error) in
      if(error == nil ) {
        do {
          let resultInJSON = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:String]
          completionHandler((resultInJSON["entryAvailable"] == "true"))
        }
        catch{
          completionHandler(false)
        }

      }
      else {
        completionHandler(false)
      }
    }
    task.resume()

  }
  
}
