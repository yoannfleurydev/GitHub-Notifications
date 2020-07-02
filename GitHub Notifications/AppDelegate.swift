//
//  AppDelegate.swift
//  GitHub Notifications
//
//  Created by Yoann Fleury on 25/06/2020.
//  Copyright © 2020 Yoann Fleury. All rights reserved.
//

import Cocoa
import Defaults
import SwiftUI
import Foundation
import Preferences

extension Preferences.PaneIdentifier {
    static let general = Self("general")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {        
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var firstMenuItem: NSMenuItem?
    
    @IBOutlet private var preferencesWindow: NSWindow!
    
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            GeneralPreferenceViewController(),
        ],
        style: .segmentedControl
    )

    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let menu = menu {
            statusItem.menu = menu
        }

        firstMenuItem?.action = #selector(openGitHub)
        
        update()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(AppDelegate.update), userInfo: nil, repeats: true)
    }

    @IBAction
    func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
        preferencesWindowController.show()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func openGitHub() {
        NSWorkspace.shared.open(NSURL(string: "https://github.com/notifications")! as URL)
    }
    
    @objc func update() {
        let username = Defaults[.username]
        let password = Defaults[.password]
        
        let basicAuth = "\(username):\(password)".data(using: .utf8)
        
        if let base64Encoded = basicAuth?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            let headers = ["authorization": "Basic \(base64Encoded)"]

             let request = NSMutableURLRequest(
                 url: NSURL(string: "https://api.github.com/notifications")! as URL,
                 cachePolicy: .reloadIgnoringLocalCacheData,
                 timeoutInterval: 10.0
             )
             
             request.httpMethod = "GET"
             request.allHTTPHeaderFields = headers

             let session = URLSession.shared
             let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                 if error != nil {
                     print(error!)
                 } else {
                     guard let responseData = data else {
                       print("Error: did not receive data")
                       return
                     }
                     
                     do {
                       guard let notifications = try JSONSerialization.jsonObject(with: responseData, options: [])
                         as? [Any] else {
                           print("error trying to convert data to JSON 1")
                           return
                        }
                        
                        self.firstMenuItem?.title = "\(notifications.count) notification\(notifications.count > 1 ? "s" : "")"
                        
                        let doesNotificationExist = notifications.count >= 1
                            
                        let itemImage = NSImage(named: doesNotificationExist ? "StatusItemImageNotification" : "StatusItemImage")
                        itemImage?.isTemplate = false
                            
                        DispatchQueue.main.async {
                           self.statusItem.button?.image = itemImage
                        }
                         
                     } catch  {
                       print("error trying to convert data to JSON")
                       return
                     }
                     
                 }
             })

            dataTask.resume()
        }
    }

}

