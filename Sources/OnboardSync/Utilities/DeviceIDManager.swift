//
//  DeviceIDManager.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import Foundation

/// Manages device ID generation and persistence for the OnboardSync SDK
final class DeviceIDManager {
    
    /// Gets or generates a unique device ID
    /// - Returns: A UUID string that uniquely identifies this device
    static func getOrGenerateDeviceID() -> String {
        let defaults = UserDefaults.standard
        
        // Try to get existing device ID
        if let existingID = defaults.string(forKey: UserDefaultsKeys.deviceId) {
            debugPrint("[DeviceID] Using existing device ID: \(existingID)")
            return existingID
        }
        
        // Generate new device ID
        let newID = UUID().uuidString
        
        // Try to save the new ID with error handling
        do {
            defaults.set(newID, forKey: UserDefaultsKeys.deviceId)
            
            // Force synchronization to ensure persistence
            if defaults.synchronize() {
                debugPrint("[DeviceID] Generated and saved new device ID: \(newID)")
            } else {
                debugPrint("[DeviceID] Warning: UserDefaults synchronization failed, using temporary ID: \(newID)")
            }
        } catch {
            debugPrint("[DeviceID] Error saving device ID: \(error.localizedDescription), using temporary ID: \(newID)")
        }
        
        return newID
    }
}