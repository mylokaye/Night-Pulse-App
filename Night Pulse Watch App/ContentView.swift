//
//  Night_PulseApp.swift
//  Night Pulse Watch App
//
//  Created by Mylo Kaye mylokaye.tech on 10/06/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var heartRateLimit: Int = 100
    @State private var monitoringEnabled: Bool = false

    var body: some View {
        VStack {
            ScrollView {
                // Your scrollable content here
            }
            .onAppear {
                // Read the contentOffset binding here
                let _ = scrollViewOffset
            }

            Picker("Heart Rate Limit", selection: $heartRateLimit) {
                ForEach(50...200, id: \.self) { bpm in
                    Text("\(bpm) BPM").tag(bpm)
                }
            }

            Toggle(isOn: $monitoringEnabled) {
                Text("Start Monitoring")
            }
        }
        .onAppear {
            // Load saved values from UserDefaults
            heartRateLimit = UserDefaults.standard.integer(forKey: "HeartRateLimit")
            monitoringEnabled = UserDefaults.standard.bool(forKey: "MonitoringEnabled")
        }
        .onChange(of: heartRateLimit) { newValue in
            // Save to UserDefaults
            UserDefaults.standard.set(newValue, forKey: "HeartRateLimit")
        }
        .onChange(of: monitoringEnabled) { newValue in
            // Save to UserDefaults
            UserDefaults.standard.set(newValue, forKey: "MonitoringEnabled")
        }
    }

    // Helper computed property to read contentOffset binding
    private var scrollViewOffset: CGFloat {
        return 0 // Replace with the appropriate value or calculation
    }
}
