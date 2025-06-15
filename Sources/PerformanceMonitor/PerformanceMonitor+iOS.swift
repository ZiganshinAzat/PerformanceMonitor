import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - iOS Performance Monitor Namespace

/// Namespace для iOS Performance Monitor чтобы избежать конфликтов с другими библиотеками
public enum iOS {
    
    /// Основной класс для мониторинга производительности iOS-приложений
    public static let performanceMonitor = PerformanceMonitor.shared
    
    /// Типы данных для iOS Performance Monitor
    public typealias Data = PerformanceData
    public typealias Analysis = PerformanceAnalysis
    public typealias Anomaly = PerformanceAnomaly
    public typealias Thresholds = PerformanceThresholds
    public typealias NetworkRequest = NetworkRequestData
}

// MARK: - iOS Extensions

#if canImport(UIKit)
extension iOS {
    
    /// Удобный метод для запуска мониторинга в iOS приложении
    public static func startMonitoring(
        interval: TimeInterval = 1.0,
        thresholds: PerformanceThresholds = .default
    ) {
        performanceMonitor.start(interval: interval, thresholds: thresholds)
    }
    
    /// Удобный метод для остановки мониторинга
    public static func stopMonitoring() {
        performanceMonitor.stop()
    }
    
    /// Получить текущие метрики для iOS
    public static func getCurrentMetrics() -> PerformanceData? {
        return performanceMonitor.getCurrentMetrics()
    }
    
    /// Генерировать отчет для iOS
    public static func generateReport(
        formats: [ReportFormat] = [.json],
        completion: @escaping (Result<[URL], Error>) -> Void
    ) {
        performanceMonitor.generateReport(formats: formats, completion: completion)
    }
}
#endif 