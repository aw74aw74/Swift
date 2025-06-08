//
//  SceneDelegate.swift
//  seminar_05_one
//
//  Created by User on 07.06.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Настраиваем окно для iOS 13+
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Создаем основное окно приложения
        window = UIWindow(windowScene: windowScene)
        
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
            if let window = self?.window {
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
            }
        }
        
        // Устанавливаем контроллер авторизации как начальный экран
        window?.rootViewController = loginVC
        
        // Делаем окно видимым и активным
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

