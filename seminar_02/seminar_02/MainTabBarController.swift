import UIKit

/// Контроллер с вкладками для навигации по приложению
/// Содержит три вкладки: Друзья, Группы, Фото
class MainTabBarController: UITabBarController {
    
    /// Вызывается после загрузки представления контроллера
    /// Настраивает панель вкладок
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    /// Настраивает панель вкладок и создает контроллеры для каждой вкладки
    private func setupTabBar() {
        // Создаем контроллеры для каждой вкладки
        let friendsVC = FriendsViewController()
        let groupsVC = GroupsViewController()
        let photosVC = PhotosViewController()
        
        // Оборачиваем каждый контроллер в навигационный контроллер для возможности навигации
        let friendsNavController = UINavigationController(rootViewController: friendsVC)
        let groupsNavController = UINavigationController(rootViewController: groupsVC)
        let photosNavController = UINavigationController(rootViewController: photosVC)
        
        // Настраиваем элементы панели вкладок с иконками и названиями
        friendsNavController.tabBarItem = UITabBarItem(title: "Друзья", image: UIImage(systemName: "person.2"), tag: 0)
        groupsNavController.tabBarItem = UITabBarItem(title: "Группы", image: UIImage(systemName: "person.3"), tag: 1)
        photosNavController.tabBarItem = UITabBarItem(title: "Фото", image: UIImage(systemName: "photo"), tag: 2)
        
        // Устанавливаем контроллеры в TabBarController
        self.viewControllers = [friendsNavController, groupsNavController, photosNavController]
        
        // Настраиваем внешний вид панели вкладок
        tabBar.tintColor = .systemBlue // Цвет выбранной вкладки
        tabBar.backgroundColor = .systemBackground // Цвет фона панели вкладок
    }
}
