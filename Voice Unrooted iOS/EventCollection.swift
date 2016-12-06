//
//  EventCollection.swift
//  SwiftAudioKitTest
//
//  Created by James Bean on 11/19/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import Foundation

public struct EventCollection {
    
    public enum IterationError: Error {
        case outOfRange
    }
    
    /// Underlying singleton array of `Event` values.
    internal static var events: [Event] = [] {
        didSet {
            events.sort { $0.index < $1.index }
        }
    }
    
    /// Index of current `Event`.
    private static var index: Int = 0
    
    public var index: Int {
        return EventCollection.index
    }
    
    /// Current `Event` value.
    public var current: Event {
        return EventCollection.events[EventCollection.index]
    }
    
    public var previous: Event? {
        let targetIndex = index - 1
        guard indices.contains(targetIndex) else { return nil }
        return self[targetIndex]
    }
    
    public var next: Event? {
        let targetIndex = index + 1
        guard targetIndex < endIndex - 1 else { return nil }
        return self[targetIndex]
    }
    
    public func go(to index: Int) throws {
        
        guard index >= startIndex && index < endIndex else {
            throw IterationError.outOfRange
        }
        
        EventCollection.index = index
    }
    
    public func prepareNext() throws {
        
        guard EventCollection.index < endIndex - 1 else {
            throw IterationError.outOfRange
        }
        
        EventCollection.index += 1
    }
    
    public func preparePrevious() throws {
        
        guard EventCollection.index > startIndex else {
            throw IterationError.outOfRange
        }
        
        EventCollection.index -= 1
    }
}

extension EventCollection: Collection {
    
    // MARK: - CollectionType
    
    public func index(after i: Int) -> Int {
        guard i != endIndex else { fatalError("Cannot increment endIndex") }
        return i + 1
    }
    
    /// Start index.
    public var startIndex: Int {
        return 0
    }
    
    /// End index.
    public var endIndex: Int {
        return EventCollection.events.count
    }
    
    /**
     - returns: Element at the given `index`.
     */
    public subscript (index: Int) -> Event {
        return EventCollection.events[index]
    }
}
