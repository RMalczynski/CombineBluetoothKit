//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import XCTest
import Combine
@testable import CombineBluetoothKit

final class StateSubjectTests: XCTestCase {
    
    var cancellables: [AnyCancellable]!
    
    override func setUp() {
        cancellables = [AnyCancellable]()
    }

    override func tearDown() {
        cancellables = nil
    }
    
    func test_noValueOnInit_publisherDoesntEmitValues() {
        Publishers.StateSubject<Int, Never>()
            .sink { _ in XCTFail("StateSubject emited value unexpectedly") }
            .store(in: &cancellables)
    }
    
    func test_valueOnInit_publisherEmitsOneValue() {
        let expct = expectation(description: "StateSubject completes with success")
        
        Publishers.StateSubject<Int, Never>(100)
            .sink {
                XCTAssertEqual($0, 100)
                expct.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expct], timeout: 0.1)
    }
    
    func testPublisherEmitsSameValueToMultipleSubscribers() {
        //Given
        let sut = Publishers.StateSubject<Int, Never>(100)
        var firstValues = [Int]()
        var secondValues = [Int]()
        
        //When
        sut
            .sink { firstValues.append($0) }
            .store(in: &cancellables)
        
        sut
            .sink { secondValues.append($0) }
            .store(in: &cancellables)
        
        sut.send(20)
        
        //Then
        XCTAssertEqual(firstValues, [100, 20])
        XCTAssertEqual(secondValues, [100, 20])
    }
    
}
