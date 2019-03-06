//
//  DataTaskProtocol.swift
//  TemplateApp
//
//  Created by John Kuang on 2019-03-04.
//  Copyright © 2019 JandJ. All rights reserved.
//

import Foundation

public enum DataTaskState: String {
    case undefined = "Undefined"
    case active = "Active"
    case suspended = "Suspended"
    case cancelled = "Cancelled"
}

public protocol DataTaskProtocol {
    
    var dataTaskState: DataTaskState {get set}
    
}
