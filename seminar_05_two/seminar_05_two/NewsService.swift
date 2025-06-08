import Foundation
import Combine

// MARK: - Протокол для сервиса новостей

/// Протокол, определяющий контракт для сервиса загрузки новостей.
/// Позволяет абстрагироваться от конкретной реализации сервиса загрузки данных.
public protocol NewsFetching {
    /// Загружает список новостей.
    /// - Parameters:
    ///   - page: Номер страницы для пагинации (по умолчанию 1).
    ///   - pageSize: Количество новостей на странице (по умолчанию 20).
    /// - Returns: `AnyPublisher`, который публикует `NewsResponse` в случае успеха или `Error` в случае ошибки.
    func fetchNews(page: Int, pageSize: Int) -> AnyPublisher<NewsResponse, Error>
}

// MARK: - Сервис для работы с API новостей

/// Сервис для загрузки новостей с API KudaGo.
/// Реализует протокол `NewsFetching`.
public class NewsService: NewsFetching {
    /// Базовый URL для API KudaGo.
    public init() {} // Публичный инициализатор
    private let baseURL = "https://kudago.com/public-api/v1.4"
    
    /// Получение списка новостей.
    /// - Parameters:
    ///   - page: Номер страницы (по умолчанию 1).
    ///   - pageSize: Количество новостей на странице (по умолчанию 20).
    /// - Returns: `AnyPublisher` с результатом запроса (`NewsResponse`) или ошибкой (`Error`).
    public func fetchNews(page: Int = 1, pageSize: Int = 20) -> AnyPublisher<NewsResponse, Error> {
        let urlString = "\(baseURL)/news/?page=\(page)&page_size=\(pageSize)"
        
        // Проверка корректности URL
        guard let url = URL(string: urlString) else {
            // Если URL некорректен, возвращаем ошибку URLError.badURL
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        // Создание и запуск задачи для загрузки данных
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data } // Извлекаем данные из ответа
            .decode(type: NewsResponse.self, decoder: JSONDecoder()) // Декодируем JSON в NewsResponse
            .receive(on: DispatchQueue.main) // Переключаемся на главный поток для обновления UI
            .eraseToAnyPublisher() // Стираем тип издателя до AnyPublisher
    }
}
