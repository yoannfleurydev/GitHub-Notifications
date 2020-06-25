//
//  GeneralPreferenceViewController.swift
//  GitHub Notifications
//
//  Created by Yoann Fleury on 29/06/2020.
//  Copyright © 2020 Yoann Fleury. All rights reserved.
//

import Cocoa
import Defaults
import Preferences


final class GeneralPreferenceViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = Preferences.PaneIdentifier.general
    let preferencePaneTitle = "General"

    override var nibName: NSNib.Name? { "GeneralPreferenceViewController" }
    
    @IBOutlet private var usernameTextField: NSTextField!
    @IBOutlet private var passwordTextField: NSTextField!
    @IBOutlet private var saveButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField?.placeholderString = "username"
        usernameTextField?.stringValue = Defaults[.username]
        passwordTextField?.placeholderString = "********"
        passwordTextField?.stringValue = Defaults[.password]
        
        saveButton?.action = #selector(save)
    }
    
    @objc func save() {
        // Save input values in User Defaults
        Defaults[.username] = usernameTextField!.stringValue
        Defaults[.password] = passwordTextField!.stringValue
        
        // Close the window when done
        self.view.window?.windowController?.close()
    }
}
