//
//  ContentView.swift
//  Heart Rate2 Watch App
//
//  Created by Mylo Kaye on 03/05/2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var heartRate: Double = 0
    private let healthStore = HKHealthStore()

    var body: some View {
        VStack {
            Text("Heart Rate")
                .font(.title)

            Text("\(Int(heartRate)) BPM")
                .font(.body)
                .fontWeight(.regular)
                .lineLimit(0)
                .padding()

            Button(action: {
                fetchHeartRate()
            }) {
                Text("Check Heart Rate")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            requestAuthorization()
        }
    }

    private func requestAuthorization() {
        let heartRateQuantity = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let dataTypes: Set<HKObjectType> = [heartRateQuantity]

        healthStore.requestAuthorization(toShare: [], read: dataTypes) { success, error in
            if !success {
                print("Authorization failed")
            }
        }
    }

    private func fetchHeartRate() {
        let heartRateQuantity = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateQuantity, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let results = results, !results.isEmpty else {
                print("Error fetching heart rate data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let heartRateSample = results.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    self.heartRate = heartRateSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
            }
        }

        healthStore.execute(query)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
