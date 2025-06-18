import Foundation
import UIKit
import PerformanceMonitor

/// Демонстрационный класс для тестирования всех функций PerformanceMonitor
/// Специально создает различные типы аномалий для демонстрации возможностей библиотеки
class PerformanceMonitorDemo {
    
    private var timer: Timer?
    private var heavyComputationTimer: Timer?
    private var memoryHogArray: [Data] = []
    
    // MARK: - Основные методы демонстрации
    
    /// Запускает полную демонстрацию всех аномалий
    func startFullDemo() {
        print("🚀 Запуск полной демонстрации PerformanceMonitor")
        print("📊 Будут продемонстрированы все типы аномалий:")
        print("   - Низкий FPS")
        print("   - Высокая загрузка CPU")
        print("   - Высокое потребление памяти")
        print("   - Скачки памяти")
        print("   - Медленные сетевые запросы")
        print()
        
        // Настраиваем более чувствительные пороги для демонстрации
        let demoThresholds = PerformanceThresholds(
            minFPS: 55.0,      // Высокий порог для FPS
            maxCPU: 50.0,      // Низкий порог для CPU
            maxMemory: 100.0,  // Низкий порог для памяти
            maxNetworkDuration: 2.0, // Короткий порог для сети
            memorySpikeFactor: 1.3   // Чувствительный порог для скачков памяти
        )
        
        // Запускаем мониторинг с частым интервалом сбора данных
        PerformanceMonitor.shared.start(interval: 0.5, thresholds: demoThresholds)
        
        // Запускаем все типы аномалий с задержками
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.simulateLowFPS()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.simulateHighCPUUsage()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.simulateHighMemoryUsage()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            self.simulateMemorySpikes()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
            self.simulateSlowNetworkRequests()
        }
        
