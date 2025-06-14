import Foundation

/// Анализатор данных производительности
final class DataAnalyzer {
    
    // MARK: - Public Methods
    
    /// Анализирует собранные данные производительности
    /// - Parameters:
    ///   - data: Массив данных производительности
    ///   - thresholds: Пороговые значения для анализа
    /// - Returns: Результат анализа с аномалиями и рекомендациями
    func analyze(data: [PerformanceData], thresholds: PerformanceThresholds) -> PerformanceAnalysis {
        guard !data.isEmpty else {
            return PerformanceAnalysis(
                averageFPS: 0,
                averageCPU: 0,
                averageMemory: 0,
                peakMemory: 0,
                anomalies: [],
                recommendations: ["Нет данных для анализа"],
                screenPerformance: [:]
            )
        }
        
        // Вычисляем средние значения
        let averageFPS = data.map { $0.fps }.reduce(0, +) / Double(data.count)
        let averageCPU = data.map { $0.cpuUsage }.reduce(0, +) / Double(data.count)
        let averageMemory = data.map { $0.memoryUsage }.reduce(0, +) / Double(data.count)
        let peakMemory = data.map { $0.memoryUsage }.max() ?? 0
        
        // Выявляем аномалии
        let anomalies = detectAnomalies(data: data, thresholds: thresholds)
        
        // Генерируем рекомендации
        let recommendations = generateRecommendations(
            averageFPS: averageFPS,
            averageCPU: averageCPU,
            averageMemory: averageMemory,
            peakMemory: peakMemory,
            anomalies: anomalies,
            thresholds: thresholds
        )
        
        // Анализируем производительность по экранам
        let screenPerformance = analyzeScreenPerformance(data: data, thresholds: thresholds)
        
        return PerformanceAnalysis(
            averageFPS: averageFPS,
            averageCPU: averageCPU,
            averageMemory: averageMemory,
            peakMemory: peakMemory,
            anomalies: anomalies,
            recommendations: recommendations,
            screenPerformance: screenPerformance
        )
    }
    
    // MARK: - Private Methods
    
    private func detectAnomalies(data: [PerformanceData], thresholds: PerformanceThresholds) -> [PerformanceAnomaly] {
        var anomalies: [PerformanceAnomaly] = []
        var previousMemory: Double?
        
        for dataPoint in data {
            // Проверяем FPS
            if dataPoint.fps < thresholds.minFPS {
                anomalies.append(PerformanceAnomaly(
                    type: .lowFPS,
                    timestamp: dataPoint.timestamp,
                    value: dataPoint.fps,
                    threshold: thresholds.minFPS,
                    screenName: dataPoint.screenName,
                    description: "Низкий FPS: \(String(format: "%.1f", dataPoint.fps)) (порог: \(thresholds.minFPS))"
                ))
            }
            
            // Проверяем CPU
            if dataPoint.cpuUsage > thresholds.maxCPU {
                anomalies.append(PerformanceAnomaly(
                    type: .highCPU,
                    timestamp: dataPoint.timestamp,
                    value: dataPoint.cpuUsage,
                    threshold: thresholds.maxCPU,
                    screenName: dataPoint.screenName,
                    description: "Высокая загрузка CPU: \(String(format: "%.1f", dataPoint.cpuUsage))% (порог: \(thresholds.maxCPU)%)"
                ))
            }
            
            // Проверяем память
            if dataPoint.memoryUsage > thresholds.maxMemory {
                anomalies.append(PerformanceAnomaly(
                    type: .highMemory,
                    timestamp: dataPoint.timestamp,
                    value: dataPoint.memoryUsage,
                    threshold: thresholds.maxMemory,
                    screenName: dataPoint.screenName,
                    description: "Высокое потребление памяти: \(String(format: "%.1f", dataPoint.memoryUsage)) MB (порог: \(thresholds.maxMemory) MB)"
                ))
            }
            
            // Проверяем скачки памяти
            if let prevMemory = previousMemory {
                let memoryIncrease = dataPoint.memoryUsage / prevMemory
                if memoryIncrease > thresholds.memorySpikeFactor {
                    anomalies.append(PerformanceAnomaly(
                        type: .memorySpike,
                        timestamp: dataPoint.timestamp,
                        value: memoryIncrease,
                        threshold: thresholds.memorySpikeFactor,
                        screenName: dataPoint.screenName,
                        description: "Скачок памяти: увеличение в \(String(format: "%.1f", memoryIncrease)) раз"
                    ))
                }
            }
            previousMemory = dataPoint.memoryUsage
            
            // Проверяем медленные сетевые запросы
            for networkRequest in dataPoint.networkRequests {
                if networkRequest.duration > thresholds.maxNetworkDuration {
                    anomalies.append(PerformanceAnomaly(
                        type: .slowNetworkRequest,
                        timestamp: networkRequest.timestamp,
                        value: networkRequest.duration,
                        threshold: thresholds.maxNetworkDuration,
                        screenName: dataPoint.screenName,
                        description: "Медленный сетевой запрос: \(String(format: "%.2f", networkRequest.duration))с к \(networkRequest.url)"
                    ))
                }
            }
        }
        
        return anomalies
    }
    
