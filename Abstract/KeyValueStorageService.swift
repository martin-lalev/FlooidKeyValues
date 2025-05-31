//
//  File.swift
//  
//
//  Created by Martin Lalev on 10/02/2023.
//

import Foundation

public protocol KeyValueStorageService: Sendable {
    func get(for key: String) -> Data?
    func update(_ value: Data, for key: String)
    func delete(for key: String)
}

@attached(peer, names: suffixed(Client))
public macro StorageService() = #externalMacro(module: "FlooidKeyValueStorageMacros", type: "StorageClientServiceMacro")

@attached(peer)
public macro DefaultValue<T>(_ value: T) = #externalMacro(module: "FlooidKeyValueStorageMacros", type: "StorageClientMemberMacro")

@freestanding(declaration, names: named(make))
public macro makeStorageService<T>(_ service: T.Type) = #externalMacro(module: "FlooidKeyValueStorageMacros", type: "StorageClientFactoryMacro")

