//
//  PermissionsHandler.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import UIKit
import AVFoundation
import Photos
import CoreLocation
import Contacts
import UserNotifications

/// Handles permission requests triggered from the onboarding flow
final class PermissionsHandler: NSObject {
    
    private static let locationManager = CLLocationManager()
    private static var locationCompletion: ((Bool) -> Void)?
    
    /// Request a specific permission type
    /// - Parameters:
    ///   - type: The permission type (camera, photos, location, contacts, notification)
    ///   - completion: Callback with the granted status
    static func requestPermission(type: String, completion: @escaping (Bool) -> Void) {
        switch type.lowercased() {
        case "camera":
            requestCameraPermission(completion: completion)
        case "photos":
            requestPhotosPermission(completion: completion)
        case "location":
            requestLocationPermission(completion: completion)
        case "contacts":
            requestContactsPermission(completion: completion)
        case "notification":
            requestNotificationsPermission(completion: completion)
        default:
            debugPrint("[Permissions] Unknown permission type: \(type)")
            completion(false)
        }
    }
    
    private static func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
    
    private static func requestPhotosPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if #available(iOS 14.0, *) {
                        completion(status == .authorized || status == .limited)
                    } else {
                        completion(status == .authorized)
                    }
                }
            }
        default:
            if #available(iOS 14.0, *) {
                completion(status == .limited)
            } else {
                completion(false)
            }
        }
    }
    
    private static func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        case .notDetermined:
            locationCompletion = completion
            locationManager.delegate = LocationDelegate.shared
            locationManager.requestWhenInUseAuthorization()
        default:
            completion(false)
        }
    }
    
    private static func requestContactsPermission(completion: @escaping (Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completion(true)
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, _ in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
    
    private static func requestNotificationsPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                DispatchQueue.main.async {
                    completion(true)
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // Location delegate helper
    private class LocationDelegate: NSObject, CLLocationManagerDelegate {
        static let shared = LocationDelegate()
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            let status: CLAuthorizationStatus
            if #available(iOS 14.0, *) {
                status = manager.authorizationStatus
            } else {
                status = CLLocationManager.authorizationStatus()
            }
            
            let authorized = status == .authorizedWhenInUse || status == .authorizedAlways
            PermissionsHandler.locationCompletion?(authorized)
            PermissionsHandler.locationCompletion = nil
        }
    }
}