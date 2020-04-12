//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Foundation
import Combine

/// Type designated for wrapping classes that inherit from `CBManager`
protocol Manager: AnyObject {
    associatedtype ManagerType
    
    /// Object inheriting from `CBManager`
    var manager: ManagerType { get }
    
    /// Current state of `ManagerType`
    var state: PassthroughSubject<ManagerState, Never> { get }
    
}

extension Manager {
    
    /**
     Method which ensures that `state` property of `Manager` is set to `poweredOn` during subscription of `publisher`.
     If not, `BluetoothError` is emitted.
    */
    func ensurePoweredOn<T>(for publisher: AnyPublisher<T, BluetoothError>) -> AnyPublisher<T, BluetoothError> {
        return state
            .tryMap { [weak self] (state) -> ManagerState in
                guard self != nil else {
                    throw BluetoothError.deallocated
                }
                
                if let error = BluetoothError(state: state) {
                    throw error
                }
                
                return state
            }
            .mapError { $0 as? BluetoothError ?? BluetoothError.unknown }
            .flatMap { _ in publisher }
            .eraseToAnyPublisher()
    }
    
}
