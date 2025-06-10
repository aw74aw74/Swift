import UIKit
import Foundation

// MARK: - Протокол темы

/// Протокол, определяющий свойства, которые должна иметь каждая тема.
protocol ThemeProtocol {
    /// Основной цвет фона для view
    var backgroundColor: UIColor { get }
    /// Второстепенный цвет фона (например, для групп элементов)
    var secondaryBackgroundColor: UIColor { get }
    /// Цвет фона для ячеек таблиц и коллекций
    var cellBackgroundColor: UIColor { get }
    /// Основной цвет текста
    var textColor: UIColor { get }
    /// Второстепенный цвет текста (например, для подписей)
    var secondaryTextColor: UIColor { get }
    /// Акцентный цвет (для кнопок, иконок, выделений)
    var accentColor: UIColor { get }
    /// Цвет для Navigation Bar
    var navigationBarColor: UIColor { get }
    /// Цвет текста заголовка в Navigation Bar
    var navigationTitleColor: UIColor { get }
    /// Цвет элементов Navigation Bar (кнопки)
    var navigationTintColor: UIColor { get }
    /// Цвет для Tab Bar
    var tabBarColor: UIColor { get }
    /// Цвет неактивных элементов Tab Bar
    var tabBarUnselectedItemColor: UIColor { get }
    /// Цвет активного элемента Tab Bar
    var tabBarSelectedItemColor: UIColor { get }
    /// Стиль статус-бара (светлый или темный контент)
    var statusBarStyle: UIStatusBarStyle { get }
    /// Цвет разделителей в таблицах и коллекциях
    var separatorColor: UIColor { get }

    // Новые свойства для кнопок
    var buttonBackgroundColor: UIColor? { get }
    var buttonTextColor: UIColor? { get }
    var disabledTextColor: UIColor? { get }
}

// Реализации по умолчанию для новых свойств ThemeProtocol
extension ThemeProtocol {
    // Цвет фона кнопки по умолчанию - акцентный цвет темы
    var buttonBackgroundColor: UIColor? { accentColor }
    
    // Цвет текста кнопки по умолчанию - либо белый, либо основной цвет текста,
    // в зависимости от того, что лучше контрастирует с buttonBackgroundColor.
    // Для простоты пока можно использовать основной цвет фона как цвет текста, если фон кнопки яркий,
    // или основной цвет текста, если фон кнопки темный. Более сложная логика контраста здесь не реализована.
    // Простой вариант: если акцентный цвет (фон кнопки) светлый, текст темный, и наоборот.
    // Этот пример предполагает, что backgroundColor контрастирует с accentColor.
    var buttonTextColor: UIColor? {
        // Простая проверка: если акцентный цвет (фон кнопки) воспринимается как светлый,
        // то текст кнопки делаем темным (например, основной textColor).
        // Иначе (если фон кнопки темный) - текст светлый (например, backgroundColor или специальный светлый цвет).
        // Это очень упрощенная логика. Для реального приложения может потребоваться более точный расчет контрастности.
        var white: CGFloat = 0
        accentColor.getWhite(&white, alpha: nil)
        return white > 0.5 ? textColor : backgroundColor // Пример: если фон кнопки светлый, текст - основной, иначе - фон основной
    }
    
    // Цвет текста для неактивных элементов по умолчанию - вторичный цвет текста с пониженной прозрачностью
    var disabledTextColor: UIColor? { secondaryTextColor.withAlphaComponent(0.5) }
    
    // Для свойств tabBar, если они уже есть, то эти значения по умолчанию не будут использоваться.

}

// MARK: - Перечисление доступных тем

/// Перечисление доступных тем в приложении.
/// `CaseIterable` позволяет получить все кейсы, `Codable` для сохранения в UserDefaults.
enum AppTheme: String, CaseIterable, Codable {
    case light = "Светлая"
    case dark = "Темная"
    case blue = "Синяя"

    /// Возвращает соответствующий объект темы.
    var theme: ThemeProtocol {
        switch self {
        case .light:
            return LightTheme()
        case .dark:
            return DarkTheme()
        case .blue:
            return BlueTheme()
        }
    }
}

// MARK: - Конкретные реализации тем

/// Светлая тема
struct LightTheme: ThemeProtocol {
    let backgroundColor: UIColor = .white
    let secondaryBackgroundColor: UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0) // Светло-серый
    let cellBackgroundColor: UIColor = .white
    let textColor: UIColor = .black
    let secondaryTextColor: UIColor = .darkGray
    let accentColor: UIColor = .systemBlue
    let navigationBarColor: UIColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0) // Почти белый
    let navigationTitleColor: UIColor = .black
    let navigationTintColor: UIColor = .systemBlue
    let tabBarColor: UIColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
    let tabBarUnselectedItemColor: UIColor = .lightGray
    let tabBarSelectedItemColor: UIColor = .systemBlue
    let statusBarStyle: UIStatusBarStyle = .darkContent
    let separatorColor: UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) // Светло-серый
}

/// Темная тема
struct DarkTheme: ThemeProtocol {
    let backgroundColor: UIColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0) // Очень темный серый
    let secondaryBackgroundColor: UIColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) // Темно-серый
    let cellBackgroundColor: UIColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.0) // Чуть светлее фона ячейки
    let textColor: UIColor = .white
    let secondaryTextColor: UIColor = .lightGray
    let accentColor: UIColor = .systemOrange
    let navigationBarColor: UIColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
    let navigationTitleColor: UIColor = .white
    let navigationTintColor: UIColor = .systemOrange
    let tabBarColor: UIColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.0) // Сделаем чуть светлее, как фон ячеек
    let tabBarUnselectedItemColor: UIColor = .lightGray // Чуть ярче для лучшей видимости
    let tabBarSelectedItemColor: UIColor = .systemOrange
    let statusBarStyle: UIStatusBarStyle = .lightContent
    let separatorColor: UIColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Темно-серый, чуть заметный
}

