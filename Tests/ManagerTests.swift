//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import XCTest
import Combine
@testable import CombineBluetoothKit

final class ManagerTests: XCTestCase {
    
    var cancellables: [AnyCancellable]!
    var sut: ManagerStub!
    
    override func setUp() {
        cancellables = [AnyCancellable]()
        sut = ManagerStub()
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
    }

    func test_stateNotChanged_valuesAreNotEmitted() {
        //Given
        var states = [ManagerState]()
        
        //When
        sut.state
            .sink(receiveValue: { states.append($0) })
            .store(in: &cancellables)
        
        //Then
        XCTAssertEqual(states, [])
    }
    
    func test_stateChangedToPoweredOn_singleValueIsEmitted() {
        //Given
        var states = [ManagerState]()
        
        //When
        sut.state
            .sink(receiveValue: {
                states.append($0)
                
            })
            .store(in: &cancellables)
        
        sut.state.send(.poweredOn)
        
        //Then
        XCTAssertEqual(states, [.poweredOn])
    }
    
    func test_ensurePoweredOn_stateChangedToPoweredOn_errorIsNil() {
        //Given
        var error: BluetoothError? = nil
        
        //When
        sut.ensurePoweredOn(for: Empty(outputType: Void.self, failureType: BluetoothError.self).eraseToAnyPublisher())
            .sink(receiveCompletion: { value in
                if case let .failure(err) = value {
                    error = err
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        sut.state.send(.poweredOn)
        
        //Then
        XCTAssertEqual(error, nil)
    }
    
    func test_ensurePoweredOn_stateChangedToPoweredOff_errorIsOfAppropriateType() {
        //Given
        var error: BluetoothError? = nil
        
        //When
        sut.ensurePoweredOn(for: Empty(outputType: Void.self, failureType: BluetoothError.self).eraseToAnyPublisher())
            .sink(receiveCompletion: { value in
                if case let .failure(err) = value {
                    error = err
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        sut.state.send(.poweredOff)
        
        //Then
        XCTAssertEqual(error, BluetoothError.bluetoothPoweredOff)
    }
    
}
