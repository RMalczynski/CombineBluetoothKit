//
//  TimeoutStrategy.swift
//  CombineBluetoothKit
//
//  Created by Rafał Małczyński on 08/03/2020.
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//

import Foundation

/// Defines strategy for timing out the peripheral connection
public enum TimeoutStrategy {
    
    /// No timeout, default `CoreBluetooth` behaviour
    case none
    
    /// Connection attempt times out after given time
    case seconds(TimeInterval)
    
}
