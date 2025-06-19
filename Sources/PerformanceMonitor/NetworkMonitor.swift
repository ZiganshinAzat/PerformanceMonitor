import Foundation

/// Монитор сетевых запросов
final class NetworkMonitor {
    
    // MARK: - Properties
    
    private var isStarted = false
    private var networkRequests: [NetworkRequestData] = []
    private let maxRequestsCount = 1000
    
    // MARK: - Public Properties
    
    /// Список перехваченных сетевых запросов
    var capturedRequests: [NetworkRequestData] {
        return Array(networkRequests)
    }
    
    /// Статистика сетевых запросов
    var networkStatistics: NetworkStatistics {
        return calculateNetworkStatistics()
    }
    
    // MARK: - Public Methods
    
    /// Запускает мониторинг сетевых запросов
    func start() {
        guard !isStarted else {
            print("⚠️ NetworkMonitor уже запущен")
            return
        }
        
        isStarted = true
        
        generateSampleRequests()
        
        print("✅ NetworkMonitor запущен с демонстрационными данными")
    }
    
    /// Останавливает мониторинг сетевых запросов
    func stop() {
        guard isStarted else {
            print("⚠️ NetworkMonitor не запущен")
            return
        }
        
        isStarted = false
        networkRequests.removeAll()
        
        print("🛑 NetworkMonitor остановлен")
    }
    
    /// Очищает список перехваченных запросов
    func clearRequests() {
        networkRequests.removeAll()
    }
    
    /// Добавляет перехваченный сетевой запрос
    internal func addNetworkRequest(_ request: NetworkRequestData) {
        networkRequests.append(request)
        
        if networkRequests.count > maxRequestsCount {
            networkRequests.removeFirst(networkRequests.count - maxRequestsCount)
        }
        
        print("🌐 Перехвачен запрос: \(request.method) \(request.url) (\(request.statusCode ?? 0))")
    }
    
    /// Добавляет тестовый сетевой запрос (для демонстрации)
    func addTestRequest() {
        let testRequest = NetworkRequestData(
            url: "https://api.example.com/test",
            method: "GET",
            statusCode: 200,
            duration: Double.random(in: 0.1...2.0),
            requestSize: Int64.random(in: 100...1000),
            responseSize: Int64.random(in: 500...5000),
            timestamp: Date()
        )
        
        addNetworkRequest(testRequest)
    }
    
    // MARK: - Private Methods
    
    private func generateSampleRequests() {
        let sampleURLs = [
            "https://api.github.com/users",
            "https://jsonplaceholder.typicode.com/posts",
            "https://httpbin.org/get",
            "https://api.openweathermap.org/data",
            "https://reqres.in/api/users"
        ]
        
        let methods = ["GET", "POST", "PUT", "DELETE"]
        let statusCodes = [200, 201, 400, 404, 500]
        
        for i in 0..<10 {
            let request = NetworkRequestData(
                url: sampleURLs.randomElement()! + "/\(i)",
                method: methods.randomElement()!,
                statusCode: statusCodes.randomElement()!,
                duration: Double.random(in: 0.1...3.0),
                requestSize: Int64.random(in: 100...2000),
                responseSize: Int64.random(in: 500...10000),
                timestamp: Date().addingTimeInterval(-Double.random(in: 0...3600))
            )
            
            networkRequests.append(request)
        }
    }
    
    private func calculateNetworkStatistics() -> NetworkStatistics {
        guard !networkRequests.isEmpty else {
            return NetworkStatistics(
                totalRequests: 0,
                successfulRequests: 0,
                failedRequests: 0,
                averageResponseTime: 0,
                totalDataTransferred: 0,
                mostFrequentDomain: nil
            )
        }
        
        let totalRequests = networkRequests.count
        let successfulRequests = networkRequests.filter { ($0.statusCode ?? 0) >= 200 && ($0.statusCode ?? 0) < 300 }.count
        let failedRequests = totalRequests - successfulRequests
        
        let averageResponseTime = networkRequests.reduce(0.0) { $0 + $1.duration } / Double(totalRequests)
        let totalDataTransferred = networkRequests.reduce(Int64(0)) { $0 + $1.requestSize + $1.responseSize }
        
        let domains = networkRequests.compactMap { URL(string: $0.url)?.host }
        let domainCounts = Dictionary(grouping: domains, by: { $0 }).mapValues { $0.count }
        let mostFrequentDomain = domainCounts.max(by: { $0.value < $1.value })?.key
        
        return NetworkStatistics(
            totalRequests: totalRequests,
            successfulRequests: successfulRequests,
            failedRequests: failedRequests,
            averageResponseTime: averageResponseTime,
            totalDataTransferred: totalDataTransferred,
            mostFrequentDomain: mostFrequentDomain
        )
    }
}

// MARK: - Supporting Structures

struct NetworkStatistics {
    let totalRequests: Int
    let successfulRequests: Int
    let failedRequests: Int
    let averageResponseTime: Double
    let totalDataTransferred: Int64
    let mostFrequentDomain: String?
} 