        // Завершаем демонстрацию и генерируем отчет
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            self.finishDemo()
        }
    }
    
    /// Останавливает демонстрацию и очищает ресурсы
    func stopDemo() {
        print("🛑 Остановка демонстрации")
        
        timer?.invalidate()
        timer = nil
        
        heavyComputationTimer?.invalidate()
        heavyComputationTimer = nil
        
        memoryHogArray.removeAll()
        
        PerformanceMonitor.shared.stop()
    }
    
    // MARK: - Симуляция различных типов аномалий
    
    /// Симулирует низкий FPS через блокировку главного потока
    private func simulateLowFPS() {
        print("🎮 Начинаем симуляцию низкого FPS...")
        
        // Создаем тяжелые вычисления на главном потоке
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Блокируем главный поток на 50-100ms
            let blockTime = Double.random(in: 0.05...0.1)
            let endTime = CFAbsoluteTimeGetCurrent() + blockTime
            
            while CFAbsoluteTimeGetCurrent() < endTime {
                // Бесполезные вычисления для блокировки потока
                _ = sin(Double.random(in: 0...1000)) * cos(Double.random(in: 0...1000))
            }
        }
        
        // Останавливаем через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.timer?.invalidate()
            self.timer = nil
            print("✅ Симуляция низкого FPS завершена")
        }
    }
    
    /// Симулирует высокую загрузку CPU
    private func simulateHighCPUUsage() {
        print("⚡ Начинаем симуляцию высокой загрузки CPU...")
        
        // Запускаем несколько фоновых задач с интенсивными вычислениями
        for i in 0..<4 {
            DispatchQueue.global(qos: .userInitiated).async {
                let endTime = CFAbsoluteTimeGetCurrent() + 3.0
                
                while CFAbsoluteTimeGetCurrent() < endTime {
                    // Интенсивные математические вычисления
                    var result = 0.0
                    for j in 0..<10000 {
                        result += sin(Double(j)) * cos(Double(j)) * tan(Double(j))
                    }
                    
                    // Маленькая пауза чтобы не заблокировать устройство полностью
                    Thread.sleep(forTimeInterval: 0.001)
                }
                
                if i == 0 {
                    DispatchQueue.main.async {
                        print("✅ Симуляция высокой загрузки CPU завершена")
                    }
                }
            }
        }
    }
    
    /// Симулирует высокое потребление памяти
    private func simulateHighMemoryUsage() {
        print("💾 Начинаем симуляцию высокого потребления памяти...")
        
        // Постепенно выделяем большие блоки памяти
        heavyComputationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            // Создаем блок данных по 10MB
            let dataSize = 10 * 1024 * 1024 // 10 MB
            let data = Data(count: dataSize)
            self.memoryHogArray.append(data)
            
            print("📈 Выделено еще 10MB памяти (всего: \(self.memoryHogArray.count * 10)MB)")
        }
        
        // Останавливаем через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.heavyComputationTimer?.invalidate()
            self.heavyComputationTimer = nil
            print("✅ Симуляция высокого потребления памяти завершена")
        }
    }
    
    /// Симулирует резкие скачки памяти
    private func simulateMemorySpikes() {
        print("📊 Начинаем симуляцию скачков памяти...")
        
        var spikeCount = 0
        
        func createMemorySpike() {
            guard spikeCount < 3 else {
                print("✅ Симуляция скачков памяти завершена")
                return
            }
            
            spikeCount += 1
            
            // Резко выделяем большой блок памяти
            let spikeSize = 50 * 1024 * 1024 // 50 MB
            let spikeData = Data(count: spikeSize)
            memoryHogArray.append(spikeData)
            
            print("🔥 Скачок памяти #\(spikeCount): выделено 50MB")
            
            // Планируем следующий скачок через 1 секунду
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                createMemorySpike()
            }
        }
        
        createMemorySpike()
    }
    
    /// Симулирует медленные сетевые запросы
    private func simulateSlowNetworkRequests() {
        print("🌐 Начинаем симуляцию медленных сетевых запросов...")
        
        let urls = [
            "https://httpbin.org/delay/3",  // 3 секунды задержки
            "https://httpbin.org/delay/4",  // 4 секунды задержки
            "https://httpbin.org/delay/5",  // 5 секунд задержки
        ]
        
        for (index, urlString) in urls.enumerated() {
            guard let url = URL(string: urlString) else { continue }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) {
                print("🌐 Отправляем медленный запрос #\(index + 1)...")
                
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("❌ Запрос #\(index + 1) завершился с ошибкой: \(error)")
                        } else {
                            print("✅ Медленный запрос #\(index + 1) завершен")
                        }
                        
                        if index == urls.count - 1 {
                            print("✅ Симуляция медленных сетевых запросов завершена")
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    /// Завершает демонстрацию и генерирует отчет
    private func finishDemo() {
        print("\n🎯 Демонстрация завершена! Генерируем отчет...")
        
        // Получаем анализ производительности
        let analysis = PerformanceMonitor.shared.getPerformanceAnalysis()
        
        print("\n📈 РЕЗУЛЬТАТЫ АНАЛИЗА:")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📊 Собрано точек данных: \(analysis.totalDataPoints)")
        print("🎮 Средний FPS: \(String(format: "%.1f", analysis.averageFPS))")
        print("⚡ Средняя загрузка CPU: \(String(format: "%.1f", analysis.averageCPU))%")
        print("💾 Среднее потребление памяти: \(String(format: "%.1f", analysis.averageMemory)) MB")
        print("🔥 Пиковое потребление памяти: \(String(format: "%.1f", analysis.peakMemory)) MB")
        print("🏆 Общая оценка производительности: \(analysis.overallScore)/100")
        
        print("\n🚨 ОБНАРУЖЕННЫЕ АНОМАЛИИ (\(analysis.anomalies.count)):")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        let groupedAnomalies = Dictionary(grouping: analysis.anomalies) { $0.type }
        
        for anomalyType in AnomalyType.allCases {
            if let anomalies = groupedAnomalies[anomalyType] {
                let typeEmoji = getEmojiForAnomalyType(anomalyType)
                print("\(typeEmoji) \(anomalyType.rawValue): \(anomalies.count) случаев")
                
                // Показываем несколько примеров
                for (index, anomaly) in anomalies.prefix(3).enumerated() {
                    let formatter = DateFormatter()
                    formatter.timeStyle = .medium
                    let timeString = formatter.string(from: anomaly.timestamp)
                    print("   \(index + 1). [\(timeString)] \(anomaly.description)")
                }
                
                if anomalies.count > 3 {
                    print("   ... и еще \(anomalies.count - 3) случаев")
                }
                print()
            }
        }
        
        print("\n💡 РЕКОМЕНДАЦИИ:")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        for (index, recommendation) in analysis.recommendations.enumerated() {
            print("\(index + 1). \(recommendation)")
        }
        
        // Генерируем отчеты
        PerformanceMonitor.shared.generateReport(formats: [.json, .csv]) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let urls):
                    print("\n📄 ОТЧЕТЫ СОЗДАНЫ:")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    for url in urls {
                        print("📁 \(url.lastPathComponent): \(url.path)")
                    }
                    print("\n🎉 Демонстрация PerformanceMonitor успешно завершена!")
                    
                case .failure(let error):
                    print("❌ Ошибка при генерации отчетов: \(error)")
                }
                
                // Очищаем ресурсы
                self.stopDemo()
            }
        }
    }
    
    // MARK: - Вспомогательные методы
    
    private func getEmojiForAnomalyType(_ type: AnomalyType) -> String {
        switch type {
        case .lowFPS: return "🎮"
        case .highCPU: return "⚡"
        case .highMemory: return "💾"
        case .memorySpike: return "🔥"
        case .slowNetworkRequest: return "🌐"
        case .batteryDrain: return "🔋"
        }
    }
    
    /// Метод для быстрого тестирования отдельной аномалии
    func testSpecificAnomaly(_ type: AnomalyType) {
        print("🧪 Тестирование аномалии: \(type.rawValue)")
        
        // Запускаем мониторинг с базовыми настройками
        PerformanceMonitor.shared.start(interval: 0.5)
        
        switch type {
        case .lowFPS:
            simulateLowFPS()
        case .highCPU:
            simulateHighCPUUsage()
        case .highMemory:
            simulateHighMemoryUsage()
        case .memorySpike:
            simulateMemorySpikes()
        case .slowNetworkRequest:
            simulateSlowNetworkRequests()
        case .batteryDrain:
            print("⚠️ Аномалия battery_drain требует реальных условий разрядки батареи")
        }
        
        // Останавливаем через 10 секунд
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            let analysis = PerformanceMonitor.shared.getPerformanceAnalysis()
            let relevantAnomalies = analysis.anomalies.filter { $0.type == type }
            
            print("✅ Тест завершен. Обнаружено аномалий типа \(type.rawValue): \(relevantAnomalies.count)")
            
            for anomaly in relevantAnomalies {
                print("   - \(anomaly.description)")
            }
            
            self.stopDemo()
        }
    }
}

// MARK: - Пример использования

/*
// Использование в вашем приложении:

// 1. Полная демонстрация всех аномалий
let demo = PerformanceMonitorDemo()
demo.startFullDemo()

// 2. Тестирование конкретной аномалии
demo.testSpecificAnomaly(.lowFPS)

// 3. Базовое использование библиотеки
PerformanceMonitor.shared.start()

// Получение текущих метрик
if let metrics = PerformanceMonitor.shared.getCurrentMetrics() {
    print("Текущий FPS: \(metrics.fps)")
    print("Загрузка CPU: \(metrics.cpuUsage)%")
    print("Потребление памяти: \(metrics.memoryUsage) MB")
}

// Остановка мониторинга
PerformanceMonitor.shared.stop()
*/