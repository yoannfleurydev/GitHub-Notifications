//
//  NotificationDTO.swift
//  GitHub Notifications
//
//  Created by Yoann Fleury on 14/07/2020.
//  Copyright © 2020 Yoann Fleury. All rights reserved.
//

import Foundation

struct SubjectJSON: Decodable {
    var title: String
    var url: String
}

struct RepositoryJSON: Decodable {
    var full_name: String
}

// Root representation of a notification.
struct NotificationJSON: Decodable {
    var subject: SubjectJSON
    var repository: RepositoryJSON
}

struct NotificationContentJSON: Decodable {
    var html_url: String
}
