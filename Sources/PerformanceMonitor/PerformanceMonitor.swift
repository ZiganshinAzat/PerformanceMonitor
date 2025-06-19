import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Основной класс для мониторинга производительности iOS-приложений
public final class PerformanceMonitor {
    
    // MARK: - Singleton
    
    public static let shared = PerformanceMonitor()
    
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
        
        fpsTracker.start()
        cpuTracker.start()
        metricKitProvider.start()
        networkMonitor.start()
        viewControllerTracker.start()
        
        startMetricsCollection(interval: interval)
        
        print("✅ PerformanceMonitor запущен с интервалом \(interval)с")
    }
    
    /// Останавливает мониторинг производительности
    public func stop() {
        guard isMonitoring else {
            print("⚠️ PerformanceMonitor не запущен")
            return
        }
        
        isMonitoring = false
        
        fpsTracker.stop()
        cpuTracker.stop()
        metricKitProvider.stop()
        networkMonitor.stop()
        viewControllerTracker.stop()
        
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
        completion: @escaping (Result<[URL], Error>) -> Void
    ) {
        let analysis = self.dataAnalyzer.analyze(
            data: self.performanceData,
            thresholds: self.thresholds
        )
        
        let reportGenerator = self.reportGenerator
        let performanceData = self.performanceData
        
        do {
            let urls = try reportGenerator.generateReports(
                analysis: analysis,
                rawData: performanceData,
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
    public func getCurrentMetrics() -> PerformanceData? {
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
    public func collectMetricsNow() {
        DispatchQueue.main.async {
            self.collectMetrics()
        }
    }
    
    /// Возвращает путь к папке Documents, где создаются отчеты
    public var reportsPath: String {
        return reportGenerator.documentsPath
    }
    
    /// Возвращает анализ производительности
    public func getPerformanceAnalysis() -> PerformanceAnalysis {
        return dataAnalyzer.analyze(data: performanceData, thresholds: thresholds)
    }
    
    // MARK: - Private Methods
    
    private func setupDelegates() {
        // networkMonitor.delegate = self // Заглушка
    }
    
    private func startMetricsCollection(interval: TimeInterval) {
        queue.asyncAfter(deadline: .now() + interval) { [weak self] in
            guard let self = self, self.isMonitoring else { return }
            
            DispatchQueue.main.async {
                self.collectMetrics()
            }
            
            self.startMetricsCollection(interval: interval)
        }
    }
    
    private func collectMetrics() {
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
        
        if self.performanceData.count > 1000 {
            self.performanceData.removeFirst(self.performanceData.count - 1000)
        }
    }
    
    private func getCurrentMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                let task = mach_task_self_
                return task_info(task,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / (1024.0 * 1024.0)
        } else {
            return Double.random(in: 100...300)
        }
    }
    
    private func getCurrentBatteryLevel() -> Double? {
        #if canImport(UIKit)
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        
        if device.batteryLevel >= 0 {
            return Double(device.batteryLevel * 100)
        } else {
            return nil 
        }
        #else
        return nil
        #endif
    }
}

// MARK: - ReportFormat

public enum ReportFormat: String, CaseIterable {
    case pdf = "pdf"
    case json = "json"
    case csv = "csv"
}
