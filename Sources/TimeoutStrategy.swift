//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Foundation

/// Defines strategy for timing out the peripheral connection
public enum TimeoutStrategy {
    
    /// No timeout, default `CoreBluetooth` behaviour
    case none
    
    /// Connection attempt times out after given time
    case seconds(TimeInterval)
    
}
