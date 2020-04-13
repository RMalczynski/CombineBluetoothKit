//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Foundation
import CoreBluetooth
import Combine

public final class PeripheralDelegate: NSObject, CBPeripheralDelegate {
    
    let didDiscoverServices = PassthroughSubject<CBPeripheral, Error>()
    let didDiscoverCharacteristics = PassthroughSubject<(CBPeripheral, for: CBService), Error>()
    let didDiscoverDescriptors = PassthroughSubject<(CBPeripheral, for: CBCharacteristic), Error>()
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        didDiscoverServices.send(peripheral)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        didDiscoverCharacteristics.send((peripheral, for: service))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        didDiscoverDescriptors.send((peripheral, for: characteristic))
    }
    
}
