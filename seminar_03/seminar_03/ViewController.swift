import UIKit

/// Контроллер экрана авторизации
/// Загружает данные из JSON-файла на GitHub
/// При успешной загрузке переходит на TabBarController
class ViewController: UIViewController {
    
    /// Замыкание, вызываемое при успешной авторизации
    /// Используется для перехода на TabBarController с передачей загруженных данных
    var onLoginSuccess: ((MockData) -> Void)?
    
    // Используем URLSession для загрузки данных с GitHub
    
    /// Индикатор загрузки
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    /// Кнопка авторизации
    /// При нажатии выполняет вход
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Модель данных для декодирования JSON
    struct MockData: Codable {
        let friends: [Friend]
        let groups: [Group]
        let photos: [Photo]
    }
    
    struct Friend: Codable {
        let id: Int
        let name: String
        let avatarUrl: String
    }
    
    struct Group: Codable {
        let id: Int
        let name: String
        let description: String
        let avatarUrl: String
    }
    
    struct Photo: Codable {
        let id: Int
        let url: String
    }
    
    /// Хранит загруженные данные
    private var mockData: MockData?

    /// Вызывается после загрузки представления контроллера
    /// Инициализирует пользовательский интерфейс и начинает загрузку данных
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    /// Настраивает пользовательский интерфейс
    /// Добавляет элементы на экран и настраивает их расположение
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(activityIndicator)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    /// Загружает данные из JSON-файла на GitHub
    private func loadData() {
        activityIndicator.startAnimating()
        loginButton.isEnabled = false
        
        // URL файла на GitHub (используем raw ссылку для получения сырых данных)
        let urlString = "https://raw.githubusercontent.com/aw74aw74/Swift/main/seminar_03/seminar_03/seminar_03_data.json"
        
        guard let url = URL(string: urlString) else {
            activityIndicator.stopAnimating()
            showAlert(message: "Неверный URL файла")
            return
        }
        
        // Создаем задачу загрузки данных
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            // Выполняем все операции в главном потоке
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                // Проверяем наличие ошибки
                if let error = error {
                    print("Ошибка загрузки данных: \(error.localizedDescription)")
                    self.showAlert(message: "Ошибка при загрузке данных: \(error.localizedDescription)")
                    return
                }
                
                // Проверяем наличие данных
                guard let data = data else {
                    self.showAlert(message: "Не удалось получить данные")
                    return
                }
                
                // Проверяем статус ответа
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        self.showAlert(message: "Ошибка сервера: \(httpResponse.statusCode)")
                        return
                    }
                }
                
                // Декодируем JSON
                do {
                    self.mockData = try JSONDecoder().decode(MockData.self, from: data)
                    self.loginButton.isEnabled = true
                    print("Данные успешно загружены с GitHub")
                } catch {
                    print("Ошибка декодирования JSON: \(error)")
                    self.showAlert(message: "Ошибка при обработке данных: \(error.localizedDescription)")
                }
            }
        }
        
        // Запускаем задачу
        task.resume()
    }
    
    /// Имитация метода обработки политики навигации для ответов
    /// Реализован для учебных целей, в реальном приложении использовался бы WKWebView
    private func decidePolicyFor(response: URLResponse, completion: @escaping (Bool) -> Void) {
        // Проверяем статус ответа
        if let httpResponse = response as? HTTPURLResponse {
            print("Получен ответ с кодом: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                // Успешный ответ
                completion(true)
            } else {
                // Ошибка в ответе
                completion(false)
                showAlert(message: "Ошибка сервера: \(httpResponse.statusCode)")
            }
        } else {
            // Если не HTTP-ответ
            completion(true)
        }
    }
    
    /// Этот метод больше не используется, так как загрузка данных происходит из GitHub
    /// Оставлен для обратной совместимости
    private func loadMockData() {
        // Перенаправляем на основной метод загрузки
        loadData()
    }
    
    /// Обрабатывает нажатие на кнопку "Войти"
    @objc private func loginButtonTapped() {
        // Проверяем, что данные загружены
        guard let data = mockData else {
            showAlert(message: "Данные еще не загружены")
            return
        }
        
        // Сохраняем состояние авторизации
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        // Переходим на TabBarController и передаем данные
        onLoginSuccess?(data)
    }
    
    /// Отображает всплывающее сообщение с указанным текстом
    /// - Parameter message: Текст сообщения для отображения
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Сообщение", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
