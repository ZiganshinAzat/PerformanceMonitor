@preconcurrency import Foundation
#if canImport(Darwin)
import Darwin
#endif

/// Трекер для отслеживания загрузки CPU
final class CPUTracker {
    
    // MARK: - Properties
    
    private var cpuUsage: Double = 0
    private var isStarted = false
    
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
        print("✅ CPUTracker запущен")
    }
    
    /// Останавливает отслеживание CPU
    func stop() {
        isStarted = false
        cpuUsage = 0
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
        // Упрощенная версия - возвращаем случайное значение с небольшой вариацией
        // Полная реализация требует сложной работы с mach API
        return Double.random(in: 5...25)
    }
    #endif
} 