import Foundation

/// Основной сетевой менеджер приложения
/// Отвечает за загрузку данных из сети и обработку ошибок

/// Перечисление возможных ошибок при работе с сетью
enum NetworkError: Error {
    /// Ошибка при декодировании JSON
    case decodingError(Error)
    
    /// Ошибка сервера с кодом статуса
    case serverError(Int)
    
    /// Отсутствуют данные в ответе
    case noData
    
    /// Неверный URL
    case invalidURL
    
    /// Локализованное описание ошибки
    var localizedDescription: String {
        switch self {
        case .decodingError(let error):
            return "Ошибка декодирования JSON: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Ошибка сервера: \(statusCode)"
        case .noData:
            return "Не удалось получить данные"
        case .invalidURL:
            return "Неверный URL файла"
        }
    }
}

/// Протокол для сервиса работы с сетью
/// Определяет методы для загрузки данных из различных источников
protocol NetworkManagerProtocol {
    /// Загружает данные из удаленного JSON-файла
    /// - Parameters:
    ///   - urlString: URL-строка для загрузки данных
    ///   - completion: Замыкание, вызываемое после завершения загрузки
    func loadMockData(from urlString: String, completion: @escaping (Result<MockData, Error>) -> Void)
    
    /// Проверяет статус ответа HTTP
    /// - Parameters:
    ///   - response: Ответ от сервера
    ///   - completion: Замыкание, вызываемое после проверки статуса
    func validateResponse(_ response: URLResponse, completion: @escaping (Bool) -> Void)
}

/// Сервис для работы с сетью
/// Реализует загрузку данных из удаленных источников
final class NetworkManager: NetworkManagerProtocol {
    
    /// Сессия для выполнения сетевых запросов
    private let session: URLSession
    
    /// Инициализатор сервиса
    /// - Parameter session: Сессия для выполнения запросов (по умолчанию используется shared)
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Загружает данные из удаленного JSON-файла
    /// - Parameters:
    ///   - urlString: URL-строка для загрузки данных
    ///   - completion: Замыкание, вызываемое после завершения загрузки
    func loadMockData(from urlString: String, completion: @escaping (Result<MockData, Error>) -> Void) {
        // Проверяем корректность URL
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Создаем задачу загрузки данных
        let task = session.dataTask(with: url) { (data, response, error) in
            
            // Проверяем наличие ошибки
            if let error = error {
                print("Ошибка загрузки данных: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Проверяем наличие данных
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Проверяем статус ответа
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                    return
                }
            }
            
            // Декодируем JSON
            do {
                let mockData = try JSONDecoder().decode(MockData.self, from: data)
                print("Данные успешно загружены с GitHub")
                completion(.success(mockData))
            } catch {
                print("Ошибка декодирования JSON: \(error)")
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        
        // Запускаем задачу
        task.resume()
    }
    
    /// Проверяет статус ответа HTTP
    /// - Parameters:
    ///   - response: Ответ от сервера
    ///   - completion: Замыкание, вызываемое после проверки статуса
    func validateResponse(_ response: URLResponse, completion: @escaping (Bool) -> Void) {
        // Проверяем статус ответа
        if let httpResponse = response as? HTTPURLResponse {
            print("Получен ответ с кодом: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                // Успешный ответ
                completion(true)
            } else {
                // Ошибка сервера
                completion(false)
            }
        } else {
            // Если не HTTP-ответ
            completion(true)
        }
    }
}

/// Расширение для создания мок-версии сервиса для тестирования
extension NetworkManager {
    /// Создает экземпляр сервиса с мок-данными для тестирования
    /// - Returns: Экземпляр NetworkManager с предустановленными данными
    static func mockService() -> NetworkManager {
        // Создаем конфигурацию сессии с мок-обработчиком
        let config = URLSessionConfiguration.ephemeral
        let mockSession = URLSession(configuration: config)
        
        return NetworkManager(session: mockSession)
    }
}
