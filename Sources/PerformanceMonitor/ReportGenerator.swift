import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(CoreGraphics)
import CoreGraphics
#endif

/// Генератор отчетов о производительности
final class ReportGenerator {
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private lazy var documentsDirectory: URL = {
        #if targetEnvironment(simulator)
        // В симуляторе используем реальную папку Documents пользователя на Mac
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        return homeDirectory.appendingPathComponent("Documents")
        #else
        // На устройстве используем стандартную папку Documents приложения
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        #endif
    }()
    
    // MARK: - Public Methods
    
    /// Возвращает путь к папке Documents, где создаются отчеты
    public var documentsPath: String {
        return documentsDirectory.path
    }
    
    /// Генерирует отчеты в указанных форматах
    /// - Parameters:
    ///   - analysis: Результат анализа производительности
    ///   - rawData: Сырые данные производительности
    ///   - formats: Форматы отчетов для генерации
    /// - Returns: Массив URL созданных файлов отчетов
    func generateReports(
        analysis: PerformanceAnalysis,
        rawData: [PerformanceData],
        formats: [ReportFormat]
    ) throws -> [URL] {
        var generatedURLs: [URL] = []
        
        let timestamp = DateFormatter.filenameDateFormatter.string(from: Date())
        
        for format in formats {
            let filename = "performance_report_\(timestamp).\(format.rawValue)"
            let url = documentsDirectory.appendingPathComponent(filename)
            
            switch format {
            case .json:
                try generateJSONReport(analysis: analysis, rawData: rawData, to: url)
            case .csv:
                try generateCSVReport(analysis: analysis, rawData: rawData, to: url)
            case .pdf:
                // PDF генерация пока не поддерживается, создаем текстовый отчет
                let textURL = url.deletingPathExtension().appendingPathExtension("txt")
                try generateTextReport(analysis: analysis, rawData: rawData, to: textURL)
                generatedURLs.append(textURL)
                print("📄 Отчет создан: \(textURL.lastPathComponent) (текстовый формат)")
                print("📁 Путь: \(textURL.path)")
                continue
            }
            
            generatedURLs.append(url)
            print("📄 Отчет создан: \(url.lastPathComponent)")
            print("📁 Путь: \(url.path)")
        }
        
        print("✅ Все отчеты созданы в папке Documents: \(documentsDirectory.path)")
        return generatedURLs
    }
    
    // MARK: - Text Report Generation
    
    private func generateTextReport(analysis: PerformanceAnalysis, rawData: [PerformanceData], to url: URL) throws {
        let content = generateReportContent(analysis: analysis, rawData: rawData)
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func generateReportContent(analysis: PerformanceAnalysis, rawData: [PerformanceData]) -> String {
        var content = """
        =====================================
        ОТЧЕТ О ПРОИЗВОДИТЕЛЬНОСТИ
        =====================================
        
        Дата генерации: \(DateFormatter.reportDisplay.string(from: Date()))
        
        📊 СВОДКА
        =========
        • Средний FPS: \(String(format: "%.1f", analysis.averageFPS))
        • Средняя загрузка CPU: \(String(format: "%.1f", analysis.averageCPU))%
        • Среднее потребление памяти: \(String(format: "%.1f", analysis.averageMemory)) MB
        • Пиковое потребление памяти: \(String(format: "%.1f", analysis.peakMemory)) MB
        • Обнаружено аномалий: \(analysis.anomalies.count)
        • Всего точек данных: \(rawData.count)
        
        """
        
        // Аномалии
        if !analysis.anomalies.isEmpty {
            content += """
            ⚠️ ОБНАРУЖЕННЫЕ АНОМАЛИИ
            ========================
            
            """
            
            for (index, anomaly) in analysis.anomalies.prefix(20).enumerated() {
                let timeString = DateFormatter.reportDisplay.string(from: anomaly.timestamp)
                content += "\(index + 1). [\(timeString)] \(anomaly.description)"
                if let screenName = anomaly.screenName {
                    content += " (Экран: \(screenName))"
                }
                content += "\n"
            }
            content += "\n"
        }
        
        // Рекомендации
        content += """
        💡 РЕКОМЕНДАЦИИ
        ===============
        
        """
        
        for (index, recommendation) in analysis.recommendations.enumerated() {
            content += "\(index + 1). \(recommendation)\n"
        }
        content += "\n"
        
        // Производительность по экранам
        if !analysis.screenPerformance.isEmpty {
            content += """
            📱 ПРОИЗВОДИТЕЛЬНОСТЬ ПО ЭКРАНАМ
            ================================
            
            """
            
            for (screenName, performance) in analysis.screenPerformance {
                content += """
                \(screenName):
                • FPS: \(String(format: "%.1f", performance.averageFPS))
                • CPU: \(String(format: "%.1f", performance.averageCPU))%
                • Память: \(String(format: "%.1f", performance.averageMemory)) MB
                • Время на экране: \(String(format: "%.1f", performance.timeSpent))с
                • Аномалий: \(performance.anomaliesCount)
                
                """
            }
        }
        
        content += """
        =====================================
        Конец отчета
        =====================================
        """
        
        return content
    }
    
    // MARK: - JSON Generation
    
    private func generateJSONReport(analysis: PerformanceAnalysis, rawData: [PerformanceData], to url: URL) throws {
        let report = JSONReport(
            generatedAt: Date(),
            analysis: analysis,
            rawData: rawData,
            deviceInfo: DeviceInfo()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(report)
        try data.write(to: url)
    }
    
    // MARK: - CSV Generation
    
    private func generateCSVReport(analysis: PerformanceAnalysis, rawData: [PerformanceData], to url: URL) throws {
        var csvContent = "Timestamp,FPS,CPU_Usage,Memory_Usage,Battery_Level,Screen_Name,Network_Requests_Count\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for data in rawData {
            let timestamp = dateFormatter.string(from: data.timestamp)
            let batteryLevel = data.batteryLevel.map { String($0) } ?? ""
            let screenName = data.screenName?.replacingOccurrences(of: ",", with: ";") ?? ""
            let networkRequestsCount = data.networkRequests.count
            
            csvContent += "\(timestamp),\(data.fps),\(data.cpuUsage),\(data.memoryUsage),\(batteryLevel),\(screenName),\(networkRequestsCount)\n"
        }
        
        try csvContent.write(to: url, atomically: true, encoding: .utf8)
    }
}

// MARK: - Supporting Structures

private struct JSONReport: Codable {
    let generatedAt: Date
    let analysis: PerformanceAnalysis
    let rawData: [PerformanceData]
    let deviceInfo: DeviceInfo
}

private struct ReportSummary: Codable {
    let totalDataPoints: Int
    let timeRange: TimeRange?
    let deviceInfo: DeviceInfo
}

private struct TimeRange: Codable {
    let start: Date
    let end: Date
}

private struct DeviceInfo: Codable {
    let model: String
    let systemName: String
    let systemVersion: String
    let identifierForVendor: String?
    
    init() {
        #if canImport(UIKit)
        // Используем заглушки для избежания проблем с @MainActor
        self.model = "iPhone"
        self.systemName = "iOS"
        self.systemVersion = "15.0"
        self.identifierForVendor = "00000000-0000-0000-0000-000000000000"
        #else
        self.model = "Mac"
        self.systemName = "macOS"
        self.systemVersion = "13.0"
        self.identifierForVendor = nil
        #endif
    }
}

// MARK: - DateFormatter Extensions

private extension DateFormatter {
    static let reportTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
    
    static let reportDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    static let filenameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
} 