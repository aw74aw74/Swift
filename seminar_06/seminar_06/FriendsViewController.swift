import UIKit
import UIKit
import Foundation

// Модели данных из Models.swift доступны автоматически, так как находятся в одном модуле

/// Контроллер представления для экрана "Друзья"
///
/// Данный класс отвечает за отображение списка друзей пользователя.
/// Экран содержит профиль с изображением, имя пользователя и таблицу с друзьями.

final class FriendsViewController: UIViewController {
    
    // Вложенный enum для ошибок сети, специфичных для FriendsViewController
    enum NetworkError: Error, LocalizedError {
        case simulatedError
        case dataDecodingError
        // Можно добавить другие типы ошибок по мере необходимости

        var errorDescription: String? {
            switch self {
            case .simulatedError:
                return "Это имитируемая ошибка сети. Попробуйте еще раз."
            case .dataDecodingError:
                return "Произошла ошибка при обработке полученных данных."
            }
        }
    }
    
    // MARK: - Константы и переменные
    
    /// Делегат для кастомного перехода к экрану профиля
    private let transitionDelegate = CustomTransitionDelegate()
    
    /// Массив друзей для отображения в таблице
    private var friends: [Friend] = []
    
    /// Индекс выбранного друга
    /// По умолчанию выбран первый друг в списке
    private var selectedFriendIndex = 0
    

    
    /// Изображение выбранного друга
    private var selectedFriendImage: UIImage?
    
    /// Метод для установки данных друзей
    /// - Parameter newFriends: Массив друзей для отображения
    func setFriends(_ newFriends: [Friend]) {
        friends = newFriends
        tableView.reloadData()
        updateSelectedFriend()
    }
    
    // Данные загружаются из JSON через MainTabBarController
    
    // Модели для декодирования JSON перенесены в отдельный файл Models.swift
    
    // MARK: - UI компоненты
    
