//
//  GitHubService.swift
//  GitHub Notifications
//
//  Created by Yoann Fleury on 28/06/2020.
//  Copyright © 2020 Yoann Fleury. All rights reserved.
//

import Cocoa
import Foundation

class GitHubService {
    @objc func update(firstMenuItem: NSMenuItem) {
        let headers = ["authorization": "Basic eW9hbm5mbGV1cnlkZXY6MTc3MWRmNDNhOTI5YTQ5ZTBhZjNjNDlhMGFjYTY5ZjYzOWIwNDY4OA=="]

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
                
                let string1 = String(data: responseData, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                print(string1)
                
                do {
                  guard let notifications = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [Any] else {
                      print("error trying to convert data to JSON 1")
                      return
                  }
                    print("The notifications length are: " + String(notifications.count))
                    firstMenuItem.title = "\(notifications.count) notification\(notifications.count > 1 ? "s" : "")"
                    
                } catch  {
                  print("error trying to convert data to JSON")
                  return
                }
                
            }
        })

        dataTask.resume()
    }
}
