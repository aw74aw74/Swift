import UIKit

/// Контроллер представления для экрана "Фото"
///
/// Данный класс отвечает за отображение фотографий пользователя.
/// Отображает коллекцию из 6 фотографий в сетке 2x3.
final class PhotosViewController: UIViewController {
    
    // MARK: - Константы и переменные
    
    /// Массив с названиями фотографий
    /// Для использования добавьте эти изображения в Assets.xcassets
    let photos = [
        "photo1",
        "photo2",
        "photo3",
        "photo4",
        "photo5",
        "photo6"
    ]
    
    /// Константа, определяющая количество фотографий в коллекции
    /// В соответствии с требованиями макета установлено значение 6 (сетка 2x3)
    var photoCount: Int {
        return photos.count
    }
    
    // MARK: - UI компоненты
    
    /// Коллекция для отображения фотографий
    /// Занимает всю площадь экрана и отображает фотографии в виде сетки
    private let collectionView: UICollectionView = {
        // Настройка макета коллекции
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10  // Минимальное расстояние между строками
        layout.minimumInteritemSpacing = 10  // Минимальное расстояние между элементами в строке
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)  // Отступы секции
        
        // Создание и настройка коллекции
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        return collectionView
    }()
    
    // MARK: - Методы жизненного цикла
    
    /// Вызывается после загрузки представления
    /// Инициализирует пользовательский интерфейс
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyCurrentTheme() // Применяем начальную тему
        // Подписываемся на уведомления о смене темы
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: ThemeManager.themeDidChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: ThemeManager.themeDidChangeNotification, object: nil)
    }

    @objc private func themeDidChange() {
        applyCurrentTheme()
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

        title = "Фото"
    }
    
    /// Добавляет все подпредставления на основное представление
    private func addSubviews() {
        view.addSubview(collectionView)
    }
    
    /// Настраивает делегаты и источники данных
    private func setupDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    /// Устанавливает ограничения Auto Layout для всех элементов интерфейса
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Theme Application

    private func applyCurrentTheme() {
        let themeColors = ThemeManager.shared.getCurrentThemeColors()

        view.backgroundColor = themeColors.backgroundColor
        collectionView.backgroundColor = themeColors.secondaryBackgroundColor // или backgroundColor

        // Обновление Navigation Bar (глобальные настройки ThemeManager должны это покрывать,
        // но можно явно обновить для текущего контроллера, если нужно)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = themeColors.navigationBarColor
        appearance.titleTextAttributes = [.foregroundColor: themeColors.navigationTitleColor]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = themeColors.navigationTintColor
        // Убедимся, что заголовок "Фото" использует правильный цвет
        self.title = "Фото" // На случай если где-то меняется, восстанавливаем
        
        collectionView.reloadData() // Обновить ячейки
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.getCurrentThemeColors().statusBarStyle
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
/// Расширение для реализации протоколов UICollectionViewDelegate и UICollectionViewDataSource
/// Обеспечивает функциональность коллекции фотографий
extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// Возвращает количество элементов в секции коллекции
    /// - Parameters:
    ///   - collectionView: Коллекция, запрашивающая информацию
    ///   - section: Индекс секции
    /// - Returns: Количество элементов (фотографий) в секции, равное значению photoCount
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoCount
    }
    
    /// Создает и настраивает ячейку для отображения в коллекции
    /// - Parameters:
    ///   - collectionView: Коллекция, запрашивающая ячейку
    ///   - indexPath: Индекс пути для запрашиваемой ячейки
    /// - Returns: Настроенная ячейка коллекции с фотографией
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        // Получаем название изображения для текущей ячейки
        let imageName = photos[indexPath.item]
        
        // Устанавливаем изображение и название в ячейку
        if let image = UIImage(named: imageName) {
            cell.photoImageView.image = image
            cell.titleLabel.text = imageName // Используем имя файла как временное название
        } else {
            // Если изображение не найдено, устанавливаем заглушку и сообщение
            cell.photoImageView.image = UIImage(systemName: "photo") // Системная иконка-заглушка
            cell.titleLabel.text = "Фото не найдено"
            print("Не удалось загрузить изображение: \(imageName)")
        }
        
        // Применяем текущую тему к ячейке
        cell.applyTheme(colors: ThemeManager.shared.getCurrentThemeColors())
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
/// Расширение для реализации протокола UICollectionViewDelegateFlowLayout
/// Отвечает за настройку размеров ячеек в коллекции
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    /// Определяет размер ячейки для заданного индекса пути
    /// - Parameters:
    ///   - collectionView: Коллекция, запрашивающая размер
    ///   - collectionViewLayout: Макет коллекции
    ///   - indexPath: Индекс пути ячейки
    /// - Returns: Размер ячейки в виде CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Расчет ширины ячейки для размещения 2 ячеек в ряду с учетом отступов
        let availableWidth = collectionView.bounds.width - 30  // Ширина с учетом отступов
        let itemWidth = availableWidth / 2  // 2 ячейки в ряду
        
        // Для фотографий делаем ячейку немного выше, чтобы поместилась подпись
        let itemHeight = itemWidth * 1.2  // Высота с учетом места для подписи
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: - PhotoCell
/// Класс ячейки для отображения фотографий в коллекции
final class PhotoCell: UICollectionViewCell {
    // MARK: - UI компоненты ячейки
    
