import UIKit

/// Делегат приложения, отвечающий за основной жизненный цикл приложения
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Основное окно приложения (для совместимости с iOS ниже 13)
    var window: UIWindow?

    /// Вызывается при запуске приложения
    /// - Parameters:
    ///   - application: Экземпляр приложения
    ///   - launchOptions: Опции запуска приложения
    /// - Returns: Успешность инициализации приложения
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Для iOS 12 и ниже, настраиваем окно здесь
        if #available(iOS 13.0, *) {
            // Для iOS 13+ настройка происходит в SceneDelegate
        } else {
            // Для iOS 12 и ниже
            window = UIWindow(frame: UIScreen.main.bounds)
            setupRootViewController()
            window?.makeKeyAndVisible()
        }
        return true
    }
    
    // Метод для настройки корневого контроллера
    func setupRootViewController() {
        // Создаем контроллер с вкладками, который будет отображаться после авторизации
        let mainTabBarController = MainTabBarController()
        
        // Создаем контроллер авторизации
        let loginVC = ViewController()
        
        // Настраиваем обработчик успешной авторизации
        loginVC.onLoginSuccess = { [weak self] mockData in
            // Передаем данные в MainTabBarController
            mainTabBarController.mockData = mockData
            
            // При успешной авторизации меняем корневой контроллер на TabBarController
            self?.window?.rootViewController = mainTabBarController
            
            // Добавляем анимацию перехода
            UIView.transition(with: self!.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
        }
        
        // Устанавливаем контроллер авторизации как начальный экран
        window?.rootViewController = loginVC
    }
}
