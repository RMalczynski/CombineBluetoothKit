//
//  CombineBluetoothKit
//  Copyright © 2020 Rafał Małczyński. All rights reserved.
//  Licensed under the MIT license (see LICENSE file)
//

import Combine

public extension Publishers {
    
    /// A publisher that wraps a single value and publishes a new element whenever the value changes.
    /// In contrast to `CurrentValueSubject`, it doesn't have to be initialized with a value.
    final class StateSubject<Output, Failure: Error>: Publisher {
        public typealias Output = Output
        public typealias Failure = Failure
        
        private var valueSubject: CurrentValueSubject<Output, Failure>?
        private var pendingSubscribers: [AnySubscriber<Output, Failure>]? = []
        
        public init(_ value: Output? = nil) {
            if let value = value {
                self.valueSubject = CurrentValueSubject<Output, Failure>(value)
                self.pendingSubscribers = nil
            }
        }
        
        public func send(_ value: Output) {
            if let subject = valueSubject {
                subject.send(value)
            } else {
                valueSubject = CurrentValueSubject<Output, Failure>(value)
                
                pendingSubscribers?
                    .forEach { valueSubject?.receive(subscriber: $0) }
                pendingSubscribers = nil
            }
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, StateSubject.Failure == S.Failure, StateSubject.Output == S.Input {
            if let subject = valueSubject {
                subject.receive(subscriber: subscriber)
            } else {
                pendingSubscribers?.append(AnySubscriber(subscriber))
            }
        }
    }
    
}
