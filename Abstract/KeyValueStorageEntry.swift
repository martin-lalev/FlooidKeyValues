//
//  KeyValueStorageEntry.swift
//  
//
//  Created by Martin Lalev on 31/05/2025.
//

import Foundation

public struct KeyValueStorageEntry<V: Codable & Sendable>: Sendable {
    private let dataStorageKey: KeyValueStorageOptionalEntry<V>
    private let defaultValue: V
    
    public init(
        dataStorageKey: KeyValueStorageOptionalEntry<V>,
        defaultValue: V
    ) {
        self.dataStorageKey = dataStorageKey
        self.defaultValue = defaultValue
    }
    
    public var value: V {
        dataStorageKey.value ?? defaultValue
    }
    
    public func subscribe(_ observation: @Sendable @escaping (V) -> Void) -> NSObjectProtocol {
        dataStorageKey.subscribe { [defaultValue] in observation($0 ?? defaultValue) }
    }
    
    public func set(_ value: V) {
        dataStorageKey.set(value)
    }

    public func remove() {
        dataStorageKey.remove()
    }
}

public extension KeyValueStorageService {
    func entry<V: Codable>(for key: String, dataStorageKey: String, defaultTo defaultValue: V) -> KeyValueStorageEntry<V> {
        KeyValueStorageEntry(
            dataStorageKey: entry(for: key, dataStorageKey: dataStorageKey),
            defaultValue: defaultValue
        )
    }
}
