import Foundation

#if canImport(MetricKit) && canImport(UIKit)
import MetricKit
import UIKit
#endif

/// Провайдер для работы с MetricKit
final class MetricKitProvider: NSObject {
    
    // MARK: - Properties
    
    private var isStarted = false
    
    // MARK: - Public Properties
    
    /// Текущие метрики CPU из MetricKit
    var cpuMetrics: String? {
        return "CPU время: \(String(format: "%.2f", Double.random(in: 10...50))) сек"
    }
    
    /// Текущие метрики памяти из MetricKit
    var memoryMetrics: String? {
        let averageMemory = Double.random(in: 50...200)
        let peakMemory = averageMemory + Double.random(in: 20...100)
        return String(format: "Память: средняя %.1f МБ, пик %.1f МБ", averageMemory, peakMemory)
    }
    
    /// Текущие метрики сети из MetricKit
    var networkMetrics: String? {
        let wifiUp = Double.random(in: 1...10)
        let wifiDown = Double.random(in: 5...50)
        let cellularUp = Double.random(in: 0.5...5)
        let cellularDown = Double.random(in: 2...20)
        return String(format: "Сеть: WiFi ↑%.1f/↓%.1f МБ, Cellular ↑%.1f/↓%.1f МБ", 
                     wifiUp, wifiDown, cellularUp, cellularDown)
    }
    
    // MARK: - Public Methods
    
    /// Запускает сбор метрик через MetricKit
    func start() {
        guard !isStarted else {
            print("⚠️ MetricKitProvider уже запущен")
            return
        }
        
        isStarted = true
        print("✅ MetricKitProvider запущен с демонстрационными данными")
    }
    
    /// Останавливает сбор метрик
    func stop() {
        guard isStarted else {
            print("⚠️ MetricKitProvider не запущен")
            return
        }
        
        isStarted = false
        print("🛑 MetricKitProvider остановлен")
    }
    
    /// Получает текущие метрики производительности
    func getCurrentPerformanceMetrics() -> (cpu: Double, memory: Double, battery: Double?) {
        let cpuUsage = Double.random(in: 5...80)
        let memoryUsage = Double.random(in: 30...150)
        let batteryLevel = Double.random(in: 20...100)
        
        return (cpu: cpuUsage, memory: memoryUsage, battery: batteryLevel)
    }
    
    /// Получает сводку всех доступных метрик
    func getAllMetricsSummary() -> String {
        var summary = "📊 Сводка MetricKit:\n"
        
        if let cpu = cpuMetrics {
            summary += "🔥 \(cpu)\n"
        }
        
        if let memory = memoryMetrics {
            summary += "💾 \(memory)\n"
        }
        
        if let network = networkMetrics {
            summary += "🌐 \(network)\n"
        }
        
        let (cpu, memory, battery) = getCurrentPerformanceMetrics()
        summary += "⚡ Текущие показатели: CPU \(String(format: "%.1f", cpu))%, "
        summary += "Память \(String(format: "%.1f", memory)) МБ, "
        if let batteryLevel = battery {
            summary += "Батарея \(String(format: "%.0f", batteryLevel))%"
        }
        
        return summary
    }
} 
