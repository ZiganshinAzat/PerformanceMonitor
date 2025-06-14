import XCTest
@testable import PerfomanceMonitor

final class PerfomanceMonitorTests: XCTestCase {
    
    var performanceMonitor: PerformanceMonitor!
    
    override func setUp() {
        super.setUp()
        performanceMonitor = PerformanceMonitor.shared
    }
    
    override func tearDown() {
        performanceMonitor.stop()
        performanceMonitor.clearData()
        super.tearDown()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testPerformanceMonitorSingleton() {
        let monitor1 = PerformanceMonitor.shared
        let monitor2 = PerformanceMonitor.shared
        
        XCTAssertTrue(monitor1 === monitor2, "PerformanceMonitor должен быть синглтоном")
    }
    
    func testStartStop() {
        XCTAssertFalse(performanceMonitor.isRunning, "Мониторинг должен быть остановлен изначально")
        
        performanceMonitor.start()
        XCTAssertTrue(performanceMonitor.isRunning, "Мониторинг должен быть запущен после start()")
        
        performanceMonitor.stop()
        XCTAssertFalse(performanceMonitor.isRunning, "Мониторинг должен быть остановлен после stop()")
    }
    
    func testDataCollection() {
        performanceMonitor.start()
        
        // Принудительно собираем данные
        performanceMonitor.collectMetricsNow()
        performanceMonitor.collectMetricsNow()
        performanceMonitor.collectMetricsNow()
        
        XCTAssertGreaterThan(performanceMonitor.collectedDataCount, 0, "Должны быть собраны данные")
        
        let currentMetrics = performanceMonitor.getCurrentMetrics()
        XCTAssertNotNil(currentMetrics, "Текущие метрики должны быть доступны")
        
        if let metrics = currentMetrics {
            XCTAssertGreaterThanOrEqual(metrics.fps, 0, "FPS должен быть неотрицательным")
            XCTAssertGreaterThanOrEqual(metrics.cpuUsage, 0, "CPU usage должен быть неотрицательным")
            XCTAssertGreaterThan(metrics.memoryUsage, 0, "Memory usage должен быть положительным")
        }
    }
    
    func testClearData() {
        performanceMonitor.start()
        
        // Принудительно собираем данные
        performanceMonitor.collectMetricsNow()
        performanceMonitor.collectMetricsNow()
        
        XCTAssertGreaterThan(performanceMonitor.collectedDataCount, 0, "Должны быть собраны данные")
        
        performanceMonitor.clearData()
        
        XCTAssertEqual(performanceMonitor.collectedDataCount, 0, "Данные должны быть очищены")
    }
    
    // MARK: - Thresholds Tests
    
    func testCustomThresholds() {
        let customThresholds = PerformanceThresholds(
            minFPS: 30.0,
            maxCPU: 90.0,
            maxMemory: 300.0,
            maxNetworkDuration: 10.0,
            memorySpikeFactor: 2.0
        )
        
        performanceMonitor.start(interval: 0.5, thresholds: customThresholds)
        XCTAssertTrue(performanceMonitor.isRunning, "Мониторинг должен запуститься с кастомными порогами")
    }
    
    func testDefaultThresholds() {
        let defaultThresholds = PerformanceThresholds.default
        
        XCTAssertEqual(defaultThresholds.minFPS, 50.0)
        XCTAssertEqual(defaultThresholds.maxCPU, 80.0)
        XCTAssertEqual(defaultThresholds.maxMemory, 200.0)
        XCTAssertEqual(defaultThresholds.maxNetworkDuration, 5.0)
        XCTAssertEqual(defaultThresholds.memorySpikeFactor, 1.5)
    }
    
    // MARK: - Report Generation Tests
    
    func testReportGeneration() {
        performanceMonitor.start()
        
        // Ждем сбора данных
        let dataExpectation = XCTestExpectation(description: "Сбор данных")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dataExpectation.fulfill()
        }
        
        wait(for: [dataExpectation], timeout: 2.0)
        
        let reportExpectation = XCTestExpectation(description: "Генерация отчета")
        
        performanceMonitor.generateReport(formats: [.json]) { result in
            switch result {
            case .success(let urls):
                XCTAssertFalse(urls.isEmpty, "Должен быть сгенерирован хотя бы один файл")
                XCTAssertTrue(urls.first?.pathExtension == "json", "Должен быть создан JSON файл")
                reportExpectation.fulfill()
            case .failure(let error):
                XCTFail("Генерация отчета не должна завершаться ошибкой: \(error)")
                reportExpectation.fulfill()
            }
        }
        
        wait(for: [reportExpectation], timeout: 5.0)
    }
    
    // MARK: - Performance Data Tests
    
    func testPerformanceDataModel() {
        let networkRequest = NetworkRequestData(
            url: "https://api.example.com/test",
            method: "GET",
            statusCode: 200,
            duration: 1.5,
            requestSize: 1024,
            responseSize: 2048
        )
        
        let performanceData = PerformanceData(
            fps: 60.0,
            cpuUsage: 45.0,
            memoryUsage: 128.0,
            batteryLevel: 85.0,
            screenName: "TestViewController",
            networkRequests: [networkRequest]
        )
        
        XCTAssertEqual(performanceData.fps, 60.0)
        XCTAssertEqual(performanceData.cpuUsage, 45.0)
        XCTAssertEqual(performanceData.memoryUsage, 128.0)
        XCTAssertEqual(performanceData.batteryLevel, 85.0)
        XCTAssertEqual(performanceData.screenName, "TestViewController")
        XCTAssertEqual(performanceData.networkRequests.count, 1)
        XCTAssertEqual(performanceData.networkRequests.first?.url, "https://api.example.com/test")
    }
    
    func testPerformanceAnomalyModel() {
        let anomaly = PerformanceAnomaly(
            type: .lowFPS,
            timestamp: Date(),
            value: 25.0,
            threshold: 50.0,
            screenName: "TestScreen",
            description: "Низкий FPS обнаружен"
        )
        
        XCTAssertEqual(anomaly.type, .lowFPS)
        XCTAssertEqual(anomaly.value, 25.0)
        XCTAssertEqual(anomaly.threshold, 50.0)
        XCTAssertEqual(anomaly.screenName, "TestScreen")
        XCTAssertEqual(anomaly.description, "Низкий FPS обнаружен")
    }
    
    // MARK: - Edge Cases Tests
    
    func testMultipleStartCalls() {
        performanceMonitor.start()
        XCTAssertTrue(performanceMonitor.isRunning)
        
        // Повторный вызов start() не должен вызывать проблем
        performanceMonitor.start()
        XCTAssertTrue(performanceMonitor.isRunning)
    }
    
    func testMultipleStopCalls() {
        performanceMonitor.start()
        performanceMonitor.stop()
        XCTAssertFalse(performanceMonitor.isRunning)
        
        // Повторный вызов stop() не должен вызывать проблем
        performanceMonitor.stop()
        XCTAssertFalse(performanceMonitor.isRunning)
    }
    
    func testGetCurrentMetricsWhenStopped() {
        XCTAssertFalse(performanceMonitor.isRunning)
        let metrics = performanceMonitor.getCurrentMetrics()
        XCTAssertNil(metrics, "Метрики должны быть nil когда мониторинг остановлен")
    }
} 