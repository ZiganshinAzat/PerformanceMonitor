# 🚀 Демонстрация PerformanceMonitor

Данный репозиторий содержит полнофункциональную библиотеку для мониторинга производительности iOS приложений, созданную как курсовая работа.

## 📊 Функционал библиотеки

### Основные возможности:
- **🎮 FPS Tracking** - Отслеживание частоты кадров в реальном времени
- **⚡ CPU Monitoring** - Мониторинг загрузки процессора
- **💾 Memory Usage** - Отслеживание потребления памяти
- **🌐 Network Monitoring** - Мониторинг сетевых запросов
- **📱 Screen Tracking** - Отслеживание переходов между экранами
- **🔋 Battery Level** - Уровень заряда батареи

### 🚨 Типы выявляемых аномалий:

1. **lowFPS** 🎮 - Низкий FPS (менее 50 кадров/сек по умолчанию)
   - Причины: тяжелые вычисления на главном потоке, сложная графика
   - Симуляция: блокировка главного потока

2. **highCPU** ⚡ - Высокая загрузка CPU (более 80% по умолчанию)
   - Причины: интенсивные вычисления, неоптимизированные алгоритмы
   - Симуляция: математические вычисления в фоновых потоках

3. **highMemory** 💾 - Высокое потребление памяти (более 250 MB по умолчанию)
   - Причины: утечки памяти, большие кэши, неосвобожденные ресурсы
   - Симуляция: выделение больших блоков памяти

4. **memorySpike** 🔥 - Резкие скачки памяти (увеличение в 1.5+ раз)
   - Причины: внезапная загрузка данных, создание временных объектов
   - Симуляция: резкое выделение 50MB блоков

5. **slowNetworkRequest** 🌐 - Медленные сетевые запросы (более 5 сек)
   - Причины: плохое соединение, медленный сервер, большие данные
   - Симуляция: запросы к httpbin.org/delay

6. **batteryDrain** 🔋 - Быстрая разрядка батареи
   - Причины: интенсивное использование GPS, камеры, процессора
   - Требует реальных условий для проявления

## 🎯 Файлы для демонстрации

### 1. `PerformanceMonitorDemo.swift`
Основной демонстрационный класс, который:
- Создает все типы аномалий программно
- Показывает возможности библиотеки
- Генерирует подробные отчеты

**Использование:**
```swift
let demo = PerformanceMonitorDemo()

// Полная демонстрация всех аномалий (30 секунд)
demo.startFullDemo()

// Тестирование конкретной аномалии
demo.testSpecificAnomaly(.lowFPS)
```

### 2. `DemoViewController.swift`
UIViewController с графическим интерфейсом для:
- Интерактивного тестирования библиотеки
- Визуализации текущих метрик
- Управления процессом демонстрации

## 🚀 Как продемонстрировать функционал

### Вариант 1: Простая демонстрация в коде

```swift
import PerformanceMonitor

// 1. Запустить мониторинг
PerformanceMonitor.shared.start()

// 2. Запустить полную демонстрацию
let demo = PerformanceMonitorDemo()
demo.startFullDemo()

// 3. Через 30 секунд получить отчет
DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
    let analysis = PerformanceMonitor.shared.getPerformanceAnalysis()
    print("Обнаружено аномалий: \(analysis.anomalies.count)")
    print("Оценка производительности: \(analysis.overallScore)/100")
}
```

### Вариант 2: С графическим интерфейсом

1. Создайте новый iOS проект в Xcode
2. Добавьте PerformanceMonitor как dependency
3. Скопируйте `DemoViewController.swift` в проект
4. Создайте UI в Storyboard или используйте программное создание
5. Запустите приложение и нажмите кнопки для тестирования

### Вариант 3: Пошаговая демонстрация

```swift
let demo = PerformanceMonitorDemo()

// Тестируем каждую аномалию отдельно
demo.testSpecificAnomaly(.lowFPS)      // 10 секунд
demo.testSpecificAnomaly(.highCPU)     // 10 секунд
demo.testSpecificAnomaly(.highMemory)  // 10 секунд
demo.testSpecificAnomaly(.memorySpike) // 10 секунд
demo.testSpecificAnomaly(.slowNetworkRequest) // 10 секунд
```

## 📈 Ожидаемые результаты

При запуске полной демонстрации вы увидите:

### В консоли:
```
🚀 Запуск полной демонстрации PerformanceMonitor
📊 Будут продемонстрированы все типы аномалий:
   - Низкий FPS
   - Высокая загрузка CPU
   - Высокое потребление памяти
   - Скачки памяти
   - Медленные сетевые запросы

🎮 Начинаем симуляцию низкого FPS...
✅ Симуляция низкого FPS завершена
⚡ Начинаем симуляцию высокой загрузки CPU...
✅ Симуляция высокой загрузки CPU завершена
💾 Начинаем симуляцию высокого потребления памяти...
✅ Симуляция высокого потребления памяти завершена

📈 РЕЗУЛЬТАТЫ АНАЛИЗА:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Собрано точек данных: 60
🎮 Средний FPS: 45.2
⚡ Средняя загрузка CPU: 65.8%
💾 Среднее потребление памяти: 180.5 MB
🔥 Пиковое потребление памяти: 350.2 MB
🏆 Общая оценка производительности: 73/100

🚨 ОБНАРУЖЕННЫЕ АНОМАЛИИ (15):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎮 low_fps: 6 случаев
⚡ high_cpu: 4 случая
💾 high_memory: 3 случая
🔥 memory_spike: 2 случая
```

### Сгенерированные отчеты:
- `performance_report_YYYY-MM-DD_HH-MM-SS.json` - Детальный JSON отчет
- `performance_report_YYYY-MM-DD_HH-MM-SS.csv` - CSV для анализа в Excel

## 🔧 Настройка пороговых значений

Для демонстрации используются более чувствительные пороги:

```swift
let demoThresholds = PerformanceThresholds(
    minFPS: 55.0,              // Высокий порог для FPS
    maxCPU: 50.0,              // Низкий порог для CPU  
    maxMemory: 100.0,          // Низкий порог для памяти
    maxNetworkDuration: 2.0,   // Короткий порог для сети
    memorySpikeFactor: 1.3     // Чувствительный порог для скачков
)
```

## 📱 Рекомендации для демонстрации

1. **Запускайте на симуляторе** - Все функции работают корректно
2. **Следите за консолью** - Там отображается весь процесс
3. **Не прерывайте демонстрацию** - Дайте ей завершиться полностью
4. **Проверьте отчеты** - Они создаются в Documents директории
5. **Используйте реальное устройство** - Для более точных метрик CPU/памяти

## 🎓 Образовательная ценность

Этот проект демонстрирует:
- **Системное программирование** - Работа с mach API, MetricKit
- **Архитектуру iOS** - CADisplayLink, URLSession, UIViewController tracking
- **Анализ данных** - Алгоритмы выявления аномалий
- **Паттерны проектирования** - Singleton, Observer, Strategy
- **Асинхронное программирование** - DispatchQueue, Timer
- **Интеграцию библиотек** - Swift Package Manager

## 🏆 Заключение

PerformanceMonitor - это полнофункциональная библиотека, которая может быть использована в реальных проектах для:
- Выявления проблем производительности
- Оптимизации приложений
- Мониторинга качества пользовательского опыта
- Автоматического тестирования производительности

Демонстрационные файлы показывают все возможности библиотеки и могут служить основой для дальнейшего развития проекта. 