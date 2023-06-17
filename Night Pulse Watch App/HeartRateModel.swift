//
//  HeartRateModel.swift
//  Night Pulse Watch App
//
//  Created by Mylo Kaye on 17/06/2023.
//

import Foundation
import HealthKit
import WatchKit

class HeartRateModel: ObservableObject {
    @Published var heartRate: Double = 0.0
    @Published var heartRateLimit: String = ""
    private var heartRateQuery: HKQuery?

    func startMonitoringHeartRate() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)

        heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
            self.updateHeartRate(samples: samples)
        }

        heartRateQuery!.updateHandler = { (query, samples, deletedObjects, anchor, error) in
            self.updateHeartRate(samples: samples)
        }

        HKHealthStore().execute(heartRateQuery!)
    }

    func stopMonitoringHeartRate() {
        if let query = heartRateQuery {
            HKHealthStore().stop(query)
        }
    }

    private func updateHeartRate(samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }

        DispatchQueue.main.async {
            guard let sample = samples.first else { return }
            let value = sample.quantity.doubleValue(for: .init(from: "count/min"))
            self.heartRate = value

            if value > Double(self.heartRateLimit) ?? 0.0 {
                self.sendHapticFeedback()
            }
        }
    }

    private func sendHapticFeedback() {
        WKInterfaceDevice.current().play(.notification)
    }
}
