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
        
        // Настраиваем очень чувствительные пороги для демонстрации большого количества аномалий
        let demoThresholds = PerformanceThresholds(
            minFPS: 58.0,      // Очень высокий порог для FPS - любое снижение будет аномалией
            maxCPU: 30.0,      // Очень низкий порог для CPU - почти любая активность будет аномалией
            maxMemory: 80.0,   // Очень низкий порог для памяти
            maxNetworkDuration: 1.5, // Очень короткий порог для сети
            memorySpikeFactor: 1.2   // Очень чувствительный порог для скачков памяти
        )
        
        // Запускаем мониторинг с очень частым интервалом сбора данных для большего количества точек
        PerformanceMonitor.shared.start(interval: 0.3, thresholds: demoThresholds)
        
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
        
        // Повторяем циклы аномалий для большего количества данных
        DispatchQueue.main.asyncAfter(deadline: .now() + 25.0) {
            print("🔄 Запускаем второй цикл демонстрации для большего количества аномалий...")
            self.simulateLowFPS()
            self.simulateHighCPUUsage()
            self.simulateHighMemoryUsage()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            self.simulateMemorySpikes()
            self.simulateSlowNetworkRequests()
        }
        
        // Завершаем демонстрацию и генерируем отчет через больше времени
        DispatchQueue.main.asyncAfter(deadline: .now() + 45.0) {
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
        
        // Создаем очень тяжелые вычисления на главном потоке для большего количества аномалий FPS
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            // Блокируем главный поток на 80-150ms для гарантированного падения FPS
            let blockTime = Double.random(in: 0.08...0.15)
            let endTime = CFAbsoluteTimeGetCurrent() + blockTime
            
            while CFAbsoluteTimeGetCurrent() < endTime {
                // Более интенсивные вычисления для блокировки потока
                for i in 0..<1000 {
                    _ = sin(Double(i)) * cos(Double(i)) * tan(Double(i)) * log(Double(i + 1))
                }
            }
        }
        
        // Увеличиваем время симуляции для большего количества аномалий
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.timer?.invalidate()
            self.timer = nil
            print("✅ Симуляция низкого FPS завершена")
        }
    }
    
    /// Симулирует высокую загрузку CPU
    private func simulateHighCPUUsage() {
        print("⚡ Начинаем симуляцию высокой загрузки CPU...")
        
        // Запускаем больше фоновых задач с очень интенсивными вычислениями
        for i in 0..<8 {
            DispatchQueue.global(qos: .userInitiated).async {
                let endTime = CFAbsoluteTimeGetCurrent() + 6.0
                
                while CFAbsoluteTimeGetCurrent() < endTime {
                    // Очень интенсивные математические вычисления
                    var result = 0.0
                    for j in 0..<50000 {
                        result += sin(Double(j)) * cos(Double(j)) * tan(Double(j)) * sqrt(Double(j + 1))
                    }
                    
                    // Убираем паузы для максимальной нагрузки CPU
                    // Thread.sleep(forTimeInterval: 0.001)
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
        
        // Очень агрессивно выделяем большие блоки памяти
        heavyComputationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Создаем блоки данных по 15MB для быстрого роста памяти
            let dataSize = 15 * 1024 * 1024 // 15 MB
            let data = Data(count: dataSize)
            self.memoryHogArray.append(data)
            
            print("📈 Выделено еще 15MB памяти (всего: \(self.memoryHogArray.count * 15)MB)")
        }
        
        // Увеличиваем время симуляции для большего количества аномалий
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
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
            guard spikeCount < 8 else {
                print("✅ Симуляция скачков памяти завершена")
                return
            }
            
            spikeCount += 1
            
            // Резко выделяем очень большой блок памяти
            let spikeSize = 80 * 1024 * 1024 // 80 MB
            let spikeData = Data(count: spikeSize)
            memoryHogArray.append(spikeData)
            
            print("🔥 Скачок памяти #\(spikeCount): выделено 80MB")
            
            // Планируем следующий скачок через меньший интервал для большего количества скачков
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                createMemorySpike()
            }
        }
        
        createMemorySpike()
    }
    
    /// Симулирует медленные сетевые запросы
    private func simulateSlowNetworkRequests() {
        print("🌐 Начинаем симуляцию медленных сетевых запросов...")
        
        let urls = [
            "https://httpbin.org/delay/2",  // 2 секунды задержки
            "https://httpbin.org/delay/3",  // 3 секунды задержки
            "https://httpbin.org/delay/4",  // 4 секунды задержки
            "https://httpbin.org/delay/5",  // 5 секунд задержки
            "https://httpbin.org/delay/2",  // Еще один 2-секундный запрос
            "https://httpbin.org/delay/3",  // Еще один 3-секундный запрос
            "https://httpbin.org/delay/6",  // 6 секунд задержки для критически медленного запроса
            "https://httpbin.org/delay/7",  // 7 секунд задержки
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
        PerformanceMonitor.shared.generateReport() { result in
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
