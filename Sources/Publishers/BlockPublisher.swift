//
//  BlockPublisher.swift
//  CombineBluetoothKit
//
//  Created by Rafał Małczyński on 12/04/2020.
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//

import Foundation
import Combine

public extension Publishers {
    
    final class BlockPublisher<T: Publisher>: Publisher {
        public typealias Output = T.Output
        public typealias Failure = T.Failure
        
        private var publisher: AnyPublisher<Output, Failure>
        
        public init(_ publisher: @escaping () -> T) {
            self.publisher = Deferred(createPublisher: publisher).eraseToAnyPublisher()
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, BlockPublisher.Failure == S.Failure, BlockPublisher.Output == S.Input {
            publisher.subscribe(subscriber)
        }
    }
    
}
