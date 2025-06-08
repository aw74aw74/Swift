import UIKit
import Foundation

/// Контроллер представления для экрана "Профиль"
///
/// Данный класс отвечает за отображение профиля пользователя.
/// Экран содержит круглое фото пользователя и его имя.
/// Представляется модально с кастомной анимацией перехода.
final class ProfileViewController: UIViewController {
    
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
        updateUI()
    }
    
    // MARK: - Настройка UI
    
    /// Настраивает пользовательский интерфейс
    private func setupUI() {
        view.backgroundColor = .white
        title = "Профиль"
        
        // Добавляем элементы на view
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
        }
    }
}
