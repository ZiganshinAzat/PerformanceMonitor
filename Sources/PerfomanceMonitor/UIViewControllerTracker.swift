import Foundation

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
        
        print("✅ UIViewControllerTracker запущен (заглушка)")
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
        
        return ScreenNavigationAnalysis(
            totalScreens: history.count,
            uniqueScreens: uniqueScreens,
            mostVisitedScreen: mostVisitedScreen,
            averageTimePerScreen: averageTimePerScreen,
            navigationPatterns: []
        )
    }
}

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