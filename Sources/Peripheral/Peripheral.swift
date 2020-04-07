//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Foundation
import CoreBluetooth

public class Peripheral {
    
    let peripheral: CBPeripheral
    
    init(with peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
}
