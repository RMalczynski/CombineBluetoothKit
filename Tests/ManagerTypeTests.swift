//
//  ManagerTypeTests.swift
//  CombineBluetoothKitTests
//
//  Created by Rafał Małczyński on 09/03/2020.
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//

import XCTest
import Combine
@testable import CombineBluetoothKit

final class ManagerTypeTests: XCTestCase {
    
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
        //given
        var states = [ManagerState]()
        
        //when
        sut.state
            .sink(receiveValue: { states.append($0) })
            .store(in: &cancellables)
        
        //then
        XCTAssertEqual(states, [])
    }
    
    func test_stateChangedToPoweredOn_singleValueIsEmitted() {
        //given
        var states = [ManagerState]()
        
        //when
        sut.state
            .sink(receiveValue: { states.append($0) })
            .store(in: &cancellables)
        
        sut.state.send(.poweredOn)
        
        //then
        XCTAssertEqual(states, [.poweredOn])
    }
    
    func test_ensurePoweredOn_stateChangedToPoweredOn_errorIsNil() {
        //given
        var error: BluetoothError? = nil
        
        //when
        sut.ensurePoweredOn()
            .sink(
                receiveCompletion: { value in
                    if case let .failure(err) = value {
                        error = err
                    }
                },
                receiveValue: { _ in })
            .store(in: &cancellables)
        
        sut.state.send(.poweredOn)
        
        //then
        XCTAssertEqual(error, nil)
    }
    
    func test_ensurePoweredOn_stateChangedToPoweredOff_errorIfOfAppropriateType() {
        //given
        var error: BluetoothError? = nil
        
        //when
        sut.ensurePoweredOn()
            .sink(
                receiveCompletion: { value in
                    if case let .failure(err) = value {
                        error = err
                    }
                },
                receiveValue: { _ in })
            .store(in: &cancellables)
        
        sut.state.send(.poweredOff)
        
        //then
        XCTAssertEqual(error, BluetoothError.bluetoothPoweredOff)
    }
    
}