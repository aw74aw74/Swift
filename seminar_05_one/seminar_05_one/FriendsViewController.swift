import UIKit
import Foundation

// Модели данных из Models.swift доступны автоматически, так как находятся в одном модуле

/// Контроллер представления для экрана "Друзья"
///
/// Данный класс отвечает за отображение списка друзей пользователя.
/// Экран содержит профиль с изображением, имя пользователя и таблицу с друзьями.
final class FriendsViewController: UIViewController {
    
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
        imageView.backgroundColor = .systemGray6
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
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
        // Данные загружаются через MainTabBarController и метод setFriends
    }
    
    /// Обновляет информацию о выбранном друге
    /// Устанавливает имя друга и загружает его фото
    private func updateSelectedFriend() {
        if !friends.isEmpty {
            let selectedFriend = friends[selectedFriendIndex]
            nameLabel.text = selectedFriend.name
            
            // Загружаем фото выбранного друга
            loadFriendImage(from: selectedFriend.avatarUrl)
        } else {
            nameLabel.text = "Нет данных"
            selectedFriendImageView.image = nil
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
        // Создаем экран профиля
        let profileVC = ProfileViewController()
        
        // Устанавливаем данные профиля из выбранного друга
        if !friends.isEmpty {
            let selectedFriend = friends[selectedFriendIndex]
            profileVC.setProfileData(name: selectedFriend.name, avatarUrl: selectedFriend.avatarUrl)
        }
        
        // Настраиваем навигацию и анимацию
        let navigationController = UINavigationController(rootViewController: profileVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.transitioningDelegate = transitionDelegate
        
        // Презентуем экран профиля
        present(navigationController, animated: true)
    }
    
    /// Добавляет все подпредставления на основное представление
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(selectedFriendImageView)
        view.addSubview(nameLabel)
        view.addSubview(tableView)
    }
    
    /// Настраивает делегаты и источники данных
    private func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /// Настраивает констрейнты для всех подпредставлений
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Констрейнты для заголовка "Друзья"
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Констрейнты для изображения выбранного друга
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
        selectedFriendIndex = indexPath.row
        updateSelectedFriend()
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
        // Получаем ячейку с идентификатором и стилем Subtitle
        var cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath)
        
        // Если ячейка не настроена для отображения подзаголовка, создаем новую
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "FriendsCell")
        }
        
        let friend = friends[indexPath.row]
        
        // Настраиваем основной текст - имя друга
        cell.textLabel?.text = friend.name
        
        // Добавляем индикатор статуса онлайн
        let onlineStatus = friend.isOnline ? "🟢 Онлайн" : "⚪️ Не в сети"
        cell.detailTextLabel?.text = onlineStatus
        
        // Устанавливаем цвет текста в зависимости от статуса
        cell.detailTextLabel?.textColor = friend.isOnline ? .systemGreen : .systemGray
        
        return cell
    }
}
