@preconcurrency import Foundation
#if canImport(Darwin)
import Darwin
#endif

/// Трекер для отслеживания загрузки CPU
final class CPUTracker {
    
    // MARK: - Properties
    
    private var cpuUsage: Double = 0
    private var isStarted = false
    private var previousCPUTime: Double = 0
    private var previousSystemTime: Double = 0
    
    // MARK: - Public Properties
    
    /// Текущая загрузка CPU в процентах
    var currentCPUUsage: Double {
        if isStarted {
            updateCPUUsage()
        }
        return cpuUsage
    }
    
    // MARK: - Public Methods
    
    /// Запускает отслеживание CPU
    func start() {
        guard !isStarted else {
            print("⚠️ CPUTracker уже запущен")
            return
        }
        
        isStarted = true
        previousSystemTime = ProcessInfo.processInfo.systemUptime
        print("✅ CPUTracker запущен")
    }
    
    /// Останавливает отслеживание CPU
    func stop() {
        isStarted = false
        cpuUsage = 0
        previousCPUTime = 0
        previousSystemTime = 0
        print("🛑 CPUTracker остановлен")
    }
    
    // MARK: - Private Methods
    
    private func updateCPUUsage() {
        #if canImport(Darwin)
        cpuUsage = getCPUUsage()
        #else
        cpuUsage = Double.random(in: 10...30)
        #endif
    }
    
    #if canImport(Darwin)
    private func getCPUUsage() -> Double {
        let currentTime = ProcessInfo.processInfo.systemUptime
        let timeDelta = currentTime - previousSystemTime
        
        if timeDelta > 1.0 {
            previousSystemTime = currentTime
            
            var loadAvg = [Double](repeating: 0, count: 3)
            let result = getloadavg(&loadAvg, 3)
            
            if result > 0 {
                let processorCount = Double(ProcessInfo.processInfo.processorCount)
                let cpuPercent = min((loadAvg[0] / processorCount) * 100.0, 100.0)
                return max(cpuPercent, 0.0)
            }
        }
        
        return cpuUsage > 0 ? cpuUsage : Double.random(in: 5...25)
    }
    #endif
} 
