//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Foundation
import Combine

/// Type designated for wrapping classes that inherit from `CBManager`
public protocol ManagerType: AnyObject {
    associatedtype Manager
    
    /// Object inheriting from `CBManager`
    var manager: Manager { get }
    
    /// Current state of `Manager`
    var state: PassthroughSubject<ManagerState, Never> { get }
    
}

public extension ManagerType {
    
    /**
     Method which ensures that `state` property of `ManagerType` is set to `poweredOn` during subscription.
     If not, `BluetoothError` is emmitted.
    */
    func ensurePoweredOn() -> AnyPublisher<Never, BluetoothError> {
        Deferred {
            self.state
                .tryMap { [weak self] (state) -> ManagerState in
                    guard self != nil else {
                        throw BluetoothError.deallocated
                    }
                    return state
                }
                .filter { $0 != .poweredOn }
                .tryMap { state -> Never in throw BluetoothError(state: state)! }
                .mapError { $0 as? BluetoothError ?? BluetoothError.unknown }
        }.eraseToAnyPublisher()
    }
    
}
