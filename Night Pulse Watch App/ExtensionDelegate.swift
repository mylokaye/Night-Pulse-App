//
//  ExtensionDelegate.swift
//  Night Pulse Watch App
//
//  Created by Mylo Kaye on 17/06/2023.
//
import WatchKit
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    var healthStore: HKHealthStore?
    var heartRateLimit: Double = 0.0 // Set a default limit
    var monitoringEnabled: Bool = false

    func applicationDidFinishLaunching() {
        // Initialize health store
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }

        // Request permission to access heart rate data
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        healthStore?.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                // Start monitoring heart rate
                self.startHeartRateMonitoring()
            } else {
                // Handle error
                print("Error requesting authorization: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func startHeartRateMonitoring() {
        // Get the heart rate limit from user defaults
        heartRateLimit = UserDefaults.standard.double(forKey: "HeartRateLimit")
        monitoringEnabled = UserDefaults.standard.bool(forKey: "MonitoringEnabled")
        // Rest of the code as previously described...
    }
}
