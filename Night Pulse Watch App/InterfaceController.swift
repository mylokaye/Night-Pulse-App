//
//  InterfaceController.swift
//  Night Pulse Watch App
//
//  Created by Mylo Kaye on 17/06/2023.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {
    var healthStore: HKHealthStore?
    var heartRateLimit: Double = 0.0 // Set a default limit

    @IBOutlet weak var heartRatePicker: WKInterfacePicker!
    @IBOutlet weak var monitorSwitch: WKInterfaceSwitch!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Initialize health store
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }

        // Configure the picker
        let pickerItems: [WKPickerItem] = (50...200).map { (bpm) in
            let item = WKPickerItem()
            item.title = "\(bpm)"
            return item
        }
        heartRatePicker.setItems(pickerItems)
    }

    @IBAction func heartRatePickerAction(_ value: Int) {
        // User selected a new heart rate limit
        heartRateLimit = Double(value + 50) // Adjust for the range we set (50-200)
        UserDefaults.standard.set(heartRateLimit, forKey: "HeartRateLimit")
    }

    @IBAction func monitorSwitchAction(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "MonitoringEnabled")
    }
}
