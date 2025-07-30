//
//  OnboardSyncTests.swift
//  OnboardSyncTests
//
//  Created by OnboardSync on 2025-01-19.
//

import XCTest
@testable import OnboardSync

final class OnboardSyncTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "onboardingCompleted")
        UserDefaults.standard.removeObject(forKey: "onboardSyncDeviceId")
    }
    
    // MARK: - Configuration Tests
    
    func testConfigurationInitialization() {
        let config = OnboardSyncConfig(
            projectId: "test-project",
            secretKey: "test-secret"
        )
        
        XCTAssertEqual(config.projectId, "test-project")
        XCTAssertEqual(config.secretKey, "test-secret")
        XCTAssertFalse(config.testingEnabled)
        XCTAssertNil(config.onComplete)
    }
    
    func testConfigurationWithAllParameters() {
        var completionCalled = false
        let config = OnboardSyncConfig(
            projectId: "test-project",
            secretKey: "test-secret",
            testingEnabled: true,
            onComplete: { completionCalled = true }
        )
        
        XCTAssertEqual(config.projectId, "test-project")
        XCTAssertEqual(config.secretKey, "test-secret")
        XCTAssertTrue(config.testingEnabled)
        XCTAssertNotNil(config.onComplete)
        
        // Test completion callback
        config.onComplete?()
        XCTAssertTrue(completionCalled)
    }
    
    // MARK: - Device ID Tests
    
    func testDeviceIDGeneration() {
        let firstID = DeviceIDManager.getOrGenerateDeviceID()
        XCTAssertFalse(firstID.isEmpty)
        
        // Should return the same ID on subsequent calls
        let secondID = DeviceIDManager.getOrGenerateDeviceID()
        XCTAssertEqual(firstID, secondID)
    }
    
    func testDeviceIDFormat() {
        let deviceID = DeviceIDManager.getOrGenerateDeviceID()
        
        // Should be a valid UUID
        let uuid = UUID(uuidString: deviceID)
        XCTAssertNotNil(uuid)
    }
    
    // MARK: - Color Utility Tests
    
    func testColorUtilsDarkColors() {
        XCTAssertTrue(ColorUtils.isDark(.black))
        XCTAssertTrue(ColorUtils.isDark(.darkGray))
        XCTAssertTrue(ColorUtils.isDark(.systemBlue))
    }
    
    func testColorUtilsLightColors() {
        XCTAssertFalse(ColorUtils.isDark(.white))
        XCTAssertFalse(ColorUtils.isDark(.lightGray))
        XCTAssertFalse(ColorUtils.isDark(.systemYellow))
    }
    
    // MARK: - Constants Tests
    
    func testConstants() {
        XCTAssertEqual(globalConfigEndpoint, "https://onboardsync-backend.vercel.app/api/global-config")
        XCTAssertEqual(UserDefaultsKeys.onboardingCompleted, "onboardingCompleted")
        XCTAssertEqual(UserDefaultsKeys.deviceId, "onboardSyncDeviceId")
        XCTAssertEqual(JSMessageHandler.onboardingChannel, "flutter_bridge")
    }
}