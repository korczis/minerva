//
//  Logger.swift
//  Minerva Eye
//
//  Created by Tomas Korcak on 5/8/20.
//  Copyright © 2020 Tomas Korcak. All rights reserved.
//

import Foundation

class Logger {
    private static var DefaultNotificationCenter = NotificationCenter.default
    static let NotificationName = Notification.Name("LogMessage")
    
    static func log(msg: String) -> Void {
        // Logger.log(msg: msg)
        
        DispatchQueue.main.async {
            Logger.DefaultNotificationCenter.post(name: Logger.NotificationName, object: msg)
        }
    }
    
    static func publisher() -> NotificationCenter.Publisher {
        return Logger.DefaultNotificationCenter
            .publisher(for: Logger.NotificationName)
    }
}
