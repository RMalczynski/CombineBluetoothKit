//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Foundation

public enum BluetoothError: Error {
    
    /// Generic error for handling `unknown` cases.
    case unknown
    
    /// Error emitted when publisher turns out to be `nil`.
    case deallocated
    
    // ManagerState
    case bluetoothUnknown
    case bluetoothResetting
    case bluetoothUnsupported
    case bluetoothUnauthorized
    case bluetoothPoweredOff
    
}

// ManagerState
extension BluetoothError {
    
    init?(state: ManagerState) {
        switch state {
        case .unknown:
            self = .bluetoothUnknown
        case .resetting:
            self = .bluetoothResetting
        case .unsupported:
            self = .bluetoothUnsupported
        case .unauthorized:
            self = .bluetoothUnauthorized
        case .poweredOff:
            self = .bluetoothPoweredOff
        default:
            return nil
        }
    }
    
}
