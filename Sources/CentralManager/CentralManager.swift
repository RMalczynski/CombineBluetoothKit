//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Foundation
import CoreBluetooth
import Combine

public protocol CentralManagerProtocol: Manager {
    
    func scanForPeripherals(withServices services: [CBUUID]?, options: [String: Any]?) -> AnyPublisher<Peripheral, BluetoothError>
    
    func establishConnection(to peripheral: Peripheral, withOptions options: [String: Any]?) -> AnyPublisher<Peripheral, BluetoothError>
    
}

public class CentralManager {
    
    public let manager: CBCentralManager
    
    public var state = Publishers.StateSubject<ManagerState, Never>()
    let delegate: CentralManagerDelegate
    
    private var peripherals = [UUID: Peripheral]()
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
    
    // MARK: - Public methods
    
    public func stopScanning() {
        manager.stopScan()
    }
    
    // MARK: - Private methods
    
    private func subscribeToDelegate() {
        delegate
            .didUpdateState
            .sink { self.state.send($0) }
            .store(in: &cancellables)
        
        delegate
            .didConnectPeripheral
            .sink { [weak self] in self?.peripherals[$0.identifier]?.connectionState.send(true) }
            .store(in: &cancellables)
        
        delegate
            .didDisconnectPeripheral
            .sink { [weak self] in self?.peripherals[$0.identifier]?.connectionState.send(false) }
            .store(in: &cancellables)
    }
    
}

// MARK: - CentralManagerProtocol

extension CentralManager: CentralManagerProtocol {
    
    public func scanForPeripherals(
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
                .tryMap { [weak self] peripheral, advertisementData, rssi in // TODO: use advData and rssi
                    guard let self = self else {
                        throw BluetoothError.deallocated
                    }
                    
                    let scannedPeripheral = Peripheral(with: peripheral, delegate: PeripheralDelegate(), centralManager: self)
                    self.peripherals[peripheral.identifier] = scannedPeripheral
                    return scannedPeripheral
                }
                .mapError { $0 as? BluetoothError ?? BluetoothError.unknown}
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()

        return ensurePoweredOn(for: publisher)
    }
    
}

// MARK: - Peripheral actions

extension CentralManager {
    
    public func establishConnection(
        to peripheral: Peripheral,
        withOptions options: [String: Any]?
    ) -> AnyPublisher<Peripheral, BluetoothError> {
        let publisher = Publishers.BlockPublisher { [weak self] () -> AnyPublisher<Peripheral, BluetoothError> in
            guard let self = self else {
                return Fail(outputType: Peripheral.self, failure: BluetoothError.deallocated).eraseToAnyPublisher()
            }
            
            self.manager.connect(peripheral.peripheral, options: options)
            
            return peripheral
                .connectionState
                .filter { $0 == true }
                .map { _ in
                    peripheral.peripheral.readRSSI()
                    return peripheral
                }
                .mapError { _ in BluetoothError.connectionFailure }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
        
        return ensurePoweredOn(for: publisher)
    }
    
}
