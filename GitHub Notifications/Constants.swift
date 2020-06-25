//
//  Constants.swift
//  GitHub Notifications
//
//  Created by Yoann Fleury on 30/06/2020.
//  Copyright © 2020 Yoann Fleury. All rights reserved.
//

import Cocoa
import Defaults

extension Defaults.Keys {
    static let username = Key<String>("username", default: "")
    static let password = Key<String>("password", default: "")
}
