import UIKit
import PerformanceMonitor

class DemoViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var metricsLabel: UILabel!
    @IBOutlet weak var startDemoButton: UIButton!
    @IBOutlet weak var stopDemoButton: UIButton!
    @IBOutlet weak var testSpecificButton: UIButton!
    @IBOutlet weak var currentMetricsButton: UIButton!
    
    private let demo = PerformanceMonitorDemo()
    private var metricsTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startMetricsDisplay()
    }
    
    private func setupUI() {
        title = "PerformanceMonitor Demo"
        
        // Настройка кнопок
        startDemoButton.setTitle("🚀 Запустить полную демонстрацию", for: .normal)
        stopDemoButton.setTitle("🛑 Остановить демонстрацию", for: .normal)
        testSpecificButton.setTitle("🧪 Тестировать низкий FPS", for: .normal)
        currentMetricsButton.setTitle("📊 Показать текущие метрики", for: .normal)
        
        // Настройка лейблов
        statusLabel.text = "Готов к демонстрации"
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        
        metricsLabel.text = "Метрики будут отображаться здесь"
        metricsLabel.numberOfLines = 0
        metricsLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        
        stopDemoButton.isEnabled = false
    }
    
    private func startMetricsDisplay() {
        metricsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateMetricsDisplay()
        }
    }
    
    private func updateMetricsDisplay() {
        if PerformanceMonitor.shared.isRunning,
           let metrics = PerformanceMonitor.shared.getCurrentMetrics() {
            
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            
            let metricsText = """
            📊 ТЕКУЩИЕ МЕТРИКИ:
            ⏰ Время: \(formatter.string(from: metrics.timestamp))
            🎮 FPS: \(String(format: "%.1f", metrics.fps))
            ⚡ CPU: \(String(format: "%.1f", metrics.cpuUsage))%
            💾 Память: \(String(format: "%.1f", metrics.memoryUsage)) MB
            🔋 Батарея: \(metrics.batteryLevel?.description ?? "N/A")%
            📱 Экран: \(metrics.screenName ?? "Неизвестно")
            🌐 Сетевые запросы: \(metrics.networkRequests.count)
            
            📈 Всего данных: \(PerformanceMonitor.shared.collectedDataCount)
            """
            
            metricsLabel.text = metricsText
        } else {
            metricsLabel.text = "PerformanceMonitor не активен"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func startFullDemo(_ sender: UIButton) {
        statusLabel.text = "🚀 Запускается полная демонстрация...\nБудут показаны все типы аномалий"
        
        startDemoButton.isEnabled = false
        stopDemoButton.isEnabled = true
        
        demo.startFullDemo()
        
        // Через 35 секунд включаем кнопку обратно
        DispatchQueue.main.asyncAfter(deadline: .now() + 35.0) {
            self.startDemoButton.isEnabled = true
            self.stopDemoButton.isEnabled = false
            self.statusLabel.text = "✅ Демонстрация завершена! Проверьте консоль для подробностей"
        }
    }
    
    @IBAction func stopDemo(_ sender: UIButton) {
        demo.stopDemo()
        startDemoButton.isEnabled = true
        stopDemoButton.isEnabled = false
        statusLabel.text = "🛑 Демонстрация остановлена"
    }
    
    @IBAction func testSpecificAnomaly(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Выберите тип аномалии для тестирования",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        // Добавляем опции для каждого типа аномалии
        for anomalyType in AnomalyType.allCases {
            let action = UIAlertAction(
                title: getDisplayName(for: anomalyType),
                style: .default
            ) { _ in
                self.testAnomaly(anomalyType)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @IBAction func showCurrentMetrics(_ sender: UIButton) {
        if PerformanceMonitor.shared.isRunning {
            let analysis = PerformanceMonitor.shared.getPerformanceAnalysis()
            
            let message = """
            📊 Собрано данных: \(analysis.totalDataPoints)
            🎮 Средний FPS: \(String(format: "%.1f", analysis.averageFPS))
            ⚡ Средний CPU: \(String(format: "%.1f", analysis.averageCPU))%
            💾 Средняя память: \(String(format: "%.1f", analysis.averageMemory)) MB
            🚨 Аномалий: \(analysis.anomalies.count)
            🏆 Оценка: \(analysis.overallScore)/100
            """
            
            let alert = UIAlertController(
                title: "Анализ производительности",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            // Запускаем базовый мониторинг
            PerformanceMonitor.shared.start()
            statusLabel.text = "▶️ Базовый мониторинг запущен"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.showCurrentMetrics(sender)
            }
        }
    }
    
    private func testAnomaly(_ type: AnomalyType) {
        statusLabel.text = "🧪 Тестируется: \(getDisplayName(for: type))"
        
        startDemoButton.isEnabled = false
        stopDemoButton.isEnabled = true
        
        demo.testSpecificAnomaly(type)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
            self.startDemoButton.isEnabled = true
            self.stopDemoButton.isEnabled = false
            self.statusLabel.text = "✅ Тест \(self.getDisplayName(for: type)) завершен"
        }
    }
    
    private func getDisplayName(for anomalyType: AnomalyType) -> String {
        switch anomalyType {
        case .lowFPS: return "🎮 Низкий FPS"
        case .highCPU: return "⚡ Высокий CPU"
        case .highMemory: return "💾 Высокая память"
        case .memorySpike: return "🔥 Скачки памяти"
        case .slowNetworkRequest: return "🌐 Медленная сеть"
        case .batteryDrain: return "🔋 Разрядка батареи"
        }
    }
    
    deinit {
        metricsTimer?.invalidate()
        demo.stopDemo()
    }
}

// MARK: - Storyboard Setup
/*
Для использования этого ViewController в Storyboard:

1. Создайте новый ViewController в Interface Builder
2. Установите класс как DemoViewController
3. Добавьте следующие UI элементы и подключите к аутлетам:
   - UILabel для statusLabel (многострочный, по центру)
   - UILabel для metricsLabel (многострочный, моноширинный шрифт)
   - UIButton для startDemoButton
   - UIButton для stopDemoButton
   - UIButton для testSpecificButton
   - UIButton для currentMetricsButton

4. Подключите действия кнопок к соответствующим IBAction методам

5. Добавьте Auto Layout ограничения для правильного отображения на всех устройствах
*/

// MARK: - Программное создание UI
extension DemoViewController {
    
    /// Создает UI программно, если не используется Storyboard
    func setupProgrammaticUI() {
        view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        let contentView = UIView()
        
        // Настройка scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Создание элементов UI
        statusLabel = UILabel()
        metricsLabel = UILabel()
        startDemoButton = UIButton(type: .system)
        stopDemoButton = UIButton(type: .system)
        testSpecificButton = UIButton(type: .system)
        currentMetricsButton = UIButton(type: .system)
        
        // Настройка элементов
        [statusLabel, metricsLabel, startDemoButton, stopDemoButton, testSpecificButton, currentMetricsButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Настройка кнопок
        [startDemoButton, stopDemoButton, testSpecificButton, currentMetricsButton].forEach { button in
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        }
        
        // Настройка лейблов
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        metricsLabel.numberOfLines = 0
        metricsLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        metricsLabel.backgroundColor = .systemGray6
        metricsLabel.layer.cornerRadius = 8
        metricsLabel.layer.masksToBounds = true
        
        // Добавление действий
        startDemoButton.addTarget(self, action: #selector(startFullDemo(_:)), for: .touchUpInside)
        stopDemoButton.addTarget(self, action: #selector(stopDemo(_:)), for: .touchUpInside)
        testSpecificButton.addTarget(self, action: #selector(testSpecificAnomaly(_:)), for: .touchUpInside)
        currentMetricsButton.addTarget(self, action: #selector(showCurrentMetrics(_:)), for: .touchUpInside)
        
        // Auto Layout
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // UI Elements
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            startDemoButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            startDemoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            startDemoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            startDemoButton.heightAnchor.constraint(equalToConstant: 50),
            
            stopDemoButton.topAnchor.constraint(equalTo: startDemoButton.bottomAnchor, constant: 12),
            stopDemoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stopDemoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stopDemoButton.heightAnchor.constraint(equalToConstant: 50),
            
            testSpecificButton.topAnchor.constraint(equalTo: stopDemoButton.bottomAnchor, constant: 12),
            testSpecificButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            testSpecificButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            testSpecificButton.heightAnchor.constraint(equalToConstant: 50),
            
            currentMetricsButton.topAnchor.constraint(equalTo: testSpecificButton.bottomAnchor, constant: 12),
            currentMetricsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            currentMetricsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            currentMetricsButton.heightAnchor.constraint(equalToConstant: 50),
            
            metricsLabel.topAnchor.constraint(equalTo: currentMetricsButton.bottomAnchor, constant: 20),
            metricsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            metricsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            metricsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            metricsLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }
} 