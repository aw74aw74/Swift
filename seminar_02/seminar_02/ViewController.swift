import UIKit

/// Контроллер экрана авторизации
/// Отображает форму для ввода логина и пароля
/// При успешной авторизации переходит на TabBarController
class ViewController: UIViewController {
    
    /// Замыкание, вызываемое при успешной авторизации
    /// Используется для перехода на TabBarController
    var onLoginSuccess: (() -> Void)?
    
    /// Изображение логотипа приложения
    /// Отображается в верхней части экрана авторизации
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBlue
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Заголовок формы авторизации
    /// Отображает текст "Авторизация" над полями ввода
    private let authorizationLabel: UILabel = {
        let label = UILabel()
        label.text = "Авторизация"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Поле ввода логина
    /// Позволяет пользователю ввести свой логин
    private let loginTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Логин"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    /// Поле ввода пароля
    /// Позволяет пользователю ввести свой пароль
    /// Текст скрыт для обеспечения безопасности
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Пароль"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true // Скрываем вводимый текст
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    /// Кнопка авторизации
    /// При нажатии проверяет введенные данные и выполняет вход
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

    /// Вызывается после загрузки представления контроллера
    /// Инициализирует пользовательский интерфейс
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    /// Настраивает пользовательский интерфейс
    /// Добавляет элементы на экран и настраивает их расположение
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(logoImageView)
        view.addSubview(authorizationLabel)
        view.addSubview(loginTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 180),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            
            authorizationLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            authorizationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            authorizationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            authorizationLabel.heightAnchor.constraint(equalToConstant: 30),
            
            loginTextField.topAnchor.constraint(equalTo: authorizationLabel.bottomAnchor, constant: 20),
            loginTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            loginTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginTextField.heightAnchor.constraint(equalToConstant: 30),
            
            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 30),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let label = UILabel(frame: logoImageView.bounds)
        label.text = "ЛОГОТИП"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        logoImageView.addSubview(label)
    }
    
    /// Скрывает клавиатуру при касании экрана
    /// Вызывается по жесту нажатия на экран
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    /// Обрабатывает нажатие на кнопку "Войти"
    /// Проверяет заполнение полей логина и пароля
    /// При успешной проверке выполняет переход на TabBarController
    @objc private func loginButtonTapped() {
        // Проверяем, что поле логина не пустое
        guard let login = loginTextField.text, !login.isEmpty else {
            showAlert(message: "Введите логин")
            return
        }
        
        // Проверяем, что поле пароля не пустое
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Введите пароль")
            return
        }
        
        // Сразу переходим на TabBarController без сообщения
        onLoginSuccess?()
    }
    
    /// Отображает всплывающее сообщение с указанным текстом
    /// - Parameter message: Текст сообщения для отображения
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Сообщение", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
/// Расширение для обработки событий текстовых полей
extension ViewController: UITextFieldDelegate {
    /// Вызывается при нажатии кнопки Return на клавиатуре
    /// - Parameter textField: Текстовое поле, в котором была нажата кнопка Return
    /// - Returns: true, чтобы обработать событие стандартным образом
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            // Если нажали Return в поле логина, переходим к полю пароля
            passwordTextField.becomeFirstResponder()
        } else {
            // Если нажали Return в поле пароля, скрываем клавиатуру и выполняем вход
            textField.resignFirstResponder()
            loginButtonTapped()
        }
        return true
    }
}