    /// Метка заголовка "Друзья"
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Друзья"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Изображение выбранного друга под заголовком
    private let selectedFriendImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        // backgroundColor и borderColor будут установлены в applyCurrentTheme
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.layer.borderWidth = 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Метка для отображения имени выбранного друга
    /// Располагается под изображением профиля
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    
    /// Таблица для отображения списка друзей
    /// Занимает основную часть экрана под профилем
    private let refreshControl = UIRefreshControl()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendsCell")
        return tableView
    }()
    
    // MARK: - Методы жизненного цикла
    
    /// Вызывается после загрузки представления
    /// Инициализирует пользовательский интерфейс
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefreshControl()
        applyCurrentTheme() // Применяем начальную тему
        
        // Подписываемся на уведомления о смене темы
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: ThemeManager.themeDidChangeNotification, object: nil)

        // Устанавливаем первого друга как выбранного по умолчанию
        updateSelectedFriend()
        
        // Загружаем изображение для первого друга, если есть
        if !friends.isEmpty {
            loadFriendImage(from: friends[0].avatarUrl)
        } else {
            // Если список друзей пуст, можно установить заглушку или скрыть изображение
            self.selectedFriendImageView.image = UIImage(systemName: "person.crop.circle.fill")
            // tintColor будет установлен в applyCurrentTheme, вызываемом через didSet selectedFriendImage
            self.selectedFriendImage = self.selectedFriendImageView.image // Обновляем свойство для didSet
            nameLabel.text = "Нет друзей"
            selectedFriendImage = nil
        }
    }
    
    /// Обновляет информацию о выбранном друге
    /// Устанавливает имя друга и загружает его фото
    private func updateSelectedFriend() {
        if !friends.isEmpty {
            let friend = friends[selectedFriendIndex]
            nameLabel.text = friend.name
            loadFriendImage(from: friend.avatarUrl)
        } else {
            // Если список друзей пуст, устанавливаем заглушку
            nameLabel.text = "Нет данных"
            selectedFriendImageView.image = UIImage(systemName: "person.crop.circle.fill")
            selectedFriendImage = nil
        }
    }
    
    /// Загружает изображение друга асинхронно
    /// - Parameter urlString: URL изображения друга
    private func loadFriendImage(from urlString: String) {
        // Проверяем наличие URL
        guard let url = URL(string: urlString) else {
            // Если URL неверный, устанавливаем заглушку
            selectedFriendImageView.image = UIImage(systemName: "person.circle.fill")
            selectedFriendImage = selectedFriendImageView.image // Обновляем для вызова didSet -> applyCurrentTheme
            return
        }
        
        // Запускаем асинхронную загрузку изображения
        DispatchQueue.global().async { [weak self] in
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.selectedFriendImage = image
                        self?.selectedFriendImageView.image = image
                    }
                }
            } catch {
                // В случае ошибки загрузки устанавливаем заглушку
                DispatchQueue.main.async {
                    self?.selectedFriendImageView.image = UIImage(systemName: "person.circle.fill")
                    self?.selectedFriendImage = self?.selectedFriendImageView.image // Обновляем для вызова didSet -> applyCurrentTheme
                }
            }
        }
    }
    
    // MARK: - Настройка интерфейса
    
    /// Настраивает пользовательский интерфейс
    /// Вызывает отдельные методы для настройки различных аспектов интерфейса
    private func setupUI() {
        setupViewAppearance()
        addSubviews()
        setupDelegates()
        setupConstraints()
    }
    
    /// Настраивает внешний вид основного представления
    /// - Устанавливает цвет фона, заголовок и кнопку профиля
    private func setupViewAppearance() {
        view.backgroundColor = .white
        title = "Друзья"
        
        // Добавляем кнопку профиля в навигационную панель
        let profileButton = UIBarButtonItem(
            title: "Профиль",
            style: .plain,
            target: self,
            action: #selector(profileButtonTapped)
        )
        navigationItem.rightBarButtonItem = profileButton
    }
    
    /// Обработчик нажатия на кнопку профиля
    @objc private func profileButtonTapped() {
        // 1. Создаем данные для текущего пользователя
        let currentUser = Friend(
            id: 0, // Уникальный ID для текущего пользователя, например, 0 или -1
            name: "Пользователь Юзеров",
            avatarUrl: "https://i.pravatar.cc/300?u=user_yuzerov_profile", // Пример URL для аватара
            isOnline: true
        )

        // 2. Создаем FriendProfileViewController (тот же, что используется для отображения профилей друзей)
        let friendProfileVC = FriendProfileViewController()

        // 3. Передаем данные текущего пользователя в контроллер профиля
        // Убедитесь, что FriendProfileViewController имеет публичное свойство `var friend: Friend?`
        friendProfileVC.friend = currentUser
        
        // 4. Выполняем переход (push) на экран профиля
        // Это добавит экран профиля в текущий стек навигации FriendsViewController
        self.navigationController?.pushViewController(friendProfileVC, animated: true)
    }

    
    /// Добавляет все подпредставления на основное представление
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(selectedFriendImageView)
        view.addSubview(nameLabel)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
    }
    
    /// Настраивает делегаты и источники данных
    private func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Устанавливаем начальные значения для меток
        titleLabel.text = "Выбранный друг"
        nameLabel.text = "Нет выбранных друзей"
    }

    /// Настраивает UIRefreshControl
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    /// Настраивает констрейнты для всех подпредставлений
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Констрейнты для индикатора активности (должны быть добавлены)
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            // Констрейнты для заголовка "Друзья"
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            selectedFriendImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            selectedFriendImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedFriendImageView.widthAnchor.constraint(equalToConstant: 80),
            selectedFriendImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Констрейнты для метки с именем
            nameLabel.topAnchor.constraint(equalTo: selectedFriendImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Констрейнты для таблицы
            tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Применение темы

    /// Применяет текущую тему к элементам UI
    // MARK: - Обработчики действий

    private func fetchUpdatedFriends(completion: @escaping (Result<[Friend], Error>) -> Void) {
        print("ℹ️ FriendsViewController: Начало имитации загрузки обновленного списка друзей...")
        // Имитация сетевой задержки
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            // Для имитации ошибки, установите это в true:
            let simulateError = false

            if simulateError {
                print("❌ FriendsViewController: Имитация ошибки сети.")
                completion(.failure(NetworkError.simulatedError))
            } else {
                // Имитация успешного ответа: создаем новый или обновленный список друзей
                // Убедитесь, что структура Friend соответствует вашей модели (id, name, avatarUrl, isOnline)
                let updatedFriends = [
                    Friend(id: 101, name: "Елена Новая", avatarUrl: "https://i.pravatar.cc/150?img=27", isOnline: true),
                    Friend(id: 102, name: "Максим Свежий", avatarUrl: "https://i.pravatar.cc/150?img=33", isOnline: false),
                    Friend(id: self.friends.first?.id ?? 1, name: "\(self.friends.first?.name ?? "Первый Друг") (обновлено)", avatarUrl: self.friends.first?.avatarUrl ?? "https://i.pravatar.cc/150?img=1", isOnline: !(self.friends.first?.isOnline ?? false)),
                    Friend(id: 103, name: "Ольга Тестовая", avatarUrl: "https://i.pravatar.cc/150?img=45", isOnline: true)
                ]
                print("ℹ️ FriendsViewController: Имитация загрузки завершена успешно. Получено \(updatedFriends.count) друзей.")
                completion(.success(updatedFriends))
            }
        }
    }

    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        print("ℹ️ FriendsViewController: Сработал pull-to-refresh.")
        // Имитируем сетевой запрос
        // В реальном приложении здесь был бы вызов NetworkManager
        // А NetworkManager бы обновил данные и через SceneDelegate передал их в MainTabBarController,
        // который бы сохранил их в CoreData и обновил UI.
        // Сейчас мы просто покажем индикатор, подождем и скроем его.

    print("ℹ️ FriendsViewController: Начато обновление списка друзей (pull-to-refresh)...")

    fetchUpdatedFriends { [weak self] result in
        guard let self = self else { return }

        // Убедимся, что UI обновляется в главном потоке
        DispatchQueue.main.async {
            switch result {
            case .success(let newFriends):
                print("ℹ️ FriendsViewController: Получены обновленные данные друзей: \(newFriends.count) записей.")
                self.friends = newFriends // Обновляем основной массив данных
                self.tableView.reloadData() // Перезагружаем таблицу для отображения новых данных
                
                // Сохраняем полученных друзей в Core Data
                CoreDataManager.shared.saveFriends(newFriends)
                CoreDataManager.shared.setLastUpdateTimestampForFriends()
                print("ℹ️ FriendsViewController: Данные друзей обновлены в Core Data")

                // Обновляем информацию о выбранном друге в верхней части экрана, если список не пуст
                self.updateSelectedFriend()

            case .failure(let error):
                print("❌ FriendsViewController: Ошибка при обновлении списка друзей: \(error.localizedDescription)")
                // Показываем UIAlertController с ошибкой
                let alert = UIAlertController(title: "Ошибка обновления",
                                              message: error.localizedDescription, // Используем localizedDescription из нашего enum
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            self.refreshControl.endRefreshing() // Завершаем анимацию UIRefreshControl в любом случае
            print("ℹ️ FriendsViewController: Обновление списка друзей (pull-to-refresh) завершено.")
        }
    }
            
            // Показываем сообщение о последнем обновлении (если есть)
            if let lastUpdate = CoreDataManager.shared.getLastUpdateTimestampForFriends() {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                // Можно показать это в UILabel или UIAlertController
                print("ℹ️ Данные о друзьях последний раз обновлялись: \(dateFormatter.string(from: lastUpdate))")
            } else {
                print("ℹ️ Время последнего обновления друзей не найдено.")
            }
        }

    // MARK: - Применение темы

    @objc private func applyCurrentTheme() {
        let currentThemeColors = ThemeManager.shared.getCurrentThemeColors()

        view.backgroundColor = currentThemeColors.backgroundColor
        tableView.backgroundColor = currentThemeColors.backgroundColor // или secondaryBackgroundColor, если нужно отличие
        tableView.separatorColor = currentThemeColors.separatorColor

        titleLabel.textColor = currentThemeColors.textColor
        nameLabel.textColor = currentThemeColors.secondaryTextColor
        
        selectedFriendImageView.layer.borderColor = currentThemeColors.accentColor.cgColor
        selectedFriendImageView.backgroundColor = currentThemeColors.secondaryBackgroundColor // Для фона, если изображение не загружено или прозрачное

        // Устанавливаем tintColor для placeholder'а, если он используется
        // Сравниваем по имени системного изображения, чтобы определить, является ли текущее изображение плейсхолдером
        if selectedFriendImageView.image == UIImage(systemName: "person.circle.fill") {
            selectedFriendImageView.tintColor = currentThemeColors.accentColor
        } else {
            selectedFriendImageView.tintColor = nil // Сбрасываем tint, если это не placeholder
        }

        refreshControl.tintColor = currentThemeColors.accentColor
        activityIndicator.color = currentThemeColors.accentColor
        
        // Обновляем стиль NavigationBar
        if let navController = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground() // Стандартный непрозрачный фон
            appearance.backgroundColor = currentThemeColors.navigationBarColor
            appearance.titleTextAttributes = [.foregroundColor: currentThemeColors.navigationTitleColor]
            appearance.largeTitleTextAttributes = [.foregroundColor: currentThemeColors.navigationTitleColor] // Если используются большие заголовки
            
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance // Для iOS 13+ при прокрутке до края
            navController.navigationBar.compactAppearance = appearance // Для компактного вида (например, в landscape на iPhone)
            
            navController.navigationBar.tintColor = currentThemeColors.navigationTintColor // Цвет кнопок (back, right bar button items)
        }
        
        setNeedsStatusBarAppearanceUpdate() // Обновить стиль статус-бара
        tableView.reloadData() // Перезагружаем таблицу для обновления ячеек
    }

    // MARK: - Theme Handling

    @objc private func themeDidChange() {
        applyCurrentTheme()
    }

    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.getCurrentThemeColors().statusBarStyle
    }