    private func generateRecommendations(
        averageFPS: Double,
        averageCPU: Double,
        averageMemory: Double,
        peakMemory: Double,
        anomalies: [PerformanceAnomaly],
        thresholds: PerformanceThresholds
    ) -> [String] {
        var recommendations: [String] = []
        
        // Рекомендации по FPS
        if averageFPS < thresholds.minFPS {
            recommendations.append("🎯 Оптимизируйте рендеринг: средний FPS (\(String(format: "%.1f", averageFPS))) ниже рекомендуемого")
            recommendations.append("• Уменьшите сложность анимаций")
            recommendations.append("• Оптимизируйте работу с изображениями")
            recommendations.append("• Используйте CALayer вместо UIView для сложной графики")
        }
        
        // Рекомендации по CPU
        if averageCPU > thresholds.maxCPU * 0.8 { // 80% от порога
            recommendations.append("⚡ Оптимизируйте использование CPU: средняя загрузка (\(String(format: "%.1f", averageCPU))%) высокая")
            recommendations.append("• Перенесите тяжелые вычисления в фоновые очереди")
            recommendations.append("• Оптимизируйте алгоритмы обработки данных")
            recommendations.append("• Используйте ленивую загрузку для ресурсоемких операций")
        }
        
        // Рекомендации по памяти
        if averageMemory > thresholds.maxMemory * 0.8 {
            recommendations.append("💾 Оптимизируйте использование памяти: среднее потребление (\(String(format: "%.1f", averageMemory)) MB) высокое")
            recommendations.append("• Освобождайте неиспользуемые ресурсы")
            recommendations.append("• Используйте слабые ссылки для избежания циклов")
            recommendations.append("• Оптимизируйте кэширование изображений")
        }
        
        if peakMemory > thresholds.maxMemory * 1.2 {
            recommendations.append("🚨 Критическое потребление памяти: пик (\(String(format: "%.1f", peakMemory)) MB)")
            recommendations.append("• Проверьте наличие утечек памяти")
            recommendations.append("• Уменьшите размер кэшей")
        }
        
        // Рекомендации по аномалиям
        let anomalyTypes = Set(anomalies.map { $0.type })
        
        if anomalyTypes.contains(.lowFPS) {
            recommendations.append("📱 Обнаружены проблемы с плавностью интерфейса")
        }
        
        if anomalyTypes.contains(.memorySpike) {
            recommendations.append("📈 Обнаружены резкие скачки памяти - проверьте загрузку данных")
        }
        
        if anomalyTypes.contains(.slowNetworkRequest) {
            recommendations.append("🌐 Обнаружены медленные сетевые запросы - оптимизируйте API или добавьте кэширование")
        }
        
        // Общие рекомендации
        if recommendations.isEmpty {
            recommendations.append("✅ Производительность приложения в норме")
            recommendations.append("💡 Продолжайте мониторинг для поддержания качества")
        } else {
            recommendations.append("🔧 Рекомендуется провести профилирование с помощью Instruments")
            recommendations.append("📊 Регулярно мониторьте производительность в разных сценариях использования")
        }
        
        return recommendations
    }
    
