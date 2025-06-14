import Foundation

/// Монитор сетевых запросов (заглушка)
final class NetworkMonitor {
    
    // MARK: - Properties
    
    private var isStarted = false
    private var networkRequests: [NetworkRequestData] = []
    
    // MARK: - Public Properties
    
    /// Список перехваченных сетевых запросов
    var capturedRequests: [NetworkRequestData] {
        return Array(networkRequests)
    }
    
    // MARK: - Public Methods
    
    /// Запускает мониторинг сетевых запросов
    func start() {
        guard !isStarted else {
            print("⚠️ NetworkMonitor уже запущен")
            return
        }
        
        isStarted = true
        print("✅ NetworkMonitor запущен (заглушка)")
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
        
        networkRequests.append(testRequest)
    }
} 