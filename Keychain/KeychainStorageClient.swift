//
//  File.swift
//  
//
//  Created by Martin Lalev on 10/02/2023.
//

import Foundation
import FlooidKeyValueStorageService

public func KeychainStorage(serviceName: String, accessGroup: String?) -> KeyValueStorageService {
    KeychainStorageClient(serviceName: serviceName, accessGroup: accessGroup)
}

final class KeychainStorageClient {
    let serviceName: String
    let accessGroup: String?
    
    init(serviceName: String, accessGroup: String?) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }
    
    func makeQuery(for key: String, with additionalProperties: [CFString: Any]) -> CFDictionary {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.serviceName,
            kSecAttrGeneric: key.data(using: String.Encoding.utf8)!,
            kSecAttrAccount: key.data(using: String.Encoding.utf8)!,
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        return query.merging(additionalProperties, uniquingKeysWith: { l, _ in l }) as CFDictionary
    }
}

extension KeychainStorageClient: KeyValueStorageService {
    func get(for key: String) -> Data? {
        let query = makeQuery(for: key, with: [
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: kCFBooleanTrue as Any,
        ])

        var value: AnyObject?
        let result = SecItemCopyMatching(query, &value)

        if result == noErr {
        } else {
            print("keychain error", "read", result)
        }
        return value as? Data
    }

    func update(_ value: Data, for key: String) {
        let query = makeQuery(for: key, with: [
            kSecValueData: value,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
        ])

        let result = SecItemAdd(query, nil)
        
        if result == noErr {
            return
        } else if result == errSecDuplicateItem {
            let query = makeQuery(for: key, with: [:])
            
            let result = SecItemUpdate(query, [kSecValueData: value] as CFDictionary)
            if result == noErr {
                return
            } else {
                print("keychain error", "update", result)
            }
        } else {
            print("keychain error", "add", result)
        }
    }

    func delete(for key: String) {
        let query = makeQuery(for: key, with: [
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
        ])

        let result = SecItemDelete(query)
        if result == noErr {
            return
        } else {
            print("keychain error", "delete", result)
        }
    }
}
