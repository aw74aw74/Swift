import UIKit

class FriendProfileViewController: UIViewController {

    // MARK: - Свойства

    var friend: Friend? {
        didSet {
            configureView()
        }
    }

    // MARK: - UI Элементы

    private lazy var themeSegmentedControl: UISegmentedControl = {
        let items = AppTheme.allCases.map { $0.rawValue } // Используем rawValue для названий сегментов
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(themeSegmentedControlChanged(_:)), for: .valueChanged)
        segmentedControl.isHidden = true // Изначально скрыт
        return segmentedControl
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75 // Больший радиус для профиля
        imageView.backgroundColor = .systemGray5 // Плейсхолдер
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    /// Индикатор онлайн-статуса друга (кружок)
    private let onlineStatusIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6 // Диаметр 12
        view.layer.borderWidth = 1.5
        return view
    }()

    /// Текстовая метка онлайн-статуса друга
    private let onlineStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    //    private let onlineStatusLabel: UILabel = {



    // MARK: - Жизненный цикл

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureView() // Заполняет данными друга
        applyCurrentTheme() // Применяем начальную тему к элементам контроллера
        // Подписываемся на уведомления об изменении темы
        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChange), name: ThemeManager.themeDidChangeNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIBasedOnFriend() // Сначала настраиваем видимость элементов и заголовок
        applyCurrentTheme()     // Затем применяем все стили темы
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: ThemeManager.themeDidChangeNotification, object: nil)
    }

    // MARK: - Настройка UI

    private func setupView() {
        view.backgroundColor = .systemBackground // Используем системный фон, он сам адаптируется к теме
        // Заголовок и видимость segmented control будут установлены в viewWillAppear

        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(onlineStatusLabel)         // Добавляем текстовую метку статуса
        view.addSubview(onlineStatusIndicatorView) // Добавляем круговой индикатор статуса
        view.addSubview(themeSegmentedControl)     // Добавляем segmented control

        setupConstraints()
    }

    private func configureView() {
        guard let friend = friend, isViewLoaded else { return }

        nameLabel.text = friend.name

        if friend.id == 0 { // Предполагаем, что id текущего пользователя = 0 (личный профиль)
            onlineStatusIndicatorView.isHidden = true
            onlineStatusLabel.isHidden = true
        } else { // Профиль друга
            onlineStatusIndicatorView.isHidden = false
            onlineStatusLabel.isHidden = false
            onlineStatusIndicatorView.backgroundColor = friend.isOnline ? .systemGreen : .systemGray
            onlineStatusLabel.text = friend.isOnline ? "в сети" : "не в сети"
        }
        // Цвет для onlineStatusLabel и рамки onlineStatusIndicatorView будет устанавливаться в applyCurrentTheme

        if let avatarUrl = URL(string: friend.avatarUrl) { // Используем friend.avatarUrl напрямую
            // Загрузка изображения (асинхронно)
            URLSession.shared.dataTask(with: avatarUrl) { [weak self] data, response, error in
                guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        self?.avatarImageView.image = UIImage(systemName: "person.crop.circle.fill") // Системная иконка-заглушка
                        // tintColor для заглушки будет установлен в applyCurrentTheme
                        self?.applyCurrentTheme() // Применить тему, чтобы цвет заглушки и другие стили обновились
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.avatarImageView.image = image
                    self.applyCurrentTheme() // Применить тему, чтобы рамка и фон обновились
                }
            }.resume()
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill") // Системная иконка-заглушка
            // tintColor для заглушки будет установлен в applyCurrentTheme
            applyCurrentTheme() // Убедимся, что тема применена, если изображение не загружается
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 150),
            avatarImageView.heightAnchor.constraint(equalToConstant: 150),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Констрейнты для текстовой метки статуса
            onlineStatusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            onlineStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Констрейнты для кругового индикатора статуса (справа от текстовой метки)
            onlineStatusIndicatorView.centerYAnchor.constraint(equalTo: onlineStatusLabel.centerYAnchor),
            onlineStatusIndicatorView.leadingAnchor.constraint(equalTo: onlineStatusLabel.trailingAnchor, constant: 8),
            onlineStatusIndicatorView.widthAnchor.constraint(equalToConstant: 12),
            onlineStatusIndicatorView.heightAnchor.constraint(equalToConstant: 12),

            // Констрейнты для segmented control, теперь ниже onlineStatusLabel
            themeSegmentedControl.topAnchor.constraint(equalTo: onlineStatusLabel.bottomAnchor, constant: 20),
            themeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            themeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Темизация

    private func applyCurrentTheme() {
        let currentThemeColors = ThemeManager.shared.currentTheme.theme

        view.backgroundColor = currentThemeColors.backgroundColor // Явно устанавливаем фон
        nameLabel.textColor = currentThemeColors.textColor
        onlineStatusIndicatorView.layer.borderColor = currentThemeColors.backgroundColor.cgColor // Рамка в цвет фона

        if let currentFriend = friend, currentFriend.id != 0 { // Только для профиля друга и если он не скрыт
            if !onlineStatusLabel.isHidden {
                 onlineStatusLabel.textColor = currentFriend.isOnline ? UIColor.systemGreen : currentThemeColors.secondaryTextColor
            }
        } else {
            // Для личного профиля onlineStatusLabel скрыт, цвет не важен
            onlineStatusLabel.textColor = .clear // На всякий случай, если он вдруг окажется видимым
        }

        // Если бы у нас был onlineStatusLabel, мы бы настроили его цвет здесь:
        // if let friend = friend {
//            onlineStatusLabel.textColor = currentFriend.isOnline ? currentThemeColors.accentColor : currentThemeColors.secondaryTextColor
//        } else {
//            onlineStatusLabel.textColor = currentThemeColors.secondaryTextColor // По умолчанию, если друг не определен
//        }

        // Настройка avatarImageView
        if avatarImageView.image == UIImage(systemName: "person.crop.circle.fill") {
            avatarImageView.backgroundColor = currentThemeColors.secondaryBackgroundColor
            avatarImageView.tintColor = currentThemeColors.secondaryTextColor // Цвет для системной иконки-заглушки
        } else {
            avatarImageView.backgroundColor = .clear // Если есть изображение, фон не нужен
            avatarImageView.tintColor = nil // Сбрасываем tintColor, если есть кастомное изображение
        }

        // Темизация UISegmentedControl
        if !themeSegmentedControl.isHidden {
            themeSegmentedControl.selectedSegmentTintColor = currentThemeColors.accentColor
            themeSegmentedControl.backgroundColor = currentThemeColors.secondaryBackgroundColor
            
            let titleTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: currentThemeColors.textColor]
            themeSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
            
            // Для выбранного сегмента можно использовать цвет, контрастный accentColor, например, цвет текста навигационной панели
            let selectedTitleTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: currentThemeColors.navigationTitleColor] 
            themeSegmentedControl.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        }
        
        updateThemeSegmentedControlSelection() // Убедимся, что выбран правильный сегмент

        // Обновление Navigation Bar
        if let navController = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = currentThemeColors.navigationBarColor
            appearance.titleTextAttributes = [.foregroundColor: currentThemeColors.navigationTitleColor]
            appearance.largeTitleTextAttributes = [.foregroundColor: currentThemeColors.navigationTitleColor]
            
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
            navController.navigationBar.tintColor = currentThemeColors.navigationTintColor
        }
        
        // Обновление статус-бара
        setNeedsStatusBarAppearanceUpdate()
        
        // Принудительное обновление некоторых элементов, если это необходимо
        view.setNeedsLayout()
    }

    // MARK: - Обработчики событий и логика UI

    private func updateUIBasedOnFriend() {
        if friend?.id == 0 { // Предполагаем, что id текущего пользователя = 0
            navigationItem.title = "Профиль"
            themeSegmentedControl.isHidden = false
            updateThemeSegmentedControlSelection()
        } else {
            navigationItem.title = friend?.name ?? "Профиль друга"
            themeSegmentedControl.isHidden = true
        }
        // Принудительно обновляем внешний вид navigationBar, если он уже был показан
        // Это может быть полезно, если title меняется после того, как view уже появилось.
        navigationController?.navigationBar.layoutIfNeeded()
    }

    private func updateThemeSegmentedControlSelection() {
        if !themeSegmentedControl.isHidden {
            if let currentIndex = AppTheme.allCases.firstIndex(of: ThemeManager.shared.currentTheme) {
                themeSegmentedControl.selectedSegmentIndex = currentIndex
            }
        }
    }

    @objc private func themeSegmentedControlChanged(_ sender: UISegmentedControl) {
        // Убедимся, что индекс в пределах массива allCases
        if sender.selectedSegmentIndex >= 0 && sender.selectedSegmentIndex < AppTheme.allCases.count {
            let selectedTheme = AppTheme.allCases[sender.selectedSegmentIndex]
            ThemeManager.shared.currentTheme = selectedTheme
        } else {
            print("⚠️ FriendProfileViewController: Выбран неверный индекс сегмента: \(sender.selectedSegmentIndex)")
        }
    }

    @objc private func handleThemeChange() {
        applyCurrentTheme() // Применяем тему ко всем элементам этого контроллера
    }

    // MARK: - Status Bar

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.theme.statusBarStyle
    }
}
