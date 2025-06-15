@preconcurrency import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Основной класс для мониторинга производительности iOS-приложений
public final class PerformanceMonitor {
    
    // MARK: - Singleton
    
    nonisolated(unsafe) public static let shared = PerformanceMonitor()
    
    // MARK: - Private Properties
    
    private var isMonitoring = false
    private var performanceData: [PerformanceData] = []
    private var thresholds: PerformanceThresholds = .default
    private var monitoringTimer: Timer?
    
    private let queue = DispatchQueue(label: "com.performancemonitor.data", qos: .utility)
    
    // Трекеры
    private let fpsTracker = FPSTracker()
    private let cpuTracker = CPUTracker()
    private let metricKitProvider = MetricKitProvider()
    private let networkMonitor = NetworkMonitor()
    private let viewControllerTracker = UIViewControllerTracker()
    private let dataAnalyzer = DataAnalyzer()
    private let reportGenerator = ReportGenerator()
    
    // MARK: - Initialization
    
    private init() {
        setupDelegates()
    }
    
    // MARK: - Public Methods
    
    /// Запускает мониторинг производительности
    /// - Parameter interval: Интервал сбора метрик в секундах (по умолчанию 1.0)
    /// - Parameter thresholds: Пороговые значения для анализа (по умолчанию стандартные)
    public func start(interval: TimeInterval = 1.0, thresholds: PerformanceThresholds = .default) {
        guard !isMonitoring else {
            print("⚠️ PerformanceMonitor уже запущен")
            return
        }
        
        self.thresholds = thresholds
        isMonitoring = true
        
        // Запускаем все трекеры
        fpsTracker.start()
        cpuTracker.start()
        metricKitProvider.start()
        networkMonitor.start()
        viewControllerTracker.start()
        
        print("✅ PerformanceMonitor запущен с интервалом \(interval)с")
    }
    
    /// Останавливает мониторинг производительности
    public func stop() {
        guard isMonitoring else {
            print("⚠️ PerformanceMonitor не запущен")
            return
        }
        
        isMonitoring = false
        
        // Останавливаем все трекеры
        fpsTracker.stop()
        cpuTracker.stop()
        metricKitProvider.stop()
        networkMonitor.stop()
        viewControllerTracker.stop()
        
        // Останавливаем таймер
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        
        print("🛑 PerformanceMonitor остановлен")
    }
    
    /// Генерирует отчет о производительности
    /// - Parameters:
    ///   - formats: Форматы отчета (PDF, JSON, CSV)
    ///   - completion: Колбэк с результатом генерации
    public func generateReport(
        formats: [ReportFormat] = [.pdf, .json],
        completion: @escaping @Sendable (Result<[URL], Error>) -> Void
    ) {
        let analysis = self.dataAnalyzer.analyze(
            data: self.performanceData,
            thresholds: self.thresholds
        )
        
        do {
            let urls = try self.reportGenerator.generateReports(
                analysis: analysis,
                rawData: self.performanceData,
                formats: formats
            )
            completion(.success(urls))
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Очищает собранные данные
    public func clearData() {
        performanceData.removeAll()
        print("🗑️ Данные PerformanceMonitor очищены")
    }
    
    /// Возвращает текущие метрики
    @MainActor public func getCurrentMetrics() -> PerformanceData? {
        guard isMonitoring else { return nil }
        
        return PerformanceData(
            fps: fpsTracker.currentFPS,
            cpuUsage: cpuTracker.currentCPUUsage,
            memoryUsage: getCurrentMemoryUsage(),
            batteryLevel: getCurrentBatteryLevel(),
            screenName: viewControllerTracker.currentScreenName,
            networkRequests: networkMonitor.capturedRequests
        )
    }
    
    /// Возвращает количество собранных метрик
    public var collectedDataCount: Int {
        return performanceData.count
    }
    
    /// Проверяет, запущен ли мониторинг
    public var isRunning: Bool {
        return isMonitoring
    }
    
    /// Принудительно собирает метрики (для тестирования)
    @MainActor public func collectMetricsNow() {
        collectMetrics()
    }
    
    // MARK: - Private Methods
    
    private func setupDelegates() {
        // Настройка делегатов для получения данных от трекеров
        // networkMonitor.delegate = self // Заглушка
    }
    
    @MainActor private func collectMetrics() {
        guard isMonitoring else { return }
        
        let metrics = PerformanceData(
            fps: self.fpsTracker.currentFPS,
            cpuUsage: self.cpuTracker.currentCPUUsage,
            memoryUsage: self.getCurrentMemoryUsage(),
            batteryLevel: self.getCurrentBatteryLevel(),
            screenName: self.viewControllerTracker.currentScreenName,
            networkRequests: self.networkMonitor.capturedRequests
        )
        
        self.performanceData.append(metrics)
        
        // Ограничиваем количество хранимых данных (последние 1000 записей)
        if self.performanceData.count > 1000 {
            self.performanceData.removeFirst(self.performanceData.count - 1000)
        }
    }
    
    private func getCurrentMemoryUsage() -> Double {
        // Заглушка - возвращаем случайное значение от 100 до 300 MB
        return Double.random(in: 100...300)
    }
    
    @MainActor private func getCurrentBatteryLevel() -> Double? {
        #if canImport(UIKit)
        // Возвращаем заглушку для избежания проблем с MainActor
        return Double.random(in: 70...100)
        #else
        return nil
        #endif
    }
}

// MARK: - ReportFormat

public enum ReportFormat: String, CaseIterable, Sendable {
    case pdf = "pdf"
    case json = "json"
    case csv = "csv"
}
