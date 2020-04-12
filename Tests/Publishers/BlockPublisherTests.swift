//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import XCTest
import Combine
@testable import CombineBluetoothKit

final class BlockPublisherTests: XCTestCase {
    
    var cancellables: [AnyCancellable]!
    
    override func setUp() {
        cancellables = [AnyCancellable]()
    }

    override func tearDown() {
        cancellables = nil
    }
    
    func testSuccessfullCompletion() {
        let expct = expectation(description: "BlockPublisher completes with success")
        let value = 100
        
        Publishers.BlockPublisher { Just(value) }
            .handleEvents(receiveCancel: { XCTFail("BlockPublisher canceled before completion") })
            .sink(receiveCompletion: {
                guard case .finished = $0 else { return XCTFail("Successful BlockPublisher has failed unexpectedly") }
                expct.fulfill()
            }, receiveValue: { XCTAssertEqual($0, value) })
            .store(in: &cancellables)
        
        wait(for: [expct], timeout: 0.1)
    }
    
    func testFailingComletion() {
        let expct = expectation(description: "BlockPublisher completes with failure")
        
        Publishers.BlockPublisher { Fail<Void, BluetoothError>(error: BluetoothError.unknown) }
            .handleEvents(receiveCancel: { XCTFail("BlockPublisher canceled before completion") })
            .sink(receiveCompletion: {
                guard case .failure = $0 else { return XCTFail("Failed BlockPublisher has completed successfully!") }
                expct.fulfill()
            }, receiveValue: { _ in })
            .store(in: &self.cancellables)
        
        wait(for: [expct], timeout: 0.1)
    }
    
}
