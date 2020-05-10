//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Foundation
import CoreBluetooth
import Combine

public protocol PeripheralProtocol {
 
    func connectPeripheral(withOptions options: [String: Any]?) -> AnyPublisher<Self, BluetoothError>
    
    func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<Self, BluetoothError>
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<Self, BluetoothError>
    func discoverDescriptors(for characteristic: CBCharacteristic) -> AnyPublisher<Self, BluetoothError>
    
    func readValue(for characteristic: CBCharacteristic) -> AnyPublisher<Self, BluetoothError>
    
}

public final class Peripheral {
    
    public let peripheral: CBPeripheral
    private let delegate: PeripheralDelegate
    private let centralManager: CentralManager
    
    let connectionState = CurrentValueSubject<Bool, Never>(false)
    let rssi = CurrentValueSubject<Int, Never>(0)
    
    private var cancellables = [AnyCancellable]()
    
    init(
        with peripheral: CBPeripheral,
        delegate: PeripheralDelegate,
        centralManager: CentralManager
    ) {
        self.peripheral = peripheral
        self.delegate = delegate
        self.centralManager = centralManager
        
        self.peripheral.delegate = self.delegate
        
        subscribeToDelegate()
    }
    
    // MARK: - Private methods
    
    private func subscribeToDelegate() {
        delegate.didReadRSSI
            .sink { [weak self] peripheral, RSSI in
                guard peripheral.identifier == self?.peripheral.identifier else {
                    return
                }
                self?.rssi.send(Int(truncating: RSSI))
            }
            .store(in: &cancellables)
    }
    
}

extension Peripheral: PeripheralProtocol {
    
    // MARK: - Connection
    
    public func connectPeripheral(withOptions options: [String: Any]? = nil) -> AnyPublisher<Peripheral, BluetoothError> {
        centralManager.establishConnection(to: self, withOptions: options)
    }

    public func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<Peripheral, BluetoothError> {
        let publisher = Publishers.BlockPublisher { [weak self] () -> AnyPublisher<Peripheral, BluetoothError> in
            guard let self = self else {
                return Fail(outputType: Peripheral.self, failure: BluetoothError.deallocated).eraseToAnyPublisher()
            }
                
            self.peripheral.discoverServices(serviceUUIDs)
            
            return self.delegate
                .didDiscoverServices
                .tryFilter { [weak self] in
                    guard let self = self else { throw BluetoothError.deallocated }
                    return $0.identifier == self.peripheral.identifier
                }
                .map { _ in self }
                .mapError { $0 as? BluetoothError ?? BluetoothError.unknown }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
        
        return centralManager
            .ensurePoweredOn(for: publisher)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Discovery

    public func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<Peripheral, BluetoothError> {
        let publisher = Publishers.BlockPublisher { [weak self] () -> AnyPublisher<Peripheral, BluetoothError> in
            guard let self = self else {
                return Fail(outputType: Peripheral.self, failure: BluetoothError.deallocated).eraseToAnyPublisher()
            }
                
            self.peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
            
            return self.delegate
                .didDiscoverCharacteristics
                .tryFilter { [weak self] in
                    guard let self = self else { throw BluetoothError.deallocated }
                    return $0.0.identifier == self.peripheral.identifier
                }
                .map { _ in self }
                .mapError { $0 as? BluetoothError ?? BluetoothError.unknown }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
        
        return centralManager
            .ensurePoweredOn(for: publisher)
            .eraseToAnyPublisher()
    }
    
    public func discoverDescriptors(for characteristic: CBCharacteristic) -> AnyPublisher<Peripheral, BluetoothError> {
        let publisher = Publishers.BlockPublisher { [weak self] () -> AnyPublisher<Peripheral, BluetoothError> in
            guard let self = self else {
                return Fail(outputType: Peripheral.self, failure: BluetoothError.deallocated).eraseToAnyPublisher()
            }
                
            self.peripheral.discoverDescriptors(for: characteristic)
            
            return self.delegate
                .didDiscoverDescriptors
                .tryFilter { [weak self] in
                    guard let self = self else { throw BluetoothError.deallocated }
                    return $0.0.identifier == self.peripheral.identifier
                }
                .map { _ in self }
                .mapError { $0 as? BluetoothError ?? BluetoothError.unknown }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
        
        return centralManager
            .ensurePoweredOn(for: publisher)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Managing values
    
    public func readValue(for characteristic: CBCharacteristic) -> AnyPublisher<Peripheral, BluetoothError> {
        let publisher = Publishers.BlockPublisher { [weak self] () -> AnyPublisher<Peripheral, BluetoothError> in
            guard let self = self else {
                return Fail(outputType: Peripheral.self, failure: BluetoothError.deallocated).eraseToAnyPublisher()
            }
                
            self.peripheral.readValue(for: characteristic)
            
            return self.delegate
                .didUpdateValue
                .tryFilter { [weak self] in
                    guard let self = self else { throw BluetoothError.deallocated }
                    return $0.0.identifier == self.peripheral.identifier
                }
                .map { _ in self }
                .mapError { $0 as? BluetoothError ?? BluetoothError.unknown }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
        
        return centralManager
            .ensurePoweredOn(for: publisher)
            .eraseToAnyPublisher()
    }
    
}
