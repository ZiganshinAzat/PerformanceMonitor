@preconcurrency import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Трекер для отслеживания FPS (кадров в секунду)
final class FPSTracker {
    
    // MARK: - Properties
    
    private var fps: Double = 60.0
    
    #if canImport(UIKit) && !targetEnvironment(macCatalyst)
    @available(iOS 15.0, *)
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    #endif
    
    // MARK: - Public Properties
    
    /// Текущий FPS
    var currentFPS: Double {
        return fps
    }
    
    /// Категория производительности на основе FPS
    var performanceCategory: PerformanceCategory {
        switch fps {
        case 50...:
            return .excellent
        case 30..<50:
            return .good
        case 20..<30:
            return .fair
        default:
            return .poor
        }
    }
    
    // MARK: - Public Methods
    
    /// Запускает отслеживание FPS
    func start() {
        #if canImport(UIKit) && !targetEnvironment(macCatalyst)
        if #available(iOS 15.0, *) {
            guard displayLink == nil else {
                print("⚠️ FPSTracker уже запущен")
                return
            }
            
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick(_:)))
            displayLink?.add(to: .main, forMode: .common)
            
            print("✅ FPSTracker запущен")
        } else {
            print("✅ FPSTracker запущен (заглушка для iOS < 15.0)")
        }
        #else
        print("✅ FPSTracker запущен (заглушка для macOS)")
        #endif
    }
    
    /// Останавливает отслеживание FPS
    func stop() {
        #if canImport(UIKit) && !targetEnvironment(macCatalyst)
        if #available(iOS 15.0, *) {
            displayLink?.invalidate()
            displayLink = nil
            fps = 0
            frameCount = 0
            lastTimestamp = 0
            
            print("🛑 FPSTracker остановлен")
        } else {
            print("🛑 FPSTracker остановлен (заглушка для iOS < 15.0)")
        }
        #else
        fps = 0
        print("🛑 FPSTracker остановлен")
        #endif
    }
    
    // MARK: - Private Methods
    
    #if canImport(UIKit) && !targetEnvironment(macCatalyst)
    @available(iOS 15.0, *)
    @objc private func displayLinkTick(_ displayLink: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = displayLink.timestamp
            return
        }
        
        frameCount += 1
        
        let elapsed = displayLink.timestamp - lastTimestamp
        if elapsed >= 1.0 {
            fps = Double(frameCount) / elapsed
            frameCount = 0
            lastTimestamp = displayLink.timestamp
        }
    }
    #endif
}

// MARK: - PerformanceCategory

enum PerformanceCategory: String, CaseIterable {
    case excellent = "Отличная"
    case good = "Хорошая"
    case fair = "Удовлетворительная"
    case poor = "Плохая"
} 