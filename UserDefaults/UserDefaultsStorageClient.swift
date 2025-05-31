//
//  File.swift
//  
//
//  Created by Martin Lalev on 10/02/2023.
//

import Foundation
import FlooidKeyValueStorageService

public func UserDefaultsStorage(userDefaults: UserDefaults) -> KeyValueStorageService {
    UserDefaultsStorageClient(userDefaults: userDefaults)
}

final class UserDefaultsStorageClient {
    nonisolated(unsafe) let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsStorageClient: KeyValueStorageService {
    func get(for key: String) -> Data? {
        self.userDefaults.data(forKey: key)
    }
    
    func update(_ value: Data, for key: String) {
        self.userDefaults.set(value, forKey: key)
    }

    func delete(for key: String) {
        self.userDefaults.removeObject(forKey: key)
    }
}
