import ComposableArchitecture
import Foundation

extension KeyChainServiceClient: DependencyKey {
    public static var liveValue: Self {
        let keyChainService = KeyChainService()
        return Self(
            remove: { key in keyChainService.removeToken(serviceKey: key) },
            update: { token, key in keyChainService.updateToken(token, serviceKey: key)},
            load: { key in keyChainService.loadToken(serviceKey: key) }
        )
    }
}

public struct KeyChainService {
    
    func updateToken(_ token: String, serviceKey: KeyChainService.Key) {
        guard let dataFromString = token.data(using: .utf8) else { return }
        
        let keychainQuery: [CFString : Any] = [kSecClass: kSecClassGenericPassword,
                                               kSecAttrService: serviceKey.rawValue,
                                               kSecValueData: dataFromString]
        SecItemDelete(keychainQuery as CFDictionary)
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    func removeToken(serviceKey: KeyChainService.Key) {
        
        let keychainQuery: [CFString : Any] = [kSecClass: kSecClassGenericPassword,
                                               kSecAttrService: serviceKey.rawValue]
        
        SecItemDelete(keychainQuery as CFDictionary)
    }
    
    func loadToken(serviceKey: KeyChainService.Key) -> String? {
        let keychainQuery: [CFString : Any] = [kSecClass : kSecClassGenericPassword,
                                               kSecAttrService : serviceKey.rawValue,
                                               kSecReturnData: kCFBooleanTrue!,
                                               kSecMatchLimitOne: kSecMatchLimitOne]
        
        var dataTypeRef: AnyObject?
        SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        guard let retrievedData = dataTypeRef as? Data else { return nil }
        
        return String(data: retrievedData, encoding: .utf8)
    }
}

extension KeyChainService {
    public enum Key: String {
        case tokenKey
    }
}