    /// Изображение фотографии
    /// Основной элемент ячейки, отображающий фотографию
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        
        // Настройка автомасштабирования
        imageView.contentMode = .scaleAspectFit  // Режим отображения с сохранением пропорций
        imageView.clipsToBounds = true  // Обрезать содержимое по границам
        // imageView.backgroundColor = .white  // Будет установлено темой
        imageView.layer.borderWidth = 1  // Ширина границы
        // imageView.layer.borderColor = UIColor.systemGray4.cgColor  // Будет установлено темой
        imageView.layer.cornerRadius = 8  // Скругление углов
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Устанавливаем изображение по умолчанию
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    /// Метка для отображения названия фотографии
    /// Располагается под изображением
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center  // Выравнивание текста по центру
        label.font = UIFont.systemFont(ofSize: 12)  // Размер шрифта

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Инициализация
    
    /// Инициализатор ячейки с заданным размером
    /// - Parameter frame: Размер и положение ячейки
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    /// Инициализатор из раскодировщика
    /// Не реализован, так как ячейки создаются программно
    /// - Parameter coder: Раскодировщик
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Настройка ячейки
    
    /// Применяет цвета текущей темы к элементам ячейки
    func applyTheme(colors: ThemeProtocol) {
        contentView.backgroundColor = colors.cellBackgroundColor
        titleLabel.textColor = colors.textColor
        photoImageView.layer.borderColor = colors.accentColor.withAlphaComponent(0.5).cgColor
        
        // Если используется системная иконка-заглушка, применяем tintColor
        if photoImageView.image == UIImage(systemName: "photo") {
            photoImageView.backgroundColor = colors.secondaryBackgroundColor
            photoImageView.tintColor = colors.secondaryTextColor
        } else {
            photoImageView.backgroundColor = .clear // Для реальных изображений фон не нужен
            photoImageView.tintColor = nil // Сбрасываем tintColor для обычных изображений
        }
    }
    
    /// Настраивает внешний вид и расположение элементов ячейки
    /// - Добавляет изображение и метку названия в ячейку
    /// - Устанавливает ограничения Auto Layout для компонентов
    private func setupCell() {
        addCellSubviews()
        setupCellConstraints()
    }
    
    /// Добавляет подпредставления на основное представление ячейки
    private func addCellSubviews() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(titleLabel)
    }
    
    /// Устанавливает ограничения Auto Layout для всех элементов ячейки
    private func setupCellConstraints() {
        NSLayoutConstraint.activate([
            // Ограничения для изображения
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor),  // Квадратное изображение
            
            // Ограничения для метки названия
            titleLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // Нет публичных методов, так как настройка ячейки происходит в cellForItemAt
}
