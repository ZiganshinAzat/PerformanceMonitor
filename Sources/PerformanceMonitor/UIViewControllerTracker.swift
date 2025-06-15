import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(ObjectiveC)
import ObjectiveC
#endif

/// Трекер для отслеживания активных экранов (UIViewController)
final class UIViewControllerTracker {
    
    // MARK: - Static Properties
    
    nonisolated(unsafe) static weak var shared: UIViewControllerTracker?
    
    // MARK: - Properties
    
    private var isStarted = false
    private var currentScreen: String?
    private var screenHistory: [(name: String, timestamp: Date)] = []
    private let maxHistoryCount = 100
    
    // MARK: - Public Properties
    
    /// Название текущего активного экрана
    var currentScreenName: String? {
        return currentScreen
    }
    
    /// История посещенных экранов
    var screenNavigationHistory: [(name: String, timestamp: Date)] {
        return Array(screenHistory)
    }
    
    // MARK: - Public Methods
    
    /// Запускает отслеживание экранов
    func start() {
        guard !isStarted else {
            print("⚠️ UIViewControllerTracker уже запущен")
            return
        }
        
        UIViewControllerTracker.shared = self
        isStarted = true
        
        #if canImport(UIKit) && !targetEnvironment(macCatalyst)
        swizzleViewControllerMethods()
        print("✅ UIViewControllerTracker запущен с method swizzling")
        #else
        print("✅ UIViewControllerTracker запущен (заглушка для macOS)")
        #endif
    }
    
    /// Останавливает отслеживание экранов
    func stop() {
        guard isStarted else {
            print("⚠️ UIViewControllerTracker не запущен")
            return
        }
        
        UIViewControllerTracker.shared = nil
        isStarted = false
        
        currentScreen = nil
        screenHistory.removeAll()
        
        print("🛑 UIViewControllerTracker остановлен")
    }
    
    /// Очищает историю экранов
    func clearHistory() {
        screenHistory.removeAll()
    }
    
    /// Регистрирует переход на новый экран
    func trackScreenTransition(to screenName: String) {
        currentScreen = screenName
        
        let entry = (name: screenName, timestamp: Date())
        screenHistory.append(entry)
        
        // Ограничиваем размер истории
        if screenHistory.count > maxHistoryCount {
            screenHistory.removeFirst(screenHistory.count - maxHistoryCount)
        }
        
        print("📱 Переход на экран: \(screenName)")
    }
    
    /// Анализирует навигацию по экранам
    func analyzeScreenNavigation() -> ScreenNavigationAnalysis {
        let history = screenNavigationHistory
        
        guard !history.isEmpty else {
            return ScreenNavigationAnalysis(
                totalScreens: 0,
                uniqueScreens: [],
                mostVisitedScreen: nil,
                averageTimePerScreen: 0,
                navigationPatterns: []
            )
        }
        
        // Подсчитываем уникальные экраны
        let uniqueScreens = Array(Set(history.map { $0.name }))
        
        // Находим самый посещаемый экран
        let screenCounts = Dictionary(grouping: history, by: { $0.name })
            .mapValues { $0.count }
        let mostVisitedScreen = screenCounts.max(by: { $0.value < $1.value })?.key
        
        // Вычисляем среднее время на экране
        var totalTime: TimeInterval = 0
        var screenCount = 0
        
        for i in 0..<(history.count - 1) {
            let currentScreen = history[i]
            let nextScreen = history[i + 1]
            
            if currentScreen.name != nextScreen.name {
                totalTime += nextScreen.timestamp.timeIntervalSince(currentScreen.timestamp)
                screenCount += 1
            }
        }
        
        let averageTimePerScreen = screenCount > 0 ? totalTime / Double(screenCount) : 0
        
        // Анализируем паттерны навигации
        let navigationPatterns = analyzeNavigationPatterns(from: history)
        
        return ScreenNavigationAnalysis(
            totalScreens: history.count,
            uniqueScreens: uniqueScreens,
            mostVisitedScreen: mostVisitedScreen,
            averageTimePerScreen: averageTimePerScreen,
            navigationPatterns: navigationPatterns
        )
    }
    
    // MARK: - Private Methods
    
    private func analyzeNavigationPatterns(from history: [(name: String, timestamp: Date)]) -> [NavigationPattern] {
        var patterns: [String: NavigationPatternData] = [:]
        
        for i in 0..<(history.count - 1) {
            let fromScreen = history[i].name
            let toScreen = history[i + 1].name
            let transitionTime = history[i + 1].timestamp.timeIntervalSince(history[i].timestamp)
            
            if fromScreen != toScreen {
                let key = "\(fromScreen) -> \(toScreen)"
                
                if var existing = patterns[key] {
                    existing.frequency += 1
                    existing.totalTransitionTime += transitionTime
                    patterns[key] = existing
                } else {
                    patterns[key] = NavigationPatternData(
                        fromScreen: fromScreen,
                        toScreen: toScreen,
                        frequency: 1,
                        totalTransitionTime: transitionTime
                    )
                }
            }
        }
        
        return patterns.values.map { data in
            NavigationPattern(
                fromScreen: data.fromScreen,
                toScreen: data.toScreen,
                frequency: data.frequency,
                averageTransitionTime: data.totalTransitionTime / Double(data.frequency)
            )
        }.sorted { $0.frequency > $1.frequency }
    }
    
    #if canImport(UIKit) && !targetEnvironment(macCatalyst)
    private func swizzleViewControllerMethods() {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.pm_viewDidAppear(_:))
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
            print("❌ Не удалось получить методы для swizzling")
            return
        }
        
        let didAddMethod = class_addMethod(UIViewController.self,
                                         originalSelector,
                                         method_getImplementation(swizzledMethod),
                                         method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(UIViewController.self,
                              swizzledSelector,
                              method_getImplementation(originalMethod),
                              method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    #endif
}

// MARK: - UIViewController Extension

#if canImport(UIKit) && !targetEnvironment(macCatalyst)
extension UIViewController {
    @objc func pm_viewDidAppear(_ animated: Bool) {
        // Вызываем оригинальный метод
        pm_viewDidAppear(animated)
        
        // Отслеживаем переход
        let screenName = String(describing: type(of: self))
        UIViewControllerTracker.shared?.trackScreenTransition(to: screenName)
    }
}
#endif

// MARK: - Supporting Structures

struct ScreenNavigationAnalysis {
    let totalScreens: Int
    let uniqueScreens: [String]
    let mostVisitedScreen: String?
    let averageTimePerScreen: TimeInterval
    let navigationPatterns: [NavigationPattern]
}

struct NavigationPattern {
    let fromScreen: String
    let toScreen: String
    let frequency: Int
    let averageTransitionTime: TimeInterval
}

private struct NavigationPatternData {
    let fromScreen: String
    let toScreen: String
    var frequency: Int
    var totalTransitionTime: TimeInterval
} 