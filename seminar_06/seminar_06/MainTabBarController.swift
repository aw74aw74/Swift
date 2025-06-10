import UIKit
import Foundation
import CoreData

// Модели данных из Models.swift доступны автоматически, так как находятся в одном модуле

/// Контроллер таб-бара для основного экрана приложения
/// Содержит вкладки: Друзья, Группы, Фото
class MainTabBarController: UITabBarController {
    
    /// Данные, полученные после авторизации
    /// Содержат информацию о друзьях, группах и фотографиях
    var mockData: MockData? {
        didSet {
            // При установке данных (обычно из сети) обновляем контроллеры
            // и сохраняем данные в Core Data
            if let newMockData = mockData {
                print("ℹ️ MainTabBarController: Получены новые mockData (из 'сети'). Сохранение в Core Data...")
                CoreDataManager.shared.saveFriends(newMockData.friends)
                CoreDataManager.shared.setLastUpdateTimestampForFriends()
                
                CoreDataManager.shared.saveGroups(newMockData.groups)
                CoreDataManager.shared.setLastUpdateTimestampForGroups()
            } else {
                 print("ℹ️ MainTabBarController: mockData установлен в nil.")
            }
            updateChildViewControllers() // Обновляем UI в любом случае
        }
    }
    
    /// Вызывается после загрузки представления контроллера
    /// Настраивает панель вкладок
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCachedData() // Загружаем кэшированные данные перед настройкой UI
        setupTabBar()    // Настраиваем вкладки (может использовать кэшированные данные, если mockData был установлен)
        applyCurrentTheme() // Применяем текущую тему (в основном для статус-бара)

        // Подписываемся на уведомления о смене темы
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: ThemeManager.themeDidChangeNotification, object: nil)
    }
    
    /// Настраивает панель вкладок и создает контроллеры для каждой вкладки
    // MARK: - Theme Management

    @objc private func themeDidChange() {
        applyCurrentTheme()
    }

    private func applyCurrentTheme() {
        let currentThemeColors = ThemeManager.shared.getCurrentThemeColors()

        // Устанавливаем цвета для UITabBar
        tabBar.tintColor = currentThemeColors.tabBarSelectedItemColor // Цвет активной иконки и текста
        tabBar.unselectedItemTintColor = currentThemeColors.tabBarUnselectedItemColor // Цвет неактивной иконки и текста
        tabBar.barTintColor = currentThemeColors.tabBarColor // Цвет фона самого таб-бара (для iOS < 13 или если appearance не используется)
        
        // Для iOS 13 и новее используем UITabBarAppearance для более детальной настройки
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            // Настройка фона
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = currentThemeColors.tabBarColor
            
            // Настройка цвета и атрибутов текста для активной вкладки
            appearance.stackedLayoutAppearance.selected.iconColor = currentThemeColors.tabBarSelectedItemColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: currentThemeColors.tabBarSelectedItemColor]
            
            // Настройка цвета и атрибутов текста для неактивной вкладки
            appearance.stackedLayoutAppearance.normal.iconColor = currentThemeColors.tabBarUnselectedItemColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: currentThemeColors.tabBarUnselectedItemColor]
            
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                // Для iOS 15+ также настраиваем scrollEdgeAppearance, чтобы вид был одинаковым при прокрутке и без нее
                tabBar.scrollEdgeAppearance = appearance
            }
        } else {
            // Fallback для iOS < 13 (уже частично покрыто выше)
            // tabBar.barStyle можно также настроить, если это часть темы, например .default или .black
        }

        setNeedsStatusBarAppearanceUpdate() // Обновляем стиль статус-бара
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.getCurrentThemeColors().statusBarStyle
    }

    // MARK: - TabBar Setup

    private func setupTabBar() {
        // Создаем контроллеры для каждой вкладки
        let friendsVC = FriendsViewController()
        let groupsVC = GroupsViewController()
        let photosVC = PhotosViewController()
        
        // Передаем данные в контроллеры, если они доступны
        if let data = mockData {
            if let friendsVC = friendsVC as? FriendsViewController {
                // Используем публичный метод для установки друзей
                // Теперь мы используем модель Friend из Models.swift напрямую
                friendsVC.setFriends(data.friends)
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
        
        // Внешний вид панели вкладок теперь настраивается глобально через ThemeManager и UIAppearance
    }

    // MARK: - Загрузка и обработка данных Core Data

    /// Загружает кэшированные данные из Core Data и устанавливает их в mockData для первоначального отображения.
    private func loadCachedData() {
        print("ℹ️ MainTabBarController: Попытка загрузки кэшированных данных из Core Data...")
        let cachedFriendsCD = CoreDataManager.shared.fetchFriends()
        let cachedGroupsCD = CoreDataManager.shared.fetchGroups()

        if !cachedFriendsCD.isEmpty || !cachedGroupsCD.isEmpty {
            let friends = cachedFriendsCD.map { friendCDtoFriend(friendCD: $0) }
            let groups = cachedGroupsCD.map { groupCDtoGroup(groupCD: $0) }
            
            // Важно: Фотографии не кэшируются в этой версии, поэтому массив фото будет пустым
            // Если бы фото кэшировались, их нужно было бы также загрузить и смапить.
            let initialMockData = MockData(friends: friends, groups: groups, photos: []) 
            self.mockData = initialMockData // Это вызовет didSet, который сохранит данные (хотя они уже есть) и обновит UI
            print("✅ MainTabBarController: Кэшированные данные загружены и установлены.")
        } else {
            print("ℹ️ MainTabBarController: Кэшированные данные не найдены.")
        }
    }

    // MARK: - Функции-мапперы для Core Data моделей

    private func friendCDtoFriend(friendCD: FriendCD) -> Friend {
        return Friend(
            id: Int(friendCD.id), // Преобразуем Int64 в Int
            name: friendCD.name ?? "Без имени",
            avatarUrl: friendCD.avatarUrl ?? "",
            isOnline: friendCD.isOnline
        )
    }

    private func groupCDtoGroup(groupCD: GroupCD) -> Group {
        return Group(
            id: Int(groupCD.id), // Преобразуем Int64 в Int
            name: groupCD.name ?? "Без названия",
            description: groupCD.groupDescription ?? "Без описания", // Используем groupDescription
            avatarUrl: groupCD.photoUrl ?? "", // Используем avatarUrl в соответствии с моделью Group
            membersCount: Int(groupCD.membersCount) // Преобразуем из Int32
        )
    }
    
    /// Обновляет дочерние контроллеры с новыми данными
    private func updateChildViewControllers() {
        guard let data = mockData, let viewControllers = viewControllers else { return }
        
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController {
                if let friendsVC = navController.viewControllers.first as? FriendsViewController {
                    // Используем публичный метод для установки друзей
                    // Теперь используем модель Friend из Models.swift напрямую
                    friendsVC.setFriends(data.friends)
                } else if let groupsVC = navController.viewControllers.first as? GroupsViewController {
                    groupsVC.groups = data.groups
                } else if let photosVC = navController.viewControllers.first as? PhotosViewController {
                    // Сюда можно добавить логику для photosVC, если она появится
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: ThemeManager.themeDidChangeNotification, object: nil)
        print("MainTabBarController deinited")
    }
}
