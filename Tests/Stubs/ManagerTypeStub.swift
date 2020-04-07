//
//  ManagerTypeStub.swift
//  CombineBluetoothKitTests
//
//  Created by Rafał Małczyński on 09/03/2020.
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//

import CoreBluetooth
import Combine
@testable import CombineBluetoothKit

class ManagerStub: Manager {
    
    var manager = CBCentralManager()
    
    var state = PassthroughSubject<ManagerState, Never>()
    
}
