import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Генератор отчетов о производительности
final class ReportGenerator {
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private lazy var documentsDirectory: URL = {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    private lazy var reportsDirectory: URL = {
        let url = documentsDirectory.appendingPathComponent("PerformanceReports")
        try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()
    
    // MARK: - Public Methods
    
    /// Генерирует отчеты в указанных форматах
    /// - Parameters:
    ///   - analysis: Результат анализа производительности
    ///   - rawData: Исходные данные производительности
    ///   - formats: Форматы отчетов для генерации
    /// - Returns: Массив URL созданных файлов
    func generateReports(
        analysis: PerformanceAnalysis,
        rawData: [PerformanceData],
        formats: [ReportFormat]
    ) throws -> [URL] {
        var generatedFiles: [URL] = []
        let timestamp = DateFormatter.reportTimestamp.string(from: Date())
        
        for format in formats {
            let fileName = "PerformanceReport_\(timestamp).\(format.rawValue)"
            let fileURL = reportsDirectory.appendingPathComponent(fileName)
            
            switch format {
            case .pdf:
                try generateTextReport(analysis: analysis, rawData: rawData, to: fileURL, format: "PDF")
            case .json:
                try generateJSONReport(analysis: analysis, rawData: rawData, to: fileURL)
            case .csv:
                try generateCSVReport(rawData: rawData, to: fileURL)
            }
            
            generatedFiles.append(fileURL)
        }
        
        print("📄 Сгенерированы отчеты: \(generatedFiles.map { $0.lastPathComponent }.joined(separator: ", "))")
        return generatedFiles
    }
    
    // MARK: - Text Report Generation (вместо PDF)
    
    private func generateTextReport(analysis: PerformanceAnalysis, rawData: [PerformanceData], to url: URL, format: String) throws {
        var content = """
        =====================================
        ОТЧЕТ О ПРОИЗВОДИТЕЛЬНОСТИ (\(format))
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
        
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    
    // MARK: - JSON Generation
    
    private func generateJSONReport(analysis: PerformanceAnalysis, rawData: [PerformanceData], to url: URL) throws {
        let report = JSONReport(
            generatedAt: Date(),
            analysis: analysis,
            rawData: rawData,
            summary: ReportSummary(
                totalDataPoints: rawData.count,
                timeRange: rawData.isEmpty ? nil : TimeRange(
                    start: rawData.first!.timestamp,
                    end: rawData.last!.timestamp
                ),
                deviceInfo: DeviceInfo()
            )
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let jsonData = try encoder.encode(report)
        try jsonData.write(to: url)
    }
    
    // MARK: - CSV Generation
    
    private func generateCSVReport(rawData: [PerformanceData], to url: URL) throws {
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
    let summary: ReportSummary
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
        let device = UIDevice.current
        self.model = device.model
        self.systemName = device.systemName
        self.systemVersion = device.systemVersion
        self.identifierForVendor = device.identifierForVendor?.uuidString
        #else
        self.model = "Unknown"
        self.systemName = "Unknown"
        self.systemVersion = "Unknown"
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
} 