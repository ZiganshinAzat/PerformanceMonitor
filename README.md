# PerformanceMonitor

Мощный Swift Package для мониторинга производительности iOS и macOS приложений.

## 🚀 Возможности

- **FPS Tracking** - Отслеживание частоты кадров в реальном времени
- **CPU Monitoring** - Мониторинг загрузки процессора
- **Memory Usage** - Отслеживание потребления памяти
- **Network Monitoring** - Мониторинг сетевых запросов
- **Screen Tracking** - Отслеживание переходов между экранами
- **Performance Analysis** - Автоматический анализ и выявление аномалий
- **Report Generation** - Генерация отчетов в форматах JSON, CSV, PDF

## 📱 Поддерживаемые платформы

- iOS 13.0+
- macOS 10.15+

## 📦 Установка

### Swift Package Manager

Добавьте PerformanceMonitor в ваш проект через Xcode:

1. File → Add Package Dependencies
2. Введите URL: `https://github.com/yourusername/PerformanceMonitor`
3. Выберите версию и добавьте в проект

Или добавьте в `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/PerformanceMonitor", from: "1.0.0")
]
```

## 🛠 Использование

### Базовое использование

```swift
import PerformanceMonitor

// Запуск мониторинга
PerformanceMonitor.shared.start()

// Получение текущих метрик
if let metrics = PerformanceMonitor.shared.getCurrentMetrics() {
    print("FPS: \(metrics.fps)")
    print("CPU: \(metrics.cpuUsage)%")
    print("Memory: \(metrics.memoryUsage) MB")
}

// Остановка мониторинга
PerformanceMonitor.shared.stop()
```

### Настройка пороговых значений

```swift
let customThresholds = PerformanceThresholds(
    minFPS: 30.0,
    maxCPU: 90.0,
    maxMemory: 300.0,
    maxNetworkDuration: 10.0,
    memorySpikeFactor: 2.0
)

PerformanceMonitor.shared.start(
    interval: 0.5, // Интервал сбора данных в секундах
    thresholds: customThresholds
)
```

### Генерация отчетов

```swift
PerformanceMonitor.shared.generateReport(formats: [.json, .csv]) { result in
    switch result {
    case .success(let urls):
        print("Отчеты созданы: \(urls)")
    case .failure(let error):
        print("Ошибка: \(error)")
    }
}
```

### Ручной сбор метрик

```swift
// Для тестирования или специальных случаев
PerformanceMonitor.shared.collectMetricsNow()
```

## 📊 Структура данных

### PerformanceData

```swift
struct PerformanceData {
    let fps: Double                    // Частота кадров
    let cpuUsage: Double              // Загрузка CPU (%)
    let memoryUsage: Double           // Потребление памяти (MB)
    let batteryLevel: Double?         // Уровень батареи (%)
    let screenName: String?           // Название текущего экрана
    let networkRequests: [NetworkRequestData] // Сетевые запросы
    let timestamp: Date               // Время сбора данных
}
```

### PerformanceThresholds

```swift
struct PerformanceThresholds {
    let minFPS: Double               // Минимальный FPS
    let maxCPU: Double              // Максимальная загрузка CPU
    let maxMemory: Double           // Максимальное потребление памяти
    let maxNetworkDuration: Double  // Максимальная длительность запроса
    let memorySpikeFactor: Double   // Коэффициент скачка памяти
    
    static let `default` = PerformanceThresholds(
        minFPS: 50.0,
        maxCPU: 80.0,
        maxMemory: 200.0,
        maxNetworkDuration: 5.0,
        memorySpikeFactor: 1.5
    )
}
```

## 🔧 Команды для разработчиков

### Сборка проекта

```bash
# Debug сборка
swift build

# Release сборка
swift build --configuration release

# Запуск тестов
swift test

# Запуск тестов в release
swift test --configuration release
```

### Проверка на разных платформах

```bash
# Сборка для iOS (требует Xcode)
xcodebuild -scheme PerformanceMonitor -destination 'platform=iOS Simulator,name=iPhone 14' build

# Сборка для macOS
swift build --triple x86_64-apple-macosx10.15
```

## 🏗 Архитектура

Проект состоит из следующих компонентов:

- **PerformanceMonitor** - Основной класс-координатор
- **FPSTracker** - Отслеживание FPS (использует CADisplayLink на iOS)
- **CPUTracker** - Мониторинг CPU (использует mach API)
- **NetworkMonitor** - Перехват сетевых запросов
- **UIViewControllerTracker** - Отслеживание экранов
- **MetricKitProvider** - Интеграция с MetricKit (iOS 13+)
- **DataAnalyzer** - Анализ данных и выявление аномалий
- **ReportGenerator** - Генерация отчетов

## ⚠️ Особенности платформ

### iOS
- Полная функциональность FPS tracking через CADisplayLink
- Реальный мониторинг CPU через mach API
- Интеграция с MetricKit для системных метрик
- Отслеживание UIViewController переходов

### macOS
- FPS tracking работает как заглушка (CADisplayLink недоступен)
- CPU мониторинг через упрощенные системные вызовы
- Ограниченная функциональность MetricKit

## 🧪 Тестирование

Проект включает полный набор unit-тестов:

```bash
swift test --verbose
```

Тесты покрывают:
- Базовую функциональность мониторинга
- Сбор и очистку данных
- Генерацию отчетов
- Работу с пороговыми значениями
- Модели данных

## 📄 Лицензия

MIT License - см. файл LICENSE

## 🤝 Вклад в проект

1. Fork проекта
2. Создайте feature branch (`git checkout -b feature/amazing-feature`)
3. Commit изменения (`git commit -m 'Add amazing feature'`)
4. Push в branch (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## 📞 Поддержка

Если у вас есть вопросы или предложения, создайте Issue в репозитории.

---

**PerformanceMonitor** - Делаем производительность видимой! 🚀 