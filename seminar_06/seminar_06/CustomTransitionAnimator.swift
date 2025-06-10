import UIKit

/// Аниматор для кастомного перехода между контроллерами
///
/// Реализует анимированный переход от UITabBarController к экрану профиля
final class CustomTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// Тип перехода (презентация или закрытие)
    enum TransitionType {
        case present
        case dismiss
    }
    
    /// Текущий тип перехода
    private let type: TransitionType
    
    /// Инициализатор аниматора
    /// - Parameter type: Тип перехода (презентация или закрытие)
    init(type: TransitionType) {
        self.type = type
        super.init()
    }
    
    /// Возвращает продолжительность анимации перехода
    /// - Parameter transitionContext: Контекст перехода
    /// - Returns: Продолжительность анимации в секундах
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    /// Выполняет анимацию перехода
    /// - Parameter transitionContext: Контекст перехода
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Получаем контейнер для анимации
        let containerView = transitionContext.containerView
        
        // Получаем контроллеры для перехода
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        // Определяем начальное и конечное состояние в зависимости от типа перехода
        switch type {
        case .present:
            // Анимация презентации
            animatePresentation(fromVC: fromVC, toVC: toVC, containerView: containerView, transitionContext: transitionContext)
        case .dismiss:
            // Анимация закрытия
            animateDismissal(fromVC: fromVC, toVC: toVC, containerView: containerView, transitionContext: transitionContext)
        }
    }
    
    /// Анимирует презентацию контроллера
    /// - Parameters:
    ///   - fromVC: Исходный контроллер
    ///   - toVC: Целевой контроллер
    ///   - containerView: Контейнер для анимации
    ///   - transitionContext: Контекст перехода
    private func animatePresentation(fromVC: UIViewController, toVC: UIViewController, containerView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        // Добавляем целевой контроллер в контейнер
        containerView.addSubview(toVC.view)
        
        // Настраиваем начальное состояние
        toVC.view.alpha = 0
        toVC.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        // Анимируем переход
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [], animations: {
            toVC.view.alpha = 1
            toVC.view.transform = .identity
            fromVC.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            fromVC.view.transform = .identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    /// Анимирует закрытие контроллера
    /// - Parameters:
    ///   - fromVC: Исходный контроллер
    ///   - toVC: Целевой контроллер
    ///   - containerView: Контейнер для анимации
    ///   - transitionContext: Контекст перехода
    private func animateDismissal(fromVC: UIViewController, toVC: UIViewController, containerView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        // Убеждаемся, что целевой контроллер виден
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        // Восстанавливаем состояние целевого контроллера
        toVC.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        // Анимируем переход
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [], animations: {
            fromVC.view.alpha = 0
            fromVC.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            toVC.view.transform = .identity
        }, completion: { _ in
            fromVC.view.transform = .identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

/// Делегат для управления переходом между контроллерами
final class CustomTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    /// Возвращает аниматор для презентации контроллера
    /// - Parameter presented: Презентуемый контроллер
    /// - Parameter presenting: Презентующий контроллер
    /// - Parameter source: Исходный контроллер
    /// - Returns: Аниматор для презентации
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionAnimator(type: .present)
    }
    
    /// Возвращает аниматор для закрытия контроллера
    /// - Parameter dismissed: Закрываемый контроллер
    /// - Returns: Аниматор для закрытия
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionAnimator(type: .dismiss)
    }
}
