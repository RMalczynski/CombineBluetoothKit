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
    
    private var cancellables = [AnyCancellable]()
    
    public init(
        centralManager: CBCentralManager,
        managerDelegate: CentralManagerDelegate
    ) {
        self.manager = centralManager
        self.delegate = managerDelegate
        
        self.manager.delegate = self.delegate
        
        subscribeToDelegate()
    }
    
    func scanForPeripherals(
        withServices services: [CBUUID]?,
        options: [String: Any]?
    ) -> AnyPublisher<Peripheral, BluetoothError> {
        let publisher = Publishers.BlockPublisher { [weak self] () -> AnyPublisher<Peripheral, BluetoothError> in
            guard let self = self else {
                return Fail(outputType: Peripheral.self, failure: BluetoothError.deallocated).eraseToAnyPublisher()
            }
            
            self.manager.scanForPeripherals(withServices: services, options: options)
            
            return self.delegate
                .didDiscoverAdvertisementData
                .map { peripheral, advertisementData, rssi in
                    return Peripheral(with: peripheral)
                }
                .mapError { _ in BluetoothError.unknown}
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()

        return ensurePoweredOn(for: publisher)
    }
    
    // MARK: - Private methods
    
    private func subscribeToDelegate() {
        delegate
            .didUpdateState
            .sink { self.state.send($0) }
            .store(in: &cancellables)
    }
    
}
