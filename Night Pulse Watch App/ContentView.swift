import SwiftUI
import HealthKit

class ExtendedRuntimeSessionManager: NSObject, WKExtendedRuntimeSessionDelegate {
    var session: WKExtendedRuntimeSession?

    override init() {
        super.init()
        session = WKExtendedRuntimeSession()
        session?.delegate = self
    }

    func startExtendedRuntimeSession() {
        session?.start()
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended runtime session started.")
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended runtime session will expire.")
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        print("Extended runtime session invalidated.")
    }
}

struct ContentView: View {
    @State private var heartRate: Double = 0
    @State private var heartRateLimit: Int = 70
    @State private var timerInterval: Int = 5
    let healthStore = HKHealthStore()
    let sessionManager = ExtendedRuntimeSessionManager()
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
            
                    ScrollView {
                        Text("Heart Rate: \(Int(heartRate))")                            .foregroundColor(Color.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.white)
                    }
                    .frame(maxHeight: .infinity)
                    
            
            Picker("Heart Rate Limit", selection: $heartRateLimit) {
                ForEach(50..<120) { limit in
                    Text("\(limit)").tag(limit)
                }
            }
            Picker("Timer Interval", selection: $timerInterval) {
                ForEach(1..<21) { interval in
                    Text("\(interval)").tag(interval)
                }
            }
            .onAppear(perform: {
                authorizeHealthKit()
                startHeartRateQuery(quantityTypeIdentifier: .heartRate)
                sessionManager.startExtendedRuntimeSession()
                startTimer()
            })
        }
    }
    
    
    
    
    // Request authorization to access HealthKit.
    func authorizeHealthKit() {
        let read = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
        
        healthStore.requestAuthorization(toShare: nil, read: read) { (chk, error) in
            if chk {
                print ("Authorization request succeeded")
            }
        }
    }
    
    // Query to get the most recent heart rate data and update when new data is available.
    func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        // We want data points from the last hour
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())
        
        // Create a predicate to filter the data
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        // Create the query
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            if let samples = samplesOrNil, let result = samples.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    self.heartRate = result.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    if self.heartRate > 70 {
                        // Play a haptic when heart rate goes above 70
                        WKInterfaceDevice.current().play(.notification)
                    }
                }
            }
        }
        
        // This is called when new samples are added to the HealthKit store
        query.updateHandler = { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            if let samples = samplesOrNil, let result = samples.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    self.heartRate = result.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    if self.heartRate > 70 {
                        // Play a haptic when heart rate goes above 70
                        WKInterfaceDevice.current().play(.notification)
                    }
                }
            }
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    func startTimer() {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: Double(timerInterval), repeats: true) { [self] _ in
                if heartRate > Double(heartRateLimit) {
                    WKInterfaceDevice.current().play(.notification)
                }
            }
        }
    }
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
