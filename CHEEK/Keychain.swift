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
        // Data 타입으로 변환
        guard let valueData = value.data(using: .utf8) else {
            print("String을 Data로 변환 실패")
            return
        }
        
        let query: NSDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key, // 저장할 Key
            kSecValueData as String: valueData, // 저장할 value
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
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                print("Keychain에 \(key) 키가 존재하지 않습니다.")
            } else {
                print("Keychain 조회 실패: \(status)")
            }
            return nil
        }
        
        // 반환된 값을 Data로 변환
        guard let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            print("Keychain에서 데이터를 String으로 변환하는 데 실패했습니다.")
            return nil
        }
        
        return value
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
