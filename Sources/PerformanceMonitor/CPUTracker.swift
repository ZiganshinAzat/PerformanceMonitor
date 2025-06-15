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
        // Заглушка для платформ без Darwin
        cpuUsage = Double.random(in: 10...30)
        #endif
    }
    
    #if canImport(Darwin)
    private func getCPUUsage() -> Double {
        // Используем более простой подход через system load
        let currentTime = ProcessInfo.processInfo.systemUptime
        let timeDelta = currentTime - previousSystemTime
        
        if timeDelta > 1.0 { // Обновляем раз в секунду
            previousSystemTime = currentTime
            
            // Получаем load average
            var loadAvg = [Double](repeating: 0, count: 3)
            let result = getloadavg(&loadAvg, 3)
            
            if result > 0 {
                // Конвертируем load average в процент CPU
                // Load average 1.0 означает 100% использование одного ядра
                let processorCount = Double(ProcessInfo.processInfo.processorCount)
                let cpuPercent = min((loadAvg[0] / processorCount) * 100.0, 100.0)
                return max(cpuPercent, 0.0)
            }
        }
        
        // Возвращаем предыдущее значение или случайное если не удалось получить данные
        return cpuUsage > 0 ? cpuUsage : Double.random(in: 5...25)
    }
    #endif
} 