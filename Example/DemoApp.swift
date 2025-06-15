import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(PerformanceMonitor)
import PerformanceMonitor
#endif

/// Демонстрационное приложение для показа возможностей PerformanceMonitor
class DemoApp {
    
    private let monitor = PerformanceMonitor.shared
    private var isRunning = false
    
    func start() {
        print("🚀 Запуск демонстрационного приложения PerformanceMonitor")
        print("=" * 60)
        
        setupMonitoring()
        runDemoScenarios()
    }
    
    private func setupMonitoring() {
        print("\n⚙️ Настройка мониторинга...")
        
        // Настройка пороговых значений для демонстрации
        let demoThresholds = PerformanceThresholds(
            cpuUsageWarning: 60.0,
            cpuUsageCritical: 85.0,
            memoryUsageWarning: 150.0,
            memoryUsageCritical: 300.0,
            fpsWarning: 50.0,
            fpsCritical: 30.0,
            batteryLevelWarning: 30.0,
            batteryLevelCritical: 15.0
        )
        
        // Запуск мониторинга с интервалом 1 секунда
        monitor.start(interval: 1.0, thresholds: demoThresholds)
        isRunning = true
        
        print("✅ Мониторинг запущен с интервалом 1 секунда")
    }
    
    private func runDemoScenarios() {
        print("\n🎬 Запуск демонстрационных сценариев...")
        
        // Сценарий 1: Нормальная работа
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.scenario1_NormalOperation()
        }
        
        // Сценарий 2: Высокая нагрузка на CPU
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.scenario2_HighCPULoad()
        }
        
        // Сценарий 3: Сетевые запросы
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            self.scenario3_NetworkRequests()
        }
        
        // Сценарий 4: Анализ и отчеты
        DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
            self.scenario4_AnalysisAndReports()
        }
        
        // Завершение демонстрации
        DispatchQueue.main.asyncAfter(deadline: .now() + 16.0) {
            self.finishDemo()
        }
    }
    
    private func scenario1_NormalOperation() {
        print("\n📊 Сценарий 1: Нормальная работа приложения")
        print("-" * 40)
        
        // Получаем текущие метрики
        let metrics = monitor.getCurrentMetrics()
        printMetrics(metrics, title: "Базовые метрики")
        
        // Симуляция легкой работы
        for i in 0..<100 {
            _ = sin(Double(i))
        }
    }
    
    private func scenario2_HighCPULoad() {
        print("\n🔥 Сценарий 2: Высокая нагрузка на CPU")
        print("-" * 40)
        
        // Создаем высокую нагрузку на CPU
        DispatchQueue.global(qos: .userInitiated).async {
            let startTime = Date()
            while Date().timeIntervalSince(startTime) < 2.0 {
                for i in 0..<10000 {
                    _ = sqrt(Double(i)) * cos(Double(i))
                }
            }
            
            DispatchQueue.main.async {
                let metrics = self.monitor.getCurrentMetrics()
                self.printMetrics(metrics, title: "Метрики под нагрузкой")
            }
        }
    }
    
    private func scenario3_NetworkRequests() {
        print("\n🌐 Сценарий 3: Сетевые запросы")
        print("-" * 40)
        
        // Симуляция множественных сетевых запросов
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                print("📡 Симуляция сетевого запроса #\(i + 1)")
                
                // В реальном приложении здесь были бы настоящие URLSession запросы
                // Для демонстрации просто добавляем задержку
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    DispatchQueue.main.async {
                        print("✅ Запрос #\(i + 1) завершен")
                    }
                }
            }
        }
    }
    
    private func scenario4_AnalysisAndReports() {
        print("\n🎯 Сценарий 4: Анализ производительности и генерация отчетов")
        print("-" * 40)
        
        // Получаем анализ производительности
        let analysis = monitor.getPerformanceAnalysis()
        printAnalysis(analysis)
        
        // Генерируем отчеты
        print("\n📄 Генерация отчетов...")
        monitor.generateReport(formats: [.json, .csv]) { result in
            switch result {
            case .success(let urls):
                print("✅ Отчеты успешно сгенерированы:")
                for url in urls {
                    print("  📁 \(url.lastPathComponent)")
                }
            case .failure(let error):
                print("❌ Ошибка генерации отчетов: \(error.localizedDescription)")
            }
        }
    }
    
    private func finishDemo() {
        print("\n🏁 Завершение демонстрации")
        print("=" * 60)
        
        // Финальные метрики
        let finalMetrics = monitor.getCurrentMetrics()
        printMetrics(finalMetrics, title: "Финальные метрики")
        
        // Остановка мониторинга
        monitor.stop()
        isRunning = false
        
        print("\n✅ Демонстрация завершена!")
        print("📊 Все данные сохранены и отчеты сгенерированы")
        print("🔧 Фреймворк PerformanceMonitor готов к использованию!")
    }
    
    private func printMetrics(_ metrics: PerformanceData, title: String) {
        print("\n📈 \(title):")
        print("  🔥 CPU: \(String(format: "%.1f", metrics.cpuUsage))%")
        print("  💾 Память: \(String(format: "%.1f", metrics.memoryUsage)) МБ")
        print("  🎮 FPS: \(String(format: "%.1f", metrics.fps))")
        
        if let batteryLevel = metrics.batteryLevel {
            print("  🔋 Батарея: \(String(format: "%.0f", batteryLevel))%")
        }
        
        if let screenName = metrics.currentScreen {
            print("  📱 Экран: \(screenName)")
        }
        
        print("  🕐 Время: \(DateFormatter.localizedString(from: metrics.timestamp, dateStyle: .none, timeStyle: .medium))")
    }
    
    private func printAnalysis(_ analysis: PerformanceAnalysis) {
        print("\n🎯 Анализ производительности:")
        print("  📊 Общая оценка: \(analysis.overallScore)/100")
        print("  ⚠️ Аномалий: \(analysis.anomalies.count)")
        
        if !analysis.anomalies.isEmpty {
            print("  🚨 Обнаруженные аномалии:")
            for anomaly in analysis.anomalies.prefix(3) {
                print("    • \(anomaly.type.rawValue): \(anomaly.description)")
            }
        }
        
        if !analysis.recommendations.isEmpty {
            print("  💡 Рекомендации:")
            for recommendation in analysis.recommendations.prefix(3) {
                print("    • \(recommendation)")
            }
        }
    }
}

// MARK: - Запуск демонстрации

/// Функция для запуска демонстрационного приложения
func runDemoApp() {
    let demo = DemoApp()
    demo.start()
}

// Раскомментируйте для запуска демонстрации:
// runDemoApp() 