    private func analyzeScreenPerformance(data: [PerformanceData], thresholds: PerformanceThresholds) -> [String: ScreenPerformance] {
        var screenData: [String: [PerformanceData]] = [:]
        var screenTimes: [String: (start: Date, end: Date?)] = [:]
        
        // Группируем данные по экранам
        for dataPoint in data {
            guard let screenName = dataPoint.screenName else { continue }
            
            if screenData[screenName] == nil {
                screenData[screenName] = []
                screenTimes[screenName] = (start: dataPoint.timestamp, end: nil)
            }
            
            screenData[screenName]?.append(dataPoint)
            screenTimes[screenName]?.end = dataPoint.timestamp
        }
        
        var screenPerformance: [String: ScreenPerformance] = [:]
        
        for (screenName, screenDataPoints) in screenData {
            guard !screenDataPoints.isEmpty else { continue }
            
            let averageFPS = screenDataPoints.map { $0.fps }.reduce(0, +) / Double(screenDataPoints.count)
            let averageCPU = screenDataPoints.map { $0.cpuUsage }.reduce(0, +) / Double(screenDataPoints.count)
            let averageMemory = screenDataPoints.map { $0.memoryUsage }.reduce(0, +) / Double(screenDataPoints.count)
            
            // Вычисляем время, проведенное на экране
            let timeSpent: TimeInterval
            if let times = screenTimes[screenName], let endTime = times.end {
                timeSpent = endTime.timeIntervalSince(times.start)
            } else {
                timeSpent = 0
            }
            
            // Подсчитываем аномалии для этого экрана
            let screenAnomalies = detectAnomalies(data: screenDataPoints, thresholds: thresholds)
            
            screenPerformance[screenName] = ScreenPerformance(
                screenName: screenName,
                averageFPS: averageFPS,
                averageCPU: averageCPU,
                averageMemory: averageMemory,
                timeSpent: timeSpent,
                anomaliesCount: screenAnomalies.count
            )
        }
        
        return screenPerformance
    }
}

// MARK: - Analysis Helpers

extension DataAnalyzer {
    
    /// Вычисляет статистику по метрикам
    func calculateStatistics(for data: [PerformanceData]) -> PerformanceStatistics {
        guard !data.isEmpty else {
            return PerformanceStatistics(
                fpsStats: MetricStatistics(min: 0, max: 0, average: 0, median: 0),
                cpuStats: MetricStatistics(min: 0, max: 0, average: 0, median: 0),
                memoryStats: MetricStatistics(min: 0, max: 0, average: 0, median: 0)
            )
        }
        
        let fpsValues = data.map { $0.fps }.sorted()
        let cpuValues = data.map { $0.cpuUsage }.sorted()
        let memoryValues = data.map { $0.memoryUsage }.sorted()
        
        return PerformanceStatistics(
            fpsStats: calculateMetricStatistics(values: fpsValues),
            cpuStats: calculateMetricStatistics(values: cpuValues),
            memoryStats: calculateMetricStatistics(values: memoryValues)
        )
    }
    
    private func calculateMetricStatistics(values: [Double]) -> MetricStatistics {
        guard !values.isEmpty else {
            return MetricStatistics(min: 0, max: 0, average: 0, median: 0)
        }
        
        let min = values.first ?? 0
        let max = values.last ?? 0
        let average = values.reduce(0, +) / Double(values.count)
        let median = values.count % 2 == 0 
            ? (values[values.count / 2 - 1] + values[values.count / 2]) / 2
            : values[values.count / 2]
        
        return MetricStatistics(min: min, max: max, average: average, median: median)
    }
}

// MARK: - Supporting Structures

struct PerformanceStatistics {
    let fpsStats: MetricStatistics
    let cpuStats: MetricStatistics
    let memoryStats: MetricStatistics
}

struct MetricStatistics {
    let min: Double
    let max: Double
    let average: Double
    let median: Double
} 