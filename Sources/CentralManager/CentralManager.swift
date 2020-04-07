//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Foundation
import CoreBluetooth
import Combine

protocol CentralManagerProtocol: Manager {
    
    func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]?) -> AnyPublisher<Peripheral, BluetoothError>
    
}

public class CentralManager: CentralManagerProtocol {
    
    let manager: CBCentralManager
    
    public var state = PassthroughSubject<ManagerState, Never>()
    private let delegate: CentralManagerDelegate
    
    init(
        centralManager: CBCentralManager,
        managerDelegate: CentralManagerDelegate
    ) {
        self.manager = centralManager
        self.delegate = managerDelegate
        
        self.manager.delegate = self.delegate
    }
    
    func scanForPeripherals(
        withServices services: [CBUUID]?,
        options: [String: Any]?
    ) -> AnyPublisher<Peripheral, BluetoothError> {
        manager.scanForPeripherals(withServices: services, options: options)
        
        let ensurer = ensurePoweredOn()
            .compactMap { $0 as? Peripheral }
        
        return delegate.didDiscoverAdvertisementData
            .map { peripheral, advertisementData, rssi in // TODO: Use advData and rssi
                return Peripheral(with: peripheral)
            }
            .mapError { _ in BluetoothError.unknown}
            .merge(with: ensurer)
            .eraseToAnyPublisher()
    }
    
}
