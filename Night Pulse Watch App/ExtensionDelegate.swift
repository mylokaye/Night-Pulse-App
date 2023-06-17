//
//  ExtensionDelegate.swift
//  Night Pulse Watch App
//
//  Created by Mylo Kaye on 17/06/2023.
//
import WatchKit
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, HKWorkoutSessionDelegate {
    let healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    var heartRateQuery: HKQuery?
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        requestHealthKitAuthorization()
    }
    
    func requestHealthKitAuthorization() {
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                self.startWorkout()
            } else if let error = error {
                print("Error requesting HealthKit authorization: \(error)")
            }
        }
    }
    
    func startWorkout() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
            workoutSession?.delegate = self
            healthStore.start(workoutSession!)
        } catch {
            print("Error starting workout session: \(error)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        if toState == .running {
            startMonitoringHeartRate()
        }
    }
    
    func startMonitoringHeartRate() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
        
        heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, sampleObjects, deletedObjects, newAnchor, error) in
            self.handleHeartRateSamples(sampleObjects)
        }
        
        if let heartRateQuery = heartRateQuery {
            healthStore.execute(heartRateQuery)
        }
    }
    
    func handleHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        DispatchQueue.main.async {
            for sample in heartRateSamples {
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                let heartRateLimit = UserDefaults(suiteName: "group.com.yourcompany.NightPulse")?.double(forKey: "heartRateLimit")
                
                if let heartRateLimit = heartRateLimit, heartRate > heartRateLimit {
                    WKInterfaceDevice.current().play(.notification)
                }
            }
        }
    }
}
    // Required by
