import UIKit

/// Контроллер представления для экрана "Группы"
///
/// Данный класс отвечает за отображение списка групп пользователя.
/// Экран содержит профиль с изображением, имя пользователя, описание и таблицу с группами.
final class GroupsViewController: UIViewController {
    
    // MARK: - Константы и переменные
    
    /// Массив групп, полученный из JSON
    /// Устанавливается из MainTabBarController после загрузки данных
    var groups: [ViewController.Group] = [] {
        didSet {
            // Обновляем интерфейс при изменении данных
            tableView.reloadData()
            if !groups.isEmpty {
                updateSelectedGroup()
            }
        }
    }
    
    // Массив групп загружается из JSON
    
    /// Индекс выбранной группы
    /// По умолчанию выбрана первая группа в списке
    private var selectedGroupIndex = 0
    
    // MARK: - UI компоненты
    
    /// Метка для отображения имени выбранной группы
    /// Располагается под изображением профиля
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Метка для отображения описания выбранной группы
    /// Располагается под именем группы
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0 // Разрешаем многострочный текст
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
    
    /// Таблица для отображения списка групп
    /// Занимает основную часть экрана под профилем и описанием
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GroupsCell")
        return tableView
    }()
    
    // MARK: - Методы жизненного цикла
    
    /// Флаг, отслеживающий, был ли уже выведен список групп в консоль
    /// Используется для вывода списка только при первом переходе на экран
    private static var groupsListPrinted = false
    
    /// Вызывается после загрузки представления
    /// Инициализирует пользовательский интерфейс и выводит список групп в консоль
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateSelectedGroup()
        
        // Выводим список групп в консоль только при первом переходе на экран
        if !GroupsViewController.groupsListPrinted {
            printGroupsList()
            GroupsViewController.groupsListPrinted = true
        }
    }
    
    /// Обновляет информацию о выбранной группе
    /// Устанавливает название и описание группы в соответствии с выбранным индексом
    private func updateSelectedGroup() {
        if !groups.isEmpty && selectedGroupIndex < groups.count {
            nameLabel.text = groups[selectedGroupIndex].name
            descriptionLabel.text = groups[selectedGroupIndex].description
            
            // Здесь можно добавить загрузку аватара группы, если необходимо
            // if let url = URL(string: groups[selectedGroupIndex].avatarUrl) {
            //     // Загрузка изображения с URL
            // }
        } else {
            nameLabel.text = "Нет данных"
            descriptionLabel.text = "Данные не загружены"
        }
    }
    
    /// Выводит список групп в консоль, имитируя запрос к API VK
    private func printGroupsList() {
        // Если группы не загружены, не выводим список
        if groups.isEmpty {
            print("Список групп не загружен")
            return
        }
        
        print("\n=== Запрос к API VK: groups.get ===")
        
        // Имитация параметров запроса к API VK
        let requestParams = [
            "user_id": "12345",
            "extended": "1",
            "filter": "admin",
            "fields": "description,members_count",
            "count": "\(groups.count)",
            "access_token": "mocked_token",
            "v": "5.131"
        ]
        
        print("Параметры запроса:")
        for (key, value) in requestParams {
            print("  \(key): \(value)")
        }
        
        print("\nПолучено групп: \(groups.count)")
        print("Список групп:\n")
        
        // Выводим список групп
        for (index, group) in groups.enumerated() {
            let membersCount = Int.random(in: 100...10000) // Случайное количество участников
            
            print("\(index + 1). ID: \(group.id), Название: \(group.name)")
            print("   Описание: \(group.description)")
            print("   Участников: \(membersCount)\n")
        }
        
        // Добавляем имитацию времени выполнения запроса
        let executionTime = String(format: "%.3f", Double.random(in: 0.1...0.5))
        print("Время выполнения запроса: \(executionTime) сек")
        print("=== Конец списка групп ===\n")
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
        title = "Группы"
    }
    
    /// Добавляет все подпредставления на основное представление
    private func addSubviews() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
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
            
            // Ограничения для метки описания
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Ограничения для таблицы
            tableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
/// Расширение для реализации протоколов UITableViewDelegate и UITableViewDataSource
/// Обеспечивает функциональность таблицы групп
extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Обрабатывает выбор ячейки в таблице
    /// - Parameters:
    ///   - tableView: Таблица, в которой произошел выбор
    ///   - indexPath: Индекс пути выбранной ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedGroupIndex = indexPath.row
        updateSelectedGroup()
    }
    
    /// Возвращает количество строк в секции таблицы
    /// - Parameters:
    ///   - tableView: Таблица, запрашивающая информацию
    ///   - section: Индекс секции
    /// - Returns: Количество строк (ячеек) в секции, равное количеству групп в массиве
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    /// Создает и настраивает ячейку для отображения в таблице
    /// - Parameters:
    ///   - tableView: Таблица, запрашивающая ячейку
    ///   - indexPath: Индекс пути для запрашиваемой ячейки
    /// - Returns: Настроенная ячейка таблицы с названием группы из массива
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsCell", for: indexPath)
        
        if indexPath.row < groups.count {
            cell.textLabel?.text = groups[indexPath.row].name
        } else {
            cell.textLabel?.text = "Нет данных"
        }
        
        return cell
    }
}
