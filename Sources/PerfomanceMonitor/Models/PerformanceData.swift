import Foundation

// MARK: - Основные структуры данных

/// Основная структура для хранения всех метрик производительности
public struct PerformanceData: Codable {
    public let timestamp: Date
    public let fps: Double
    public let cpuUsage: Double
    public let memoryUsage: Double // в MB
    public let batteryLevel: Double? // в процентах
    public let screenName: String?
    public let networkRequests: [NetworkRequestData]
    
    public init(
        timestamp: Date = Date(),
        fps: Double,
        cpuUsage: Double,
        memoryUsage: Double,
        batteryLevel: Double? = nil,
        screenName: String? = nil,
        networkRequests: [NetworkRequestData] = []
    ) {
        self.timestamp = timestamp
        self.fps = fps
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.batteryLevel = batteryLevel
        self.screenName = screenName
        self.networkRequests = networkRequests
    }
}

/// Данные сетевого запроса
public struct NetworkRequestData: Codable, Sendable {
    public let url: String
    public let method: String
    public let statusCode: Int?
    public let duration: TimeInterval
    public let requestSize: Int64
    public let responseSize: Int64
    public let timestamp: Date
    
    public init(
        url: String,
        method: String,
        statusCode: Int? = nil,
        duration: TimeInterval,
        requestSize: Int64,
        responseSize: Int64,
        timestamp: Date = Date()
    ) {
        self.url = url
        self.method = method
        self.statusCode = statusCode
        self.duration = duration
        self.requestSize = requestSize
        self.responseSize = responseSize
        self.timestamp = timestamp
    }
}

/// Результат анализа производительности
public struct PerformanceAnalysis: Codable {
    public let averageFPS: Double
    public let averageCPU: Double
    public let averageMemory: Double
    public let peakMemory: Double
    public let anomalies: [PerformanceAnomaly]
    public let recommendations: [String]
    public let screenPerformance: [String: ScreenPerformance]
    
    public init(
        averageFPS: Double,
        averageCPU: Double,
        averageMemory: Double,
        peakMemory: Double,
        anomalies: [PerformanceAnomaly],
        recommendations: [String],
        screenPerformance: [String: ScreenPerformance]
    ) {
        self.averageFPS = averageFPS
        self.averageCPU = averageCPU
        self.averageMemory = averageMemory
        self.peakMemory = peakMemory
        self.anomalies = anomalies
        self.recommendations = recommendations
        self.screenPerformance = screenPerformance
    }
}

/// Аномалия производительности
public struct PerformanceAnomaly: Codable {
    public let type: AnomalyType
    public let timestamp: Date
    public let value: Double
    public let threshold: Double
    public let screenName: String?
    public let description: String
    
    public init(
        type: AnomalyType,
        timestamp: Date,
        value: Double,
        threshold: Double,
        screenName: String? = nil,
        description: String
    ) {
        self.type = type
        self.timestamp = timestamp
        self.value = value
        self.threshold = threshold
        self.screenName = screenName
        self.description = description
    }
}

/// Типы аномалий
public enum AnomalyType: String, Codable, CaseIterable {
    case lowFPS = "low_fps"
    case highCPU = "high_cpu"
    case highMemory = "high_memory"
    case memorySpike = "memory_spike"
    case slowNetworkRequest = "slow_network"
    case batteryDrain = "battery_drain"
}

/// Производительность экрана
public struct ScreenPerformance: Codable {
    public let screenName: String
    public let averageFPS: Double
    public let averageCPU: Double
    public let averageMemory: Double
    public let timeSpent: TimeInterval
    public let anomaliesCount: Int
    
    public init(
        screenName: String,
        averageFPS: Double,
        averageCPU: Double,
        averageMemory: Double,
        timeSpent: TimeInterval,
        anomaliesCount: Int
    ) {
        self.screenName = screenName
        self.averageFPS = averageFPS
        self.averageCPU = averageCPU
        self.averageMemory = averageMemory
        self.timeSpent = timeSpent
        self.anomaliesCount = anomaliesCount
    }
}

/// Конфигурация пороговых значений
public struct PerformanceThresholds: Sendable {
    public let minFPS: Double
    public let maxCPU: Double
    public let maxMemory: Double
    public let maxNetworkDuration: TimeInterval
    public let memorySpikeFactor: Double
    
    public static let `default` = PerformanceThresholds(
        minFPS: 50.0,
        maxCPU: 80.0,
        maxMemory: 200.0, // MB
        maxNetworkDuration: 5.0, // секунды
        memorySpikeFactor: 1.5 // 50% увеличение считается скачком
    )
    
    public init(
        minFPS: Double = 50.0,
        maxCPU: Double = 80.0,
        maxMemory: Double = 200.0,
        maxNetworkDuration: TimeInterval = 5.0,
        memorySpikeFactor: Double = 1.5
    ) {
        self.minFPS = minFPS
        self.maxCPU = maxCPU
        self.maxMemory = maxMemory
        self.maxNetworkDuration = maxNetworkDuration
        self.memorySpikeFactor = memorySpikeFactor
    }
} 