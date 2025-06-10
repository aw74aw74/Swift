import UIKit
import Foundation

/// Контроллер представления для экрана "Профиль"
///
/// Данный класс отвечает за отображение профиля пользователя.
/// Экран содержит круглое фото пользователя и его имя.
/// Представляется модально с кастомной анимацией перехода.
final class ProfileViewController: UIViewController {
    
    // MARK: - UI элементы для выбора темы
    
    private lazy var themeLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите тему:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var themeSegmentedControl: UISegmentedControl = {
        let items = AppTheme.allCases.map { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(themeSegmentDidChange(_:)), for: .valueChanged)
        return control
    }()
    
    // MARK: - Константы и переменные
    
    /// Имя пользователя для отображения
    private var userName: String = ""
    
    /// URL аватара пользователя
    private var avatarUrl: String = ""
    
    // MARK: - UI элементы
    
    /// Изображение профиля
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Метка с именем пользователя
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI() // Загружает имя и аватар
        setupThemeSegmentedControlInitialState() // Устанавливаем выбранный сегмент
        applyTheme() // Применяем начальную тему

        // Подписываемся на уведомления об изменении темы
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applyTheme),
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )
    }
    
    // MARK: - Настройка UI
    
    /// Настраивает пользовательский интерфейс
    private func setupUI() {
        view.backgroundColor = .white
        title = "Профиль"
        
        // Добавляем элементы на view
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(themeLabel)
        view.addSubview(themeSegmentedControl)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Констрейнты для элементов выбора темы
            themeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
            themeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            themeSegmentedControl.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 8),
            themeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            themeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Добавляем кнопку закрытия
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }
    
    /// Обновляет UI с текущими данными
    private func updateUI() {
        // Обновляем имя пользователя
        nameLabel.text = userName
        
        // Загружаем изображение, если URL не пустой
        loadProfileImage()
    }
    
    /// Загружает изображение профиля асинхронно
    private func loadProfileImage() {
        // Проверяем наличие URL
        guard !avatarUrl.isEmpty, let url = URL(string: avatarUrl) else {
            // Если URL неверный, устанавливаем заглушку
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            return
        }
        
        // Запускаем асинхронную загрузку изображения
        DispatchQueue.global().async { [weak self] in
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                }
            } catch {
                // В случае ошибки загрузки устанавливаем заглушку
                DispatchQueue.main.async {
                    self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
    }
    
    // MARK: - Действия
    
    /// Обработчик нажатия на кнопку закрытия
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Публичные методы
    
    /// Устанавливает данные профиля
    /// - Parameters:
    ///   - name: Имя пользователя
    ///   - avatarUrl: URL аватара пользователя
    func setProfileData(name: String, avatarUrl: String) {
        self.userName = name
        self.avatarUrl = avatarUrl
        
        // Если view уже загружен, обновляем UI
        if isViewLoaded {
            updateUI()
            applyTheme() // Применяем тему, если view уже загружен
        }
    }
    
    // MARK: - Применение темы
    
    /// Применяет текущую тему к элементам UI
    @objc private func applyTheme() {
        let themeColors = ThemeManager.shared.getCurrentThemeColors()
        
        view.backgroundColor = themeColors.backgroundColor
        nameLabel.textColor = themeColors.textColor
        themeLabel.textColor = themeColors.textColor
        
        // Стилизация SegmentedControl
        themeSegmentedControl.backgroundColor = themeColors.secondaryBackgroundColor
        themeSegmentedControl.selectedSegmentTintColor = themeColors.accentColor
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: themeColors.textColor]
        themeSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        
        // Для выбранного сегмента лучше использовать контрастный цвет, если accentColor светлый
        // Например, если accentColor - systemBlue, то текст может быть белым.
        // Если accentColor темный, текст может быть светлым.
        // Здесь для примера используется navigationTitleColor, но это может потребовать корректировки
        let selectedTitleTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: themeColors.navigationTitleColor] 
        themeSegmentedControl.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        
        // Обновление Navigation Bar (хотя ThemeManager уже делает это глобально через UIAppearance)
        // Это может быть полезно для немедленного эффекта или специфичных настроек
        navigationController?.navigationBar.barTintColor = themeColors.navigationBarColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeColors.navigationTitleColor]
        navigationController?.navigationBar.tintColor = themeColors.navigationTintColor
        if let largeTitleColor = themeColors.navigationTitleColor as? UIColor {
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
        }

        setNeedsStatusBarAppearanceUpdate() // Обновить стиль статус-бара
    }
    
    /// Обработчик изменения значения в SegmentedControl для выбора темы
    @objc private func themeSegmentDidChange(_ sender: UISegmentedControl) {
        let selectedTheme = AppTheme.allCases[sender.selectedSegmentIndex]
        ThemeManager.shared.currentTheme = selectedTheme
        // Уведомление из ThemeManager вызовет applyTheme()
    }
    
    /// Устанавливает начальное состояние SegmentedControl в соответствии с текущей темой
    private func setupThemeSegmentedControlInitialState() {
        if let currentThemeIndex = AppTheme.allCases.firstIndex(of: ThemeManager.shared.currentTheme) {
            themeSegmentedControl.selectedSegmentIndex = currentThemeIndex
        }
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.getCurrentThemeColors().statusBarStyle
    }

    deinit {
        // Отписываемся от уведомлений
        NotificationCenter.default.removeObserver(self, name: ThemeManager.themeDidChangeNotification, object: nil)
    }
}
