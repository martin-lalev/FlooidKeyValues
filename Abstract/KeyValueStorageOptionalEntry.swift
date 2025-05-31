//
//  KeyValueStorageOptionalEntry.swift
//  
//
//  Created by Martin Lalev on 31/05/2025.
//

import Foundation

public struct KeyValueStorageOptionalEntry<V: Codable & Sendable>: Sendable {
    private let storageService: KeyValueStorageService
    private let notificationName: Notification.Name
    private let key: String
    private let fromData: @Sendable (Data) -> V?
    private let toData: @Sendable (V) -> Data?
    
    public init(
        dataStorageKey: String,
        storageService: KeyValueStorageService,
        key: String,
        fromData: @Sendable @escaping (Data) -> V?,
        toData: @Sendable @escaping (V) -> Data?
    ) {
        self.storageService = storageService
        self.notificationName = Notification.Name("\(dataStorageKey)_\(key)")
        self.key = key
        self.fromData = fromData
        self.toData = toData
    }

    public var value: V? {
        storageService.get(for: key).flatMap(fromData)
    }
    
    public func subscribe(_ observation: @Sendable @escaping (V?) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: notificationName, object: storageService, queue: nil) { notification in
            guard let value = notification.userInfo?["value"] else { return observation(nil) }
            guard let value = value as? V else { return }
            observation(value)
        }
    }
    
    public func set(_ value: V) {
        guard let data = toData(value) else { return }
        storageService.update(data, for: key)
        NotificationCenter.default.post(name: notificationName, object: storageService, userInfo: ["value": value])
    }
    
    public func remove() {
        storageService.delete(for: key)
        NotificationCenter.default.post(name: notificationName, object: storageService, userInfo: [:])
    }
}

public extension KeyValueStorageService {
    func entry<V: Codable>(for key: String, dataStorageKey: String) -> KeyValueStorageOptionalEntry<V> {
        KeyValueStorageOptionalEntry(
            dataStorageKey: dataStorageKey,
            storageService: self,
            key: key,
            fromData: { try? JSONDecoder().decode(V.self, from: $0) },
            toData: { try? JSONEncoder().encode($0)  }
        )
    }
}
