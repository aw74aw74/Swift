import UIKit

/// Контроллер с вкладками для навигации по приложению
/// Содержит три вкладки: Друзья, Группы, Фото
class MainTabBarController: UITabBarController {
    
    /// Данные, полученные после авторизации
    /// Содержат информацию о друзьях, группах и фотографиях
    var mockData: ViewController.MockData? {
        didSet {
            // При установке данных обновляем контроллеры, если они уже созданы
            updateChildViewControllers()
        }
    }
    
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
        
        // Передаем данные в контроллеры, если они доступны
        if let data = mockData {
            if let friendsVC = friendsVC as? FriendsViewController {
                // Используем публичный метод для установки друзей
                // Нужно преобразовать тип ViewController.Friend в FriendsViewController.Friend
                let convertedFriends = data.friends.map { friend in
                    return FriendsViewController.Friend(id: friend.id, name: friend.name, avatarUrl: friend.avatarUrl, isOnline: friend.isOnline)
                }
                friendsVC.setFriends(convertedFriends)
            }
            
            if let groupsVC = groupsVC as? GroupsViewController {
                groupsVC.groups = data.groups
            }
            
            if let photosVC = photosVC as? PhotosViewController {
                // Передаем фото, если необходимо
                // photosVC.photos = data.photos
            }
        }
        
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
    
    /// Обновляет дочерние контроллеры с новыми данными
    private func updateChildViewControllers() {
        guard let data = mockData, let viewControllers = viewControllers else { return }
        
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController {
                if let friendsVC = navController.viewControllers.first as? FriendsViewController {
                    // Используем публичный метод для установки друзей
                    // Нужно преобразовать тип ViewController.Friend в FriendsViewController.Friend
                    let convertedFriends = data.friends.map { friend in
                        return FriendsViewController.Friend(id: friend.id, name: friend.name, avatarUrl: friend.avatarUrl, isOnline: friend.isOnline)
                    }
                    friendsVC.setFriends(convertedFriends)
                } else if let groupsVC = navController.viewControllers.first as? GroupsViewController {
                    groupsVC.groups = data.groups
                } else if let photosVC = navController.viewControllers.first as? PhotosViewController {

                }
            }
        }
    }
}
