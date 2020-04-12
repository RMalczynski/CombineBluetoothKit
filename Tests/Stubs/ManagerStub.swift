//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import CoreBluetooth
import Combine
@testable import CombineBluetoothKit

class ManagerStub: Manager {
    
    var manager = CBCentralManager()
    
    var state = PassthroughSubject<ManagerState, Never>()
    
}
