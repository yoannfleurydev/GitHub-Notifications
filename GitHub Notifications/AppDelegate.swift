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
        setStatusItemImage()
        
        update()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Timer.scheduledTimer(
            timeInterval: 60,
            target: self,
            selector: #selector(AppDelegate.update),
            userInfo: nil,
            repeats: true
        )
    }

    @IBAction
    func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
        preferencesWindowController.show()
    }

    @objc func openGitHub() {
        NSWorkspace.shared.open(NSURL(string: "https://github.com/notifications")! as URL)
    }
    
    @objc func openGitHubURL(sender: MenuItemOpenURL) {
        if let url = sender.url {
            NSWorkspace.shared.open(NSURL(string: url)! as URL)
        }
    }
    
    @objc func update() {
        let password = Defaults[.password]
    
        let headers = ["authorization": "token \(password)"]

        let notificationsRequest = NSMutableURLRequest(
            url: NSURL(string: "https://api.github.com/notifications")! as URL,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 10.0
        )

        notificationsRequest.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let getNotificationsTask = session.dataTask(
            with: notificationsRequest as URLRequest,
            completionHandler: {
                (notificationsData, response, error) -> Void in
                    if error != nil {
                        print(error!)
                    } else {
                        guard let responseData = notificationsData else {
                            print("Error: did not receive data")
                            return
                        }

                        let decoder = JSONDecoder()
                        do {
                            let notifications = try decoder.decode([NotificationJSON].self, from: responseData)
                            
                            // Remove previous items.
                            self.menu?.items.compactMap {
                                $0 as? MenuItemOpenURL
                            }.forEach { item in
                                self.menu?.removeItem(item)
                            }
                            
                            // Add new items
                            for (index, notification) in notifications.enumerated() {
                                let notificationMenuItem = MenuItemOpenURL(
                                    title: notification.subject.title,
                                    action: #selector(self.openGitHubURL(sender:)),
                                    keyEquivalent: ""
                                )
                                
                                let notificationURLRequest = NSMutableURLRequest(
                                    url: NSURL(string: notification.subject.url)! as URL,
                                    cachePolicy: .reloadIgnoringLocalCacheData,
                                    timeoutInterval: 10.0
                                )
                                
                                let getNotificationURLTask = session.dataTask(
                                    with: notificationURLRequest as URLRequest,
                                    completionHandler: {
                                        (data, response, error) -> Void in
                                        if error != nil {
                                            print(error!)
                                        } else {
                                            guard let responseData = data else {
                                                print("Error: did not receive data")
                                                return
                                            }
                                            
                                            do {
                                                let notificationContent = try decoder.decode(NotificationContentJSON.self, from: responseData)
                                                notificationMenuItem.url = notificationContent.html_url
                                            } catch  {
                                              print("error trying to convert data to JSON")
                                              return
                                            }
                                        }
                                    }
                                )
                                getNotificationURLTask.resume()
                                
                                notificationMenuItem.toolTip = notification.repository.full_name

                                self.menu?.insertItem(notificationMenuItem, at: index + 1)
                                
                                if index == 1 {
                                    break
                                }
                            }

                            self.firstMenuItem?.title = "\(notifications.count) notification\(notifications.count > 1 ? "s" : "")"
                            
                            let doesNotificationExist = notifications.count >= 1
                                
                            DispatchQueue.main.async {
                                self.setStatusItemImage(
                                    named: doesNotificationExist
                                        ? "StatusItemImageNotification"
                                        : "StatusItemImage"
                                )
                            }
                         } catch  {
                           print("error trying to convert data to JSON")
                           return
                         }
                     }
         })

        getNotificationsTask.resume()
    }

    func setStatusItemImage(named: String = "StatusItemImage") {
        let itemImage = NSImage(named: named)
        itemImage?.isTemplate = false
        statusItem.button?.image = itemImage
    }
}

