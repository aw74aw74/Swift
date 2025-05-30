import UIKit

/// Контроллер представления для экрана "Друзья"
///
/// Данный класс отвечает за отображение списка друзей пользователя.
/// Экран содержит профиль с изображением, имя пользователя и таблицу с друзьями.
final class FriendsViewController: UIViewController {
    
    // MARK: - Константы и переменные
    
    /// Модель данных друга
    struct Friend: Codable {
        let id: Int
        let name: String
        let avatarUrl: String
        let isOnline: Bool
    }
    
    /// Массив друзей для отображения в таблице
    private var friends: [Friend] = []
    
    /// Индекс выбранного друга
    /// По умолчанию выбран первый друг в списке
    private var selectedFriendIndex = 0
    
    /// Флаг, отслеживающий, был ли уже выведен список друзей в консоль
    /// Используется для вывода списка только при первом переходе на экран
    private static var friendsListPrinted = false
    
    /// Метод для установки данных друзей
    func setFriends(_ newFriends: [Friend]) {
        friends = newFriends
        tableView.reloadData()
        updateSelectedFriend()
        
        // Выводим список друзей в консоль только при первом переходе на экран
        if !FriendsViewController.friendsListPrinted {
            printFriendsList()
            FriendsViewController.friendsListPrinted = true
        }
    }
    
    // Данные загружаются из JSON через MainTabBarController
    
    /// Выводит список друзей в консоль, имитируя запрос к API VK
    private func printFriendsList() {
        print("\n=== Запрос к API VK: friends.get ===")
        
        // Имитация параметров запроса к API VK
        let requestParams = [
            "user_id": "12345",
            "order": "name",
            "fields": "photo_100,online",
            "count": "\(friends.count)",
            "access_token": "mocked_token",
            "v": "5.131"
        ]
        
        print("Параметры запроса:")
        for (key, value) in requestParams {
            print("  \(key): \(value)")
        }
        
        print("\nПолучено друзей: \(friends.count)")
        print("Список друзей:")
        
        for (index, friend) in friends.enumerated() {
            let onlineStatus = friend.isOnline ? "Онлайн" : "Не в сети"
            print("\(index + 1). ID: \(friend.id), Имя: \(friend.name), Статус: \(onlineStatus), Аватар: \(friend.avatarUrl)")
        }
        
        // Добавляем имитацию времени выполнения запроса
        let executionTime = String(format: "%.3f", Double.random(in: 0.1...0.5))
        print("\nВремя выполнения запроса: \(executionTime) сек")
        print("=== Конец списка друзей ===\n")
    }
    
    /// Структура для декодирования всего JSON-файла
    private struct MockData: Codable {
        let friends: [Friend]
        let groups: [Group]
        let photos: [Photo]
    }
    
    private struct Group: Codable {
        let id: Int
        let name: String
        let description: String
        let avatarUrl: String
    }
    
    private struct Photo: Codable {
        let id: Int
        let url: String
    }
    
    // MARK: - UI компоненты
    
    /// Метка для отображения имени выбранного друга
    /// Располагается под изображением профиля
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Изображение профиля пользователя
    /// Отображается в верхней части экрана
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.cornerRadius = 25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
    /// Устанавливает имя друга в соответствии с выбранным индексом
    private func updateSelectedFriend() {
        if !friends.isEmpty {
            nameLabel.text = friends[selectedFriendIndex].name
        } else {
            nameLabel.text = "Нет данных"
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
    /// - Устанавливает цвет фона и заголовок
    private func setupViewAppearance() {
        view.backgroundColor = .white
        title = "Друзья"
    }
    
    /// Добавляет все подпредставления на основное представление
    private func addSubviews() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(tableView)
    }
    
    /// Настраивает делегаты и источники данных
    private func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /// Устанавливает ограничения Auto Layout для всех элементов интерфейса
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Ограничения для изображения профиля
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Ограничения для метки имени
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Ограничения для таблицы
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