/// Синяя тема
struct BlueTheme: ThemeProtocol {
    let backgroundColor: UIColor = UIColor(red: 0.90, green: 0.94, blue: 1.0, alpha: 1.0) // Очень светло-синий (E6F0FF)
    let secondaryBackgroundColor: UIColor = UIColor(red: 0.82, green: 0.88, blue: 0.98, alpha: 1.0) // Светло-синий (D1E0FA)
    let cellBackgroundColor: UIColor = UIColor(red: 0.96, green: 0.98, blue: 1.0, alpha: 1.0) // Почти белый с синеватым оттенком (F5FAFF)
    let textColor: UIColor = UIColor(red: 0.05, green: 0.15, blue: 0.30, alpha: 1.0) // Очень темно-синий (0D264D)
    let secondaryTextColor: UIColor = UIColor(red: 0.25, green: 0.35, blue: 0.50, alpha: 1.0) // Темно-серый синий (405980)
    let accentColor: UIColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Яркий синий (System Blue)
    let navigationBarColor: UIColor = UIColor(red: 0.82, green: 0.88, blue: 0.98, alpha: 1.0) // Светло-синий (D1E0FA)
    let navigationTitleColor: UIColor = UIColor(red: 0.05, green: 0.15, blue: 0.30, alpha: 1.0) // Очень темно-синий (0D264D)
    let navigationTintColor: UIColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Яркий синий (System Blue)
    let tabBarColor: UIColor = UIColor(red: 0.82, green: 0.88, blue: 0.98, alpha: 1.0) // Светло-синий (D1E0FA)
    let tabBarUnselectedItemColor: UIColor = UIColor(red: 0.35, green: 0.45, blue: 0.60, alpha: 1.0) // Приглушенный синий (597399)
    let tabBarSelectedItemColor: UIColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Яркий синий (System Blue)
    let statusBarStyle: UIStatusBarStyle = .darkContent // На светло-синем фоне темный контент
    let separatorColor: UIColor = UIColor(red: 0.75, green: 0.82, blue: 0.90, alpha: 1.0) // Светло-сине-серый
}

// MARK: - ThemeManager

/// Менеджер тем, отвечающий за применение и сохранение выбранной темы.
final class ThemeManager {
    /// Синглтон экземпляр ThemeManager.
    static let shared = ThemeManager()

    /// Ключ для сохранения текущей темы в UserDefaults.
    private let themeKey = "selectedTheme"

    /// Уведомление, отправляемое при смене темы.
    static let themeDidChangeNotification = Notification.Name("themeDidChangeNotification")

    /// Текущая активная тема. При установке нового значения, тема применяется и сохраняется.
    var currentTheme: AppTheme {
        didSet {
            saveTheme()
            applyGlobalTheme()
            NotificationCenter.default.post(name: ThemeManager.themeDidChangeNotification, object: nil)
        }
    }

    /// Приватный конструктор для синглтона.
    private init() {
        // Загружаем сохраненную тему или устанавливаем светлую по умолчанию
        if let storedThemeValue = UserDefaults.standard.string(forKey: themeKey),
           let storedTheme = AppTheme(rawValue: storedThemeValue) {
            self.currentTheme = storedTheme
        } else {
            self.currentTheme = .light // Тема по умолчанию
        }
        applyGlobalTheme() // Применяем начальную тему
    }

    /// Сохраняет текущую выбранную тему в UserDefaults.
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
    }

    /// Применяет глобальные настройки внешнего вида на основе текущей темы.
    /// Это затрагивает элементы, которые настраиваются через `UIAppearance`.
    private func applyGlobalTheme() {
        let themeColors = currentTheme.theme

        // Настройка Navigation Bar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = themeColors.navigationBarColor
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: themeColors.navigationTitleColor]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: themeColors.navigationTitleColor]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().tintColor = themeColors.navigationTintColor

        // Настройка Tab Bar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = themeColors.tabBarColor
        
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.iconColor = themeColors.tabBarUnselectedItemColor
        tabBarItemAppearance.normal.titleTextAttributes = [.foregroundColor: themeColors.tabBarUnselectedItemColor]
        tabBarItemAppearance.selected.iconColor = themeColors.tabBarSelectedItemColor
        tabBarItemAppearance.selected.titleTextAttributes = [.foregroundColor: themeColors.tabBarSelectedItemColor]
        
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.inlineLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = tabBarItemAppearance
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        UITabBar.appearance().tintColor = themeColors.tabBarSelectedItemColor // Для iOS < 13

        // Обновление статус-бара (требует дополнительной настройки в Info.plist и контроллерах)
        // UIApplication.shared.statusBarStyle - устарело.
        // Вместо этого используйте preferredStatusBarStyle в каждом UIViewController
        // и убедитесь, что "View controller-based status bar appearance" в Info.plist установлен в YES.
        
        // Принудительное обновление UI для всех окон
        for windowScene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            for window in windowScene.windows {
                window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                // Можно также рекурсивно пройтись по всем subviews и вызвать applyTheme, если это необходимо
                // но лучше, чтобы каждый контроллер сам подписывался на уведомление
            }
        }
    }
    
    /// Возвращает конкретный объект `ThemeProtocol` для текущей `currentTheme`.
    func getCurrentThemeColors() -> ThemeProtocol {
        return currentTheme.theme
    }
}