/*
    deinit {
        // Отписываемся от уведомлений
        NotificationCenter.default.removeObserver(self, name: ThemeManager.themeDidChangeNotification, object: nil)
    }
*/
}

// MARK: - UITableViewDelegate, UITableViewDataSource
/// Расширение для реализации протоколов UITableViewDelegate и UITableViewDataSource
/// Обеспечивает функциональность таблицы друзей
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Обрабатывает выбор ячейки в таблице
    /// - Parameters:
    ///   - tableView: Таблица, в которой произошел выбор
    ///   - indexPath: Индекс пути выбранной ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Получаем выбранного друга
        let selectedFriend = friends[indexPath.row]
        
        // Обновляем UI для отображения выбранного друга в самом FriendsViewController (если это еще нужно)
        selectedFriendIndex = indexPath.row
        updateSelectedFriend() 

        // Создаем и настраиваем FriendProfileViewController
        let friendProfileVC = FriendProfileViewController()
        friendProfileVC.friend = selectedFriend
        
        // Выполняем переход
        // Убедимся, что FriendsViewController встроен в UINavigationController
        // Это должно быть сделано в MainTabBarController при создании FriendsViewController
        navigationController?.pushViewController(friendProfileVC, animated: true)
    }
    
    /// Возвращает количество строк в секции таблицы
    /// - Parameters:
    ///   - tableView: Таблица, запрашивающая информацию
    ///   - section: Индекс секции
    /// - Returns: Количество строк (ячеек) в секции, равное количеству друзей в массиве
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    /// Создает и настраивает ячейку для отображения в таблице
    /// - Parameters:
    ///   - tableView: Таблица, запрашивающая ячейку
    ///   - indexPath: Индекс пути для запрашиваемой ячейки
    /// - Returns: Настроенная ячейка таблицы с именем друга из массива
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FriendsCellSubtitle" // Используем отдельный идентификатор для ячеек .subtitle
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        if cell == nil {
            // Если ячейка с таким идентификатором не зарегистрирована или не может быть переиспользована,
            // создаем новую ячейку в стиле .subtitle.
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let friend = friends[indexPath.row]
        let currentThemeColors = ThemeManager.shared.getCurrentThemeColors()

        cell!.textLabel?.text = friend.name
        cell!.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular) // Шрифт для основного текста
        cell!.textLabel?.textColor = currentThemeColors.textColor
        
        // Убираем detailTextLabel, так как статус будет отображаться индикатором
        cell!.detailTextLabel?.text = nil

        // Создаем индикатор статуса (лампочку)
        let statusIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        statusIndicatorView.layer.cornerRadius = 5 // Делаем круглым
        statusIndicatorView.backgroundColor = friend.isOnline ? .systemGreen : .systemGray
        cell!.accessoryView = statusIndicatorView
        
        cell!.backgroundColor = currentThemeColors.cellBackgroundColor
        
        // Настройка selectedBackgroundView для подсветки выбранной ячейки
        let selectedView = UIView()
        selectedView.backgroundColor = currentThemeColors.accentColor.withAlphaComponent(0.3) // Полупрозрачный акцентный цвет
        cell!.selectedBackgroundView = selectedView
        
        return cell!
    }
} // Закрывающая скобка для extension FriendsViewController
