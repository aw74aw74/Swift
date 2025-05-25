import UIKit

/// Делегат приложения, отвечающий за основной жизненный цикл приложения
/// Настраивает корневой контроллер и управляет переходами между экранами
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Основное окно приложения
    /// Содержит корневой контроллер и отображает пользовательский интерфейс
    var window: UIWindow?

    /// Вызывается при запуске приложения
    /// Настраивает основное окно и устанавливает начальный экран авторизации
    /// - Parameters:
    ///   - application: Экземпляр приложения
    ///   - launchOptions: Опции запуска приложения
    /// - Returns: Успешность инициализации приложения
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Создаем основное окно приложения размером с экран устройства
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Создаем контроллер с вкладками, который будет отображаться после авторизации
        let mainTabBarController = MainTabBarController()
        
        // Создаем контроллер авторизации
        let loginVC = ViewController()
        
        // Настраиваем обработчик успешной авторизации
        loginVC.onLoginSuccess = { [weak self] in
            // При успешной авторизации меняем корневой контроллер на TabBarController
            self?.window?.rootViewController = mainTabBarController
        }
        
        // Устанавливаем контроллер авторизации как начальный экран
        window?.rootViewController = loginVC
        
        // Делаем окно видимым и активным
        window?.makeKeyAndVisible()
        return true
    }
}
