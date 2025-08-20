/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import HealthKit

@Observable class WatchHealthStatus: NSObject {
    
    static var shared = WatchHealthStatus()
    
    var isMonitoring = false
    var heartRate: Double = 0.0
    
    private var healthStore: HKHealthStore?
    private let heartRateQuantityType = HKObjectType.quantityType(forIdentifier: .heartRate)
    private let appStartTime: Date
    
    override init() {
        self.appStartTime = Date()
        super.init()
    }
    
    func startMonitoring(){
        isMonitoring = false
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            guard let heartRateQuantityType = self.heartRateQuantityType else { return}
            healthStore?.requestAuthorization(toShare: nil, read: [heartRateQuantityType]) { success, error in
                if success {
                    guard let heartRateQuantityType = self.heartRateQuantityType else { return }
                    let query = HKAnchoredObjectQuery(
                        type: heartRateQuantityType,
                        predicate: nil,
                        anchor: nil,
                        limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, newAnchor, error) in
                            guard let samples = samples as? [HKQuantitySample] else { return }
                            self.process(samples: samples)
                        }
                    self.isMonitoring = true
                    query.updateHandler = { (query, samples, deletedObjects, newAnchor, error) in
                        guard let samples = samples as? [HKQuantitySample] else { return }
                        self.process(samples: samples)
                    }
                    
                    self.healthStore?.execute(query)
                }
            }
        }
    }
    
    private func process(samples: [HKQuantitySample]) {
        //Log.error("process heart rate")
        for sample in samples {
            if sample.endDate > appStartTime {
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                
                DispatchQueue.main.async {
                    self.heartRate = heartRate
                }
            }
        }
    }
}
