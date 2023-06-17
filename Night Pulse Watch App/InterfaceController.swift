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
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateLimitTextField: WKInterfaceTextField!

    var heartRateLimit: Double = 0.0

    @IBAction func startButtonTapped() {
        // Start monitoring heart rate
    }

    @IBAction func stopButtonTapped() {
        // Stop monitoring heart rate
    }

    @IBAction func heartRateLimitTextFieldAction(_ value: NSString?) {
        if let value = value {
            heartRateLimit = value.doubleValue
        }
    }
}
