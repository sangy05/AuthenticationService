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
import Kitura
import HeliumLogger
import CloudFoundryEnv
import LoggerAPI
import Configuration


protocol MainControllerDelegate {
  func didHitApi()
    func didReceiveRequest(info:String)
}

class KituraTableViewController:UIViewController, MainControllerDelegate {
  
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var logLabel: UILabel!
  
  @IBOutlet weak var apiHitsValue: UILabel!
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var ipAddressLabel: UILabel!
  @IBOutlet weak var statusValueLabel: UILabel!
  
  var router:Router?
  var serverStarted = false
  private var queue = DispatchQueue(label: "server_thread")
  private var bxqueue = DispatchQueue(label: "bluemix_thread")
  
  let deviceID = (UIDevice.current.identifierForVendor?.description ?? "dummy") + UIDevice.current.name;
  
  override func viewDidLoad() {
    self.registerButton.isHidden = true
    self.serverStarted = false
    self.startStopButton.backgroundColor = Colors.uiColor(fromHexadecimalString: "#339933")
    self.startStopButton.setTitle("Start", for: .normal)
    self.statusValueLabel.text = "Initialized"
    
    let manager = DataManager()
    
    manager.checkForDeviceEntry(deviceID:self.deviceID) { (status) in
      if(!status){
        DispatchQueue.main.async {
          self.registerButton.isHidden = false
        }
      }
    }
  }
  
  @IBAction func startStopButtonTapped(_ sender: Any) {
    if(serverStarted){
      Kitura.stop()
      self.serverStarted = false
      self.statusValueLabel.text = "Stopped"
      self.ipAddressLabel.text = ""
      self.apiHitsValue.text = "0";
      self.startStopButton.backgroundColor = Colors.uiColor(fromHexadecimalString: "#339933")
      self.startStopButton.setTitle("Start", for: .normal)
      self.logLabel.text = ""
      
    }
    else {
      self.indicator.startAnimating()
      self.queue.async {
        self.startServer()
      }
    }
  }
  
  func serverStartedStatusDidChange() {
    self.statusValueLabel.text = "Started"
    self.indicator.stopAnimating()
    self.serverStarted = true
    self.startStopButton.backgroundColor = UIColor.red
    self.startStopButton.setTitle("Stop", for: .normal)
    
    self.bxqueue.async {
      let dataManager = DataManager()
      dataManager.updateDevice(urlEndPoint: self.ipAddressLabel.text!, status: "available", deviceID: self.deviceID, completionHandler: { (status) in
        
        DispatchQueue.main.async {
          if(status){
             self.logLabel.text = "Main Server Updated.."
          }
          else{
            self.logLabel.text = "Main Server Updation Failed.."
          }
        }
        
      })
    }
    
  }
  
  @IBAction func registerButtonTapped(_ sender: Any) {
    self.indicator.startAnimating()
    let dataManager = DataManager()
    dataManager.registerDevice(urlEndPoint: self.ipAddressLabel.text!, deviceID:self.deviceID) { (status) in
      
      DispatchQueue.main.async {
        if(status){
          self.logLabel.text = "Server Registerted Successfully. Start using with given IP"
          self.registerButton.isHidden = true
          self.indicator.stopAnimating()
        }
        else{
          self.statusValueLabel.text = "Registartion Failed"
        }
      }
      
    }

  }
  
  func didReceiveRequest(info:String) {
    DispatchQueue.main.async {
      self.logLabel.text = "Request Recieved on :"+info
    }
    
  }
  
  func didHitApi() {
    let existingValue = Int((self.apiHitsValue.text ?? "0")) ?? 0
    self.apiHitsValue.text = (existingValue + 1).description;
  }

  func startServer(){
    self.router = Router()
    guard let router = self.router else {
      return
    }
    //Manage All the API services
    let apiManager = APIManager(with:router)
    apiManager.delegate = self
    apiManager.addServices()
    
    //start the server with port & url linked to router
    //HeliumLogger.use()
    do {
      let configManager = ConfigurationManager()
      configManager.load(.environmentVariables)
      let port: Int = configManager.port
      
      // Add an HTTP server and connect it to the router
      Kitura.addHTTPServer(onPort: port, with: router)
      let networkData = IPUtility.getMyIP()
      if let ip = networkData.ip {
        let url = IPUtility.getUrl(ip: ip, port: "\(port)")
        print("URL: \(url)")
        DispatchQueue.main.async {
          self.serverStartedStatusDidChange()
          self.ipAddressLabel.text = url
        }
        
      }
      print("Server is starting on \(configManager.url)")
      Kitura.run()
      
    }
  }
  
  
}
