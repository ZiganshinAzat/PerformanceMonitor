import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Состояние батареи (независимое от UIKit)
public enum BatteryState: Int, Codable, CaseIterable {
    case unknown = 0
    case unplugged = 1
    case charging = 2
    case full = 3
}

/// Монитор батареи и энергопотребления
public final class BatteryMonitor {
    
    // MARK: - Singleton
    
    public static let shared = BatteryMonitor()
    
    // MARK: - Properties
    
    private var isMonitoring = false
    private var batteryHistory: [BatterySnapshot] = []
    private let maxHistoryCount = 1000
    private var lastBatteryLevel: Float = 1.0
    private var lastBatteryState: BatteryState = .unknown
    
    /// Делегат для уведомлений об изменениях батареи
    public weak var delegate: BatteryMonitorDelegate?
    
    // MARK: - Public Properties
    
    /// Текущий уровень батареи (0.0 - 1.0)
    public var currentBatteryLevel: Float {
        #if canImport(UIKit)
        return UIDevice.current.batteryLevel
        #else
        return 1.0
        #endif
    }
    
    /// Текущее состояние батареи
    public var currentBatteryState: BatteryState {
        #if canImport(UIKit)
        return BatteryState(uiDeviceState: UIDevice.current.batteryState)
        #else
        return .unknown
        #endif
    }
    
    /// История изменений батареи
    public var history: [BatterySnapshot] {
        return Array(batteryHistory)
    }
    
    /// Статистика энергопотребления
    public var energyStats: EnergyConsumptionStats {
        return calculateEnergyStats()
    }
    
    // MARK: - Public Methods
    
    /// Запускает мониторинг батареи
    public func startMonitoring() {
        guard !isMonitoring else {
            print("⚠️ BatteryMonitor уже запущен")
            return
        }
        
        isMonitoring = true
        
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
        #endif
        
        recordCurrentBatteryState()
        
        print("✅ BatteryMonitor запущен")
    }
    
    /// Останавливает мониторинг батареи
    public func stopMonitoring() {
        guard isMonitoring else {
            print("⚠️ BatteryMonitor не запущен")
            return
        }
        
        isMonitoring = false
        
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
        #endif
        
        print("🛑 BatteryMonitor остановлен")
    }
    
    /// Очищает историю батареи
    public func clearHistory() {
        batteryHistory.removeAll()
    }
    
    /// Принудительная запись текущего состояния
    public func recordCurrentState() {
        recordCurrentBatteryState()
    }
    
    // MARK: - Private Methods
    
    private init() {}
    
    @objc private func batteryLevelDidChange() {
        recordCurrentBatteryState()
    }
    
    @objc private func batteryStateDidChange() {
        recordCurrentBatteryState()
    }
    
    private func recordCurrentBatteryState() {
        let snapshot = BatterySnapshot(
            level: currentBatteryLevel,
            state: currentBatteryState,
            timestamp: Date()
        )
        
        batteryHistory.append(snapshot)
        
        if batteryHistory.count > maxHistoryCount {
            batteryHistory.removeFirst(batteryHistory.count - maxHistoryCount)
        }
        
        analyzeBatteryConsumption(snapshot)
        
        delegate?.batteryMonitor(self, didRecordSnapshot: snapshot)
        
        lastBatteryLevel = snapshot.level
        lastBatteryState = snapshot.state
    }
    
    private func analyzeBatteryConsumption(_ snapshot: BatterySnapshot) {
        guard batteryHistory.count >= 2 else { return }
        
        let previousSnapshot = batteryHistory[batteryHistory.count - 2]
        let timeDiff = snapshot.timestamp.timeIntervalSince(previousSnapshot.timestamp)
        let levelDiff = previousSnapshot.level - snapshot.level
        
        if timeDiff > 0 && levelDiff > 0 {
            let drainRatePerMinute = (levelDiff / Float(timeDiff)) * 60
            
            if drainRatePerMinute > 0.05 {
                let warning = "⚠️ Быстрый разряд батареи: \(String(format: "%.1f", drainRatePerMinute * 100))%/мин"
                print(warning)
                delegate?.batteryMonitor(self, didDetectFastDrain: drainRatePerMinute)
            }
        }
    }
    
    private func calculateEnergyStats() -> EnergyConsumptionStats {
        guard batteryHistory.count >= 2 else {
            return EnergyConsumptionStats(
                totalDrainPercent: 0,
                averageDrainRatePerHour: 0,
                timeToEmpty: nil,
                chargingTime: nil,
                isCharging: currentBatteryState == .charging,
                currentLevel: currentBatteryLevel
            )
        }
        
        let first = batteryHistory.first!
        let last = batteryHistory.last!
        
        let totalTime = last.timestamp.timeIntervalSince(first.timestamp)
        let totalDrain = first.level - last.level
        
        let drainRatePerHour = totalTime > 0 ? (totalDrain / Float(totalTime)) * 3600 : 0
        
        let timeToEmpty: TimeInterval? = drainRatePerHour > 0 ?
            TimeInterval(last.level / drainRatePerHour * 3600) : nil
        
        let chargingSnapshots = batteryHistory.filter { $0.state == .charging }
        var chargingTime: TimeInterval? = nil
        
        if chargingSnapshots.count >= 2 {
            let firstCharging = chargingSnapshots.first!
            let lastCharging = chargingSnapshots.last!
            chargingTime = lastCharging.timestamp.timeIntervalSince(firstCharging.timestamp)
        }
        
        return EnergyConsumptionStats(
            totalDrainPercent: totalDrain,
            averageDrainRatePerHour: drainRatePerHour,
            timeToEmpty: timeToEmpty,
            chargingTime: chargingTime,
            isCharging: currentBatteryState == .charging,
            currentLevel: currentBatteryLevel
        )
    }
}

// MARK: - BatteryMonitorDelegate

public protocol BatteryMonitorDelegate: AnyObject {
    func batteryMonitor(_ monitor: BatteryMonitor, didRecordSnapshot snapshot: BatterySnapshot)
    func batteryMonitor(_ monitor: BatteryMonitor, didDetectFastDrain rate: Float)
}

// MARK: - Supporting Structures

public struct BatterySnapshot: Codable {
    public let level: Float // 0.0 - 1.0
    public let state: BatteryState
    public let timestamp: Date
    
    public init(level: Float, state: BatteryState, timestamp: Date) {
        self.level = level
        self.state = state
        self.timestamp = timestamp
    }
}

public struct EnergyConsumptionStats {
    public let totalDrainPercent: Float
    public let averageDrainRatePerHour: Float
    public let timeToEmpty: TimeInterval?
    public let chargingTime: TimeInterval?
    public let isCharging: Bool
    public let currentLevel: Float
    
    /// Оценка энергоэффективности (0.0 - 1.0)
    public var efficiencyScore: Double {
        guard averageDrainRatePerHour > 0 else { return 1.0 }
        
        let normalDrainRate: Float = 0.10
        let efficiency = min(1.0, normalDrainRate / averageDrainRatePerHour)
        return Double(efficiency)
    }
}

// MARK: - BatteryState Extension

extension BatteryState {
    #if canImport(UIKit)
    init(uiDeviceState: UIDevice.BatteryState) {
        switch uiDeviceState {
        case .unknown:
            self = .unknown
        case .unplugged:
            self = .unplugged
        case .charging:
            self = .charging
        case .full:
            self = .full
        @unknown default:
            self = .unknown
        }
    }
    #endif
} 
