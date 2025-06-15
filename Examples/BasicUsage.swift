import Foundation
#if canImport(PerformanceMonitor)
import PerformanceMonitor
#endif

/// Пример базового использования PerformanceMonitor
class BasicUsageExample {
    
    private let monitor = PerformanceMonitor.shared
    
    func runExample() {
        print("🚀 Запуск примера использования PerformanceMonitor")
        
        // 1. Настройка пороговых значений
        let customThresholds = PerformanceThresholds(
            cpuUsageWarning: 70.0,
            cpuUsageCritical: 90.0,
            memoryUsageWarning: 200.0,
            memoryUsageCritical: 400.0,
            fpsWarning: 45.0,
            fpsCritical: 30.0,
            batteryLevelWarning: 20.0,
            batteryLevelCritical: 10.0
        )
        
        // 2. Запуск мониторинга с интервалом 2 секунды
        monitor.start(interval: 2.0, thresholds: customThresholds)
        
        // 3. Симуляция работы приложения
        simulateAppWork()
        
        // 4. Получение текущих метрик
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.printCurrentMetrics()
            
            // 5. Генерация отчета
            self.generateReport()
            
            // 6. Остановка мониторинга
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.monitor.stop()
                print("✅ Пример завершен")
            }
        }
    }
    
    private func simulateAppWork() {
        print("💼 Симуляция работы приложения...")
        
        // Симуляция CPU нагрузки
        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0..<1000000 {
                _ = sqrt(Double(i))
            }
        }
        
        // Симуляция сетевых запросов
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.simulateNetworkRequests()
        }
    }
    
    private func simulateNetworkRequests() {
        // Добавляем тестовые сетевые запросы
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                // В реальном приложении здесь были бы настоящие сетевые запросы
                print("🌐 Симуляция сетевого запроса #\(i + 1)")
            }
        }
    }
    
    private func printCurrentMetrics() {
        print("\n📊 Текущие метрики производительности:")
        
        let metrics = monitor.getCurrentMetrics()
        
        print("🔥 CPU: \(String(format: "%.1f", metrics.cpuUsage))%")
        print("💾 Память: \(String(format: "%.1f", metrics.memoryUsage)) МБ")
        print("🎮 FPS: \(String(format: "%.1f", metrics.fps))")
        
        if let batteryLevel = metrics.batteryLevel {
            print("🔋 Батарея: \(String(format: "%.0f", batteryLevel))%")
        }
        
        if let screenName = metrics.currentScreen {
            print("📱 Текущий экран: \(screenName)")
        }
        
        // Получаем анализ производительности
        let analysis = monitor.getPerformanceAnalysis()
        print("\n🎯 Анализ производительности:")
        print("📈 Общая оценка: \(analysis.overallScore)/100")
        print("⚠️ Аномалий обнаружено: \(analysis.anomalies.count)")
        
        if !analysis.recommendations.isEmpty {
            print("\n💡 Рекомендации:")
            for recommendation in analysis.recommendations {
                print("  • \(recommendation)")
            }
        }
    }
    
    private func generateReport() {
        print("\n📄 Генерация отчета...")
        
        monitor.generateReport(formats: [.json]) { result in
            switch result {
            case .success(let urls):
                print("✅ Отчет сгенерирован:")
                for url in urls {
                    print("  📁 \(url.lastPathComponent)")
                }
            case .failure(let error):
                print("❌ Ошибка генерации отчета: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Запуск примера

func runBasicExample() {
    let example = BasicUsageExample()
    example.runExample()
}

// Раскомментируйте для запуска примера:
// runBasicExample() 