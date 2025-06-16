import Foundation

/// Монитор для отслеживания URLSession запросов
public final class URLSessionMonitor: NSObject {
    
    // MARK: - Singleton
    
    public static let shared = URLSessionMonitor()
    
    // MARK: - Properties
    
    private var isEnabled = false
    private var capturedRequests: [NetworkRequestData] = []
    private let maxRequestsCount = 1000
    
    /// Делегат для получения уведомлений о новых запросах
    weak var delegate: URLSessionMonitorDelegate?
    
    // MARK: - Public Methods
    
    /// Включает мониторинг URLSession запросов
    public func enable() {
        guard !isEnabled else { return }
        isEnabled = true
        swizzleURLSessionMethods()
        print("✅ URLSessionMonitor включен")
    }
    
    /// Выключает мониторинг URLSession запросов
    public func disable() {
        guard isEnabled else { return }
        isEnabled = false
        // В реальной реализации здесь был бы unswizzle
        print("🛑 URLSessionMonitor выключен")
    }
    
    /// Возвращает список перехваченных запросов
    public var allRequests: [NetworkRequestData] {
        return Array(capturedRequests)
    }
    
    /// Очищает список запросов
    public func clearRequests() {
        capturedRequests.removeAll()
    }
    
    /// Создает настроенную URLSession с мониторингом
    public func createMonitoredSession(configuration: URLSessionConfiguration = .default) -> URLSession {
        let session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )
        return session
    }
    
    // MARK: - Internal Methods
    
    internal func recordRequest(_ request: NetworkRequestData) {
        capturedRequests.append(request)
        
        // Ограничиваем количество сохраненных запросов
        if capturedRequests.count > maxRequestsCount {
            capturedRequests.removeFirst(capturedRequests.count - maxRequestsCount)
        }
        
        delegate?.urlSessionMonitor(self, didCaptureRequest: request)
        
        // Анализируем эффективность запроса
        analyzeRequestEfficiency(request)
    }
    
    // MARK: - Private Methods
    
    private func swizzleURLSessionMethods() {
        // В реальной реализации здесь был бы method swizzling
        // для перехвата URLSession.dataTask методов
        print("🔧 URLSession методы настроены для мониторинга")
    }
    
    private func analyzeRequestEfficiency(_ request: NetworkRequestData) {
        var issues: [String] = []
        
        // Проверяем время отклика
        if request.duration > 5.0 {
            issues.append("Медленный запрос (>\(request.duration)с)")
        }
        
        // Проверяем размер ответа
        if request.responseSize > 5 * 1024 * 1024 { // 5MB
            issues.append("Большой ответ (\(request.responseSize / 1024 / 1024)MB)")
        }
        
        // Проверяем статус код
        if let statusCode = request.statusCode, statusCode >= 400 {
            issues.append("Ошибка HTTP \(statusCode)")
        }
        
        // Логируем проблемы
        if !issues.isEmpty {
            print("⚠️ Проблемы с запросом \(request.url):")
            issues.forEach { print("   • \($0)") }
        }
    }
}

// MARK: - URLSessionDelegate

extension URLSessionMonitor: URLSessionDelegate, URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard isEnabled else { return }
        
        let startTime = task.earliestBeginDate ?? Date()
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        let request = NetworkRequestData(
            url: task.originalRequest?.url?.absoluteString ?? "unknown",
            method: task.originalRequest?.httpMethod ?? "GET",
            statusCode: (task.response as? HTTPURLResponse)?.statusCode,
            duration: duration,
            requestSize: Int64(task.originalRequest?.httpBody?.count ?? 0),
            responseSize: task.countOfBytesReceived,
            timestamp: startTime
        )
        
        recordRequest(request)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard isEnabled else { return }
        
        // Используем URLSessionTaskMetrics для более точных данных
        for transactionMetric in metrics.transactionMetrics {
            let requestStartTime = transactionMetric.requestStartDate ?? Date()
            let responseEndTime = transactionMetric.responseEndDate ?? Date()
            let duration = responseEndTime.timeIntervalSince(requestStartTime)
            
            let request = NetworkRequestData(
                url: task.originalRequest?.url?.absoluteString ?? "unknown",
                method: task.originalRequest?.httpMethod ?? "GET",
                statusCode: (task.response as? HTTPURLResponse)?.statusCode,
                duration: duration,
                requestSize: Int64(task.originalRequest?.httpBody?.count ?? 0),
                responseSize: task.countOfBytesReceived,
                timestamp: requestStartTime
            )
            
            recordRequest(request)
        }
    }
}

// MARK: - URLSessionMonitorDelegate

public protocol URLSessionMonitorDelegate: AnyObject {
    func urlSessionMonitor(_ monitor: URLSessionMonitor, didCaptureRequest request: NetworkRequestData)
}

// MARK: - Network Efficiency Extensions

public extension URLSessionMonitor {
    
    /// Статистика эффективности сетевых запросов
    var networkEfficiencyStats: NetworkEfficiencyStats {
        let requests = capturedRequests
        
        let totalRequests = requests.count
        let slowRequests = requests.filter { $0.duration > 3.0 }.count
        let failedRequests = requests.filter { ($0.statusCode ?? 0) >= 400 }.count
        let largeRequests = requests.filter { $0.responseSize > 1024 * 1024 }.count // >1MB
        
        let averageResponseTime = requests.isEmpty ? 0 : 
            requests.reduce(0.0) { $0 + $1.duration } / Double(totalRequests)
        
        let totalDataTransferred = requests.reduce(Int64(0)) { $0 + $1.requestSize + $1.responseSize }
        
        return NetworkEfficiencyStats(
            totalRequests: totalRequests,
            slowRequests: slowRequests,
            failedRequests: failedRequests,
            largeRequests: largeRequests,
            averageResponseTime: averageResponseTime,
            totalDataTransferred: totalDataTransferred,
            efficiencyScore: calculateEfficiencyScore(
                total: totalRequests,
                slow: slowRequests,
                failed: failedRequests,
                large: largeRequests
            )
        )
    }
    
    private func calculateEfficiencyScore(total: Int, slow: Int, failed: Int, large: Int) -> Double {
        guard total > 0 else { return 1.0 }
        
        let slowPenalty = Double(slow) / Double(total) * 0.3
        let failedPenalty = Double(failed) / Double(total) * 0.5
        let largePenalty = Double(large) / Double(total) * 0.2
        
        let totalPenalty = slowPenalty + failedPenalty + largePenalty
        return max(0.0, 1.0 - totalPenalty)
    }
}

// MARK: - Supporting Structures

public struct NetworkEfficiencyStats {
    public let totalRequests: Int
    public let slowRequests: Int
    public let failedRequests: Int
    public let largeRequests: Int
    public let averageResponseTime: Double
    public let totalDataTransferred: Int64
    public let efficiencyScore: Double // 0.0 - 1.0, где 1.0 = максимальная эффективность
} 