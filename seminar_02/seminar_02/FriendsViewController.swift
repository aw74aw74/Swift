import UIKit

/// Контроллер представления для экрана "Друзья"
///
/// Данный класс отвечает за отображение списка друзей пользователя.
/// Экран содержит профиль с изображением, имя пользователя и таблицу с друзьями.
final class FriendsViewController: UIViewController {
    
    // MARK: - Константы и переменные
    
    /// Массив друзей для отображения в таблице
    /// Содержит имена друзей
    private let friends = [
        "Иван Иванов",
        "Петр Петров",
        "Александр Сидоров",
        "Екатерина Смирнова",
        "Мария Кузнецова"
    ]
    
    /// Индекс выбранного друга
    /// По умолчанию выбран первый друг в списке
    private var selectedFriendIndex = 0
    
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
        updateSelectedFriend()
    }
    
    /// Обновляет информацию о выбранном друге
    /// Устанавливает имя друга в соответствии с выбранным индексом
    private func updateSelectedFriend() {
        nameLabel.text = friends[selectedFriendIndex]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath)
        cell.textLabel?.text = friends[indexPath.row]
        return cell
    }
}
