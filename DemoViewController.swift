import UIKit
import PerformanceMonitor

class DemoViewController: UIViewController {
    
    // UI элементы создаются программно
    private let statusLabel = UILabel()
    private let metricsLabel = UILabel()
    private let startDemoButton = UIButton(type: .system)
    private let stopDemoButton = UIButton(type: .system)
    private let testSpecificButton = UIButton(type: .system)
    private let currentMetricsButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let demo = PerformanceMonitorDemo()
    private var metricsTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        startMetricsDisplay()
    }
    
    private func setupUI() {
        title = "PerformanceMonitor Demo"
        view.backgroundColor = .systemBackground
        
        // Настройка scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Настройка статус лейбла
        statusLabel.text = "Готов к демонстрации"
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        statusLabel.textColor = .label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка лейбла метрик
        metricsLabel.text = "Метрики будут отображаться здесь"
        metricsLabel.numberOfLines = 0
        metricsLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        metricsLabel.textColor = .secondaryLabel
        metricsLabel.backgroundColor = .secondarySystemBackground
        metricsLabel.layer.cornerRadius = 8
        metricsLabel.layer.masksToBounds = true
        metricsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем отступы для лейбла метрик
        let metricsContainer = UIView()
        metricsContainer.backgroundColor = .secondarySystemBackground
        metricsContainer.layer.cornerRadius = 8
        metricsContainer.translatesAutoresizingMaskIntoConstraints = false
        metricsContainer.addSubview(metricsLabel)
        
        // Настройка кнопок
        setupButton(startDemoButton, title: "🚀 Запустить полную демонстрацию", backgroundColor: .systemBlue)
        setupButton(stopDemoButton, title: "🛑 Остановить демонстрацию", backgroundColor: .systemRed)
        setupButton(testSpecificButton, title: "🧪 Тестировать аномалии", backgroundColor: .systemOrange)
        setupButton(currentMetricsButton, title: "📊 Показать анализ", backgroundColor: .systemGreen)
        
        stopDemoButton.isEnabled = false
        
        // Добавляем элементы в contentView
        contentView.addSubview(statusLabel)
        contentView.addSubview(metricsContainer)
        contentView.addSubview(startDemoButton)
        contentView.addSubview(stopDemoButton)
        contentView.addSubview(testSpecificButton)
        contentView.addSubview(currentMetricsButton)
        
        // Настройка constraints для metricsLabel внутри контейнера
        NSLayoutConstraint.activate([
            metricsLabel.topAnchor.constraint(equalTo: metricsContainer.topAnchor, constant: 12),
            metricsLabel.leadingAnchor.constraint(equalTo: metricsContainer.leadingAnchor, constant: 12),
            metricsLabel.trailingAnchor.constraint(equalTo: metricsContainer.trailingAnchor, constant: -12),
            metricsLabel.bottomAnchor.constraint(equalTo: metricsContainer.bottomAnchor, constant: -12)
        ])
        
        // Сохраняем ссылку на metricsContainer для constraints
        metricsContainer.tag = 999
        
        // Добавляем действия для кнопок
        startDemoButton.addTarget(self, action: #selector(startFullDemo), for: .touchUpInside)
        stopDemoButton.addTarget(self, action: #selector(stopDemo), for: .touchUpInside)
        testSpecificButton.addTarget(self, action: #selector(testSpecificAnomaly), for: .touchUpInside)
        currentMetricsButton.addTarget(self, action: #selector(showCurrentMetrics), for: .touchUpInside)
    }
    
    private func setupButton(_ button: UIButton, title: String, backgroundColor: UIColor) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем тень
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
    }
    
    private func setupConstraints() {
        let metricsContainer = contentView.viewWithTag(999)!
        
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Status label constraints
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Metrics container constraints
            metricsContainer.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            metricsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            metricsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            metricsContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            // Start demo button constraints
            startDemoButton.topAnchor.constraint(equalTo: metricsContainer.bottomAnchor, constant: 30),
            startDemoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            startDemoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            startDemoButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Stop demo button constraints
            stopDemoButton.topAnchor.constraint(equalTo: startDemoButton.bottomAnchor, constant: 15),
            stopDemoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stopDemoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stopDemoButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Test specific button constraints
            testSpecificButton.topAnchor.constraint(equalTo: stopDemoButton.bottomAnchor, constant: 15),
            testSpecificButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testSpecificButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            testSpecificButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Current metrics button constraints
            currentMetricsButton.topAnchor.constraint(equalTo: testSpecificButton.bottomAnchor, constant: 15),
            currentMetricsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currentMetricsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            currentMetricsButton.heightAnchor.constraint(equalToConstant: 50),
            currentMetricsButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
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
            metricsLabel.text = "PerformanceMonitor не активен\n\nНажмите одну из кнопок ниже\nчтобы запустить демонстрацию"
        }
    }
    
    // MARK: - Actions
    
    @objc private func startFullDemo() {
        statusLabel.text = "🚀 Запускается полная демонстрация...\nБудут показаны все типы аномалий"
        
        startDemoButton.isEnabled = false
        stopDemoButton.isEnabled = true
        
        // Анимация кнопки
        UIView.animate(withDuration: 0.3) {
            self.startDemoButton.alpha = 0.5
            self.stopDemoButton.alpha = 1.0
        }
        
        demo.startFullDemo()
        
        // Через 50 секунд включаем кнопку обратно (увеличенное время для более интенсивной демонстрации)
        DispatchQueue.main.asyncAfter(deadline: .now() + 50.0) {
            self.startDemoButton.isEnabled = true
            self.stopDemoButton.isEnabled = false
            self.statusLabel.text = "✅ Демонстрация завершена! Проверьте консоль для подробностей"
            
            UIView.animate(withDuration: 0.3) {
                self.startDemoButton.alpha = 1.0
                self.stopDemoButton.alpha = 0.5
            }
        }
    }
    
    @objc private func stopDemo() {
        demo.stopDemo()
        startDemoButton.isEnabled = true
        stopDemoButton.isEnabled = false
        statusLabel.text = "🛑 Демонстрация остановлена"
        
        UIView.animate(withDuration: 0.3) {
            self.startDemoButton.alpha = 1.0
            self.stopDemoButton.alpha = 0.5
        }
    }
    
    @objc private func testSpecificAnomaly() {
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
        
        // Для iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = testSpecificButton
            popover.sourceRect = testSpecificButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func showCurrentMetrics() {
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
                self.showCurrentMetrics()
            }
        }
    }
    
    private func testAnomaly(_ type: AnomalyType) {
        statusLabel.text = "🧪 Тестируется: \(getDisplayName(for: type))"
        
        startDemoButton.isEnabled = false
        stopDemoButton.isEnabled = true
        
        UIView.animate(withDuration: 0.3) {
            self.startDemoButton.alpha = 0.5
            self.stopDemoButton.alpha = 1.0
        }
        
        demo.testSpecificAnomaly(type)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
            self.startDemoButton.isEnabled = true
            self.stopDemoButton.isEnabled = false
            self.statusLabel.text = "✅ Тест \(self.getDisplayName(for: type)) завершен"
            
            UIView.animate(withDuration: 0.3) {
                self.startDemoButton.alpha = 1.0
                self.stopDemoButton.alpha = 0.5
            }
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