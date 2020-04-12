//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Foundation
import CoreBluetooth
import Combine

public final class CentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    
    let didConnectPeripheral = PassthroughSubject<CBPeripheral, Never>()
    let didDisconnectPeripheral = PassthroughSubject<CBPeripheral, Error>()
    let didFailToConnect = PassthroughSubject<CBPeripheral, Error>()
    let connectionEventDidOccur = PassthroughSubject<(CBConnectionEvent, CBPeripheral), Never>()
    let didDiscoverAdvertisementData = PassthroughSubject<(CBPeripheral, [String: Any], NSNumber), Never>()
    let didUpdateState = PassthroughSubject<ManagerState, Never>()
    let willRestoreState = PassthroughSubject<[String: Any], Never>()
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        didConnectPeripheral.send(peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        didDiscoverAdvertisementData.send((peripheral, advertisementData, RSSI))
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard let state = ManagerState(rawValue: central.state.rawValue) else { return }
        didUpdateState.send(state)
    }
    
    public func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        
    }
    
}
