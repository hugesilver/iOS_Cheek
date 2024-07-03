//
//  Keychain.swift
//  CHEEK
//
//  Created by 김태은 on 6/24/24.
//

import Foundation

class Keychain: ObservableObject {
    // Keychain 생성
    func create(key: String, value: String) {
        let query: NSDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key, // 저장할 Account Key
            kSecValueData as String: value, // 저장할 value
        ]
        
        SecItemDelete(query) // 중복 Keychain 삭제
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            print("Keychain 생성 실패: \(status)")
            return
        }
        
        print("\(key): \(value) 키체인 생성 성공")
    }
    
    // Keychain 조회
    func read(key: String) -> String? {
        let query: NSDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne, // 중복되는 경우, 하나의 값만 불러오라는 의미
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess || status != errSecItemNotFound else {
            print("Keychain 조회 실패(status)")
            return nil
        }
        
        guard let existingItem = item as? [String: Any],
              let account = existingItem[kSecAttrAccount as String] as? String,
              let valueData = existingItem[kSecValueData as String] as? String
        else {
            print("Keychain 조회 실패(item 오류)")
            return nil
        }
        
        return valueData
    }
    
    // Keychain 삭제
    func delete(key: String) {
        let query: NSDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query)
        
        guard status == noErr else {
            print("Keychain 삭제 실패: \(status)")
            return
        }
        
        print("\(key) 키체인 삭제 성공")
    }
}
