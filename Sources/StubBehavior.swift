//
//  StubBehavior.swift
//  CombineBluetoothKit
//
//  Created by Rafał Małczyński on 07/03/2020.
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//

import Foundation

/// Defines stubbing behavior.
public enum StubBehavior {
    
    /// Stubs are not returned.
    case never

    /// Stubs are returned immediatly after request.
    case immediatly
    
    /// Stubs are delayed by provided number of seconds.
    case deferred(seconds: TimeInterval)
    
}
