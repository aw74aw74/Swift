import UIKit
import Foundation

// Модели данных из Models.swift и сетевой сервис из NetworkManager.swift доступны автоматически, так как находятся в одном модуле

/// Контроллер экрана авторизации
/// Загружает данные из JSON-файла на GitHub
/// При успешной загрузке переходит на TabBarController
class ViewController: UIViewController {
    
    // MARK: - Инициализация
    
    /// Инициализатор с внедрением зависимости сетевого сервиса
    /// - Parameter networkManager: Сервис для работы с сетью
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Инициализатор из раскодировщика
    /// Требуется для поддержки стандартного инициализатора UIViewController
    required init?(coder: NSCoder) {
        self.networkManager = NetworkManager()
        super.init(coder: coder)
    }
    
    /// Замыкание, вызываемое при успешной авторизации
    /// Используется для перехода на TabBarController с передачей загруженных данных
    var onLoginSuccess: ((MockData) -> Void)?
    
    // Используем NetworkManager для загрузки данных с GitHub
    
    /// Сервис для работы с сетью
    private let networkManager: NetworkManagerProtocol
    
    /// Индикатор загрузки
    /// Заголовок экрана
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold) // Пример шрифта
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        // Цвет текста будет устанавливаться в applyCurrentTheme
        return label
    }()

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
        button.setTitle("ВОЙТИ", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18) // Увеличиваем размер шрифта
        button.layer.cornerRadius = 10 // Более заметное скругление
        button.layer.shadowColor = UIColor.black.cgColor // Добавляем тень
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Модели перенесены в отдельный файл Models.swift
    
    /// Хранит загруженные данные
    private var mockData: MockData?

    /// Вызывается после загрузки представления контроллера
    /// Инициализирует пользовательский интерфейс и начинает загрузку данных
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Сначала настраиваем UI элементы
        applyCurrentTheme() // Затем применяем к ним тему
        loadData()

        // Подписываемся на уведомления о смене темы
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: ThemeManager.themeDidChangeNotification, object: nil)
    }
    
    /// Настраивает пользовательский интерфейс
    /// Добавляет элементы на экран и настраивает их расположение
    // MARK: - Theme

    @objc private func themeDidChange() {
        applyCurrentTheme()
    }

    private func applyCurrentTheme() {
        let currentThemeColors = ThemeManager.shared.getCurrentThemeColors()

        view.backgroundColor = currentThemeColors.backgroundColor
        titleLabel.textColor = currentThemeColors.textColor

        // Обновляем цвета кнопки входа
        loginButton.backgroundColor = currentThemeColors.buttonBackgroundColor ?? currentThemeColors.accentColor // Используем специальный цвет фона кнопки или акцентный цвет
        loginButton.setTitleColor(currentThemeColors.buttonTextColor ?? currentThemeColors.secondaryTextColor, for: .normal) // Используем специальный цвет текста кнопки или вторичный цвет текста
        // Если кнопка выключена, можно задать другие цвета
        loginButton.setTitleColor(currentThemeColors.disabledTextColor ?? .gray, for: .disabled)

        // Обновляем цвет индикатора активности
        activityIndicator.color = currentThemeColors.textColor // Обычно цвет текста хорошо подходит для индикатора


        setNeedsStatusBarAppearanceUpdate() // Обновляем стиль статус-бара
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.getCurrentThemeColors().statusBarStyle
    }

    // MARK: - UI Setup

    private func setupUI() {
        
        // Добавляем элементы на экран
        view.addSubview(activityIndicator)
        view.addSubview(loginButton)
        
        // Настраиваем заголовок для лучшей видимости
        let titleLabel = UILabel()
        titleLabel.text = "Вход в приложение"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Настраиваем ограничения для всех элементов
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Индикатор загрузки
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Кнопка входа
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
        
        // URL к JSON файлу на GitHub (raw content)
        let urlString = "https://raw.githubusercontent.com/aw74aw74/Swift/main/seminar_06/seminar_06/seminar_06_data.json"
        
        // Используем сетевой менеджер для загрузки данных
        networkManager.loadMockData(from: urlString) { [weak self] result in
            guard let self = self else { return }
            
            // Выполняем все операции в главном потоке
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                // Обрабатываем результат загрузки
                switch result {
                case .success(let data):
                    // Сохраняем полученные данные
                    self.mockData = data
                    self.loginButton.isEnabled = true
                    
                    // Делаем кнопку входа активной
                    self.loginButton.alpha = 1.0
                    // Сохраняем оригинальный синий цвет
                    // self.loginButton.backgroundColor = .systemBlue // Цвет кнопки теперь управляется темой
                    // Вместо этого, можно вызвать applyCurrentTheme(), если нужно обновить цвет после загрузки данных,
                    // но обычно это не требуется, если тема не менялась во время загрузки.
                    // Если loginButton.isEnabled = true меняет его внешний вид, который зависит от темы, то вызов applyCurrentTheme() может быть нужен.
                    // В данном случае, просто включение кнопки не должно требовать перерисовки темы.
                    
                case .failure(let error):
                    // Обрабатываем ошибку
                    if let networkError = error as? NetworkError {
                        self.showAlert(message: networkError.localizedDescription)
                    } else {
                        self.showAlert(message: "Ошибка при загрузке данных: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// Имитация метода обработки политики навигации для ответов
    private func decidePolicyFor(response: URLResponse, completion: @escaping (Bool) -> Void) {
        // Делегируем проверку сетевому менеджеру
        networkManager.validateResponse(response, completion: completion)
    }
    
    
    /// Обрабатывает нажатие на кнопку "Войти"
    @objc private func loginButtonTapped() {
        // Проверяем, что данные загружены
        guard let data = mockData else {
            showAlert(message: "Данные еще не загружены") // Восстанавливаем исходное сообщение
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

    deinit {
        NotificationCenter.default.removeObserver(self, name: ThemeManager.themeDidChangeNotification, object: nil)
        print("ViewController deinited")
    }
}
