import Foundation
import PerformanceMonitor

// MARK: - Пример использования PerformanceMonitor

class ExampleUsage {
    
    func basicUsage() {
        print("🚀 Базовое использование PerformanceMonitor")
        
        // 1. Запуск мониторинга
        PerformanceMonitor.shared.start()
        
        // 2. Симуляция работы приложения
        simulateAppWork()
        
        // 3. Получение текущих метрик
        if let metrics = PerformanceMonitor.shared.getCurrentMetrics() {
            print("📊 Текущие метрики:")
            print("   FPS: \(String(format: "%.1f", metrics.fps))")
            print("   CPU: \(String(format: "%.1f", metrics.cpuUsage))%")
            print("   Memory: \(String(format: "%.1f", metrics.memoryUsage)) MB")
            if let battery = metrics.batteryLevel {
                print("   Battery: \(String(format: "%.0f", battery))%")
            }
        }
        
        // 4. Остановка мониторинга
        PerformanceMonitor.shared.stop()
    }
    
    func advancedUsage() {
        print("\n🔧 Продвинутое использование с настройками")
        
        // Настройка пороговых значений
        let customThresholds = PerformanceThresholds(
            minFPS: 30.0,
            maxCPU: 90.0,
            maxMemory: 300.0,
            maxNetworkDuration: 10.0,
            memorySpikeFactor: 2.0
        )
        
        // Запуск с настройками
        PerformanceMonitor.shared.start(
            interval: 0.5, // Сбор данных каждые 0.5 секунды
            thresholds: customThresholds
        )
        
        // Симуляция работы
        simulateAppWork()
        
        // Принудительный сбор метрик
        PerformanceMonitor.shared.collectMetricsNow()
        PerformanceMonitor.shared.collectMetricsNow()
        PerformanceMonitor.shared.collectMetricsNow()
        
        print("📈 Собрано данных: \(PerformanceMonitor.shared.collectedDataCount)")
        
        // Генерация отчета
        generateReport()
        
        // Очистка данных
        PerformanceMonitor.shared.clearData()
        print("🗑️ Данные очищены. Осталось: \(PerformanceMonitor.shared.collectedDataCount)")
        
        PerformanceMonitor.shared.stop()
    }
    
    private func simulateAppWork() {
        print("⚙️ Симуляция работы приложения...")
        
        // Симуляция CPU нагрузки
        for _ in 0..<1000 {
            _ = sqrt(Double.random(in: 1...1000))
        }
        
        // Симуляция работы с памятью
        var data: [String] = []
        for i in 0..<100 {
            data.append("Test data \(i)")
        }
        
        // Небольшая пауза
        Thread.sleep(forTimeInterval: 0.1)
    }
    
    private func generateReport() {
        print("📄 Генерация отчета...")
        
        PerformanceMonitor.shared.generateReport(formats: [.json, .csv]) { result in
            switch result {
            case .success(let urls):
                print("✅ Отчеты созданы:")
                for url in urls {
                    print("   - \(url.lastPathComponent)")
                }
            case .failure(let error):
                print("❌ Ошибка генерации отчета: \(error)")
            }
        }
    }
}

// MARK: - Запуск примера

func runExample() {
    let example = ExampleUsage()
    
    print("=" * 50)
    print("PerformanceMonitor - Пример использования")
    print("=" * 50)
    
    example.basicUsage()
    example.advancedUsage()
    
    print("\n" + "=" * 50)
    print("Пример завершен!")
    print("=" * 50)
}

// Расширение для удобства
extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}

// Раскомментируйте для запуска примера:
// runExample() 