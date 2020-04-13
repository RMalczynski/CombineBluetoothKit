//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import CoreBluetooth
import Combine
@testable import CombineBluetoothKit

class ManagerStub: Manager {
    
    let manager = CBCentralManager()
    let state = Publishers.StateSubject<ManagerState, Never>()
    
}
