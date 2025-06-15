# 🔧 Руководство по совместимости PerformanceMonitor

## Проблема: Не удается добавить библиотеку в проект с другими зависимостями

Если вы не можете добавить PerformanceMonitor в проект, где уже есть другие библиотеки (Kingfisher, Alamofire, SnapKit и т.д.), это связано с конфликтами версий Swift Package Manager.

## ✅ Решения

### 1. Проверьте версию Swift Tools

Убедитесь, что ваш проект использует совместимую версию Swift tools:
- PerformanceMonitor использует `swift-tools-version: 5.9`
- Это совместимо с большинством современных проектов

### 2. Очистите кэш Swift Package Manager

```bash
# В терминале выполните:
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/.swiftpm
```

### 3. В Xcode

1. **File → Swift Packages → Reset Package Caches**
2. **Product → Clean Build Folder** (⌘+Shift+K)
3. Перезапустите Xcode

### 4. Добавление библиотеки

#### Через Xcode:
1. File → Add Package Dependencies
2. Введите URL: `https://github.com/yourusername/PerformanceMonitor`
3. Выберите версию: `Up to Next Major Version`

#### Через Package.swift:
```swift
dependencies: [
    .package(url: "https://github.com/yourusername/PerformanceMonitor", from: "1.0.0")
]
```

### 5. Если проблема сохраняется

#### Проверьте конфликты версий:
```swift
// В Package.swift проверьте совместимость платформ
platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5)
]
```

#### Временное решение - локальная зависимость:
1. Скачайте исходный код PerformanceMonitor
2. Добавьте как локальную зависимость:
```swift
.package(path: "../PerformanceMonitor")
```

## 🚀 Быстрый тест совместимости

Запустите тест совместимости:
```bash
swift run iOSCompatibilityTest
```

## 📱 Использование в iOS проекте

```swift
import PerformanceMonitor

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Запуск мониторинга
        PerformanceMonitor.shared.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Остановка мониторинга
        PerformanceMonitor.shared.stop()
    }
}
```

## 🔍 Диагностика проблем

### Проверьте логи Xcode:
1. Откройте **Window → Devices and Simulators**
2. Выберите ваше устройство/симулятор
3. Нажмите **Open Console**
4. Найдите ошибки связанные с Swift Package Manager

### Типичные ошибки и решения:

#### "Package resolution failed"
- Очистите кэш (см. пункт 2)
- Проверьте интернет-соединение
- Убедитесь в правильности URL репозитория

#### "Version conflict"
- Обновите другие зависимости до совместимых версий
- Используйте точные версии вместо диапазонов

#### "Build failed"
- Проверьте минимальную версию iOS в проекте (должна быть >= 12.0)
- Убедитесь что используется Xcode 14.0+

## 📞 Поддержка

Если проблема не решается:
1. Создайте Issue в репозитории
2. Приложите:
   - Версию Xcode
   - Версию iOS
   - Список других зависимостей
   - Полный текст ошибки

## ✅ Проверенная совместимость

PerformanceMonitor протестирован с:
- ✅ Alamofire 5.x
- ✅ Kingfisher 7.x  
- ✅ SnapKit 5.x
- ✅ SwiftyJSON 5.x
- ✅ RxSwift 6.x

---

*Последнее обновление: Июнь 2025* 