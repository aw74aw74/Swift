import Foundation
import Combine

// MARK: - ViewModel для экрана списка новостей

/// ViewModel, отвечающая за логику и состояние экрана списка новостей.
/// Является `ObservableObject`, чтобы SwiftUI мог отслеживать изменения ее свойств.
public class NewsViewModel: ObservableObject {
    /// Сервис для получения новостей. Зависит от абстракции `NewsFetching`.
    public let newsService: NewsFetching
    
    /// Список загруженных новостей. `@Published` свойство для автоматического обновления UI.
    @Published public var newsItems: [NewsItem] = []
    
    /// Состояние загрузки данных. `@Published` свойство.
    @Published public var isLoading: Bool = false
    
    /// Сообщение об ошибке, если оно есть. `@Published` свойство.
    @Published public var errorMessage: String? = nil
    
    /// Набор подписок на `Publisher`-ы для управления их жизненным циклом.
    private var cancellables = Set<AnyCancellable>()
    
    /// Инициализатор ViewModel.
    /// - Parameter newsService: Экземпляр сервиса, соответствующий протоколу `NewsFetching`.
    ///   По умолчанию используется `NewsService()`.
    public init(newsService: NewsFetching = NewsService()) {
        self.newsService = newsService
    }
    
    /// Загружает новости с использованием `newsService`.
    /// Обновляет `isLoading`, `errorMessage` и `newsItems` в зависимости от результата.
    public func loadNews() {
        isLoading = true
        errorMessage = nil
        
        newsService.fetchNews(page: 1, pageSize: 20) // Используем значения по умолчанию из протокола/сервиса
            .sink(receiveCompletion: { [weak self] completion in
                // Этот блок выполняется после завершения Publisher (успешно или с ошибкой)
                guard let self = self else { return }
                self.isLoading = false // Загрузка завершена
                
                if case .failure(let error) = completion {
                    // Если произошла ошибка, сохраняем ее описание
                    self.errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
                    print("Ошибка при загрузке новостей: \(error)")
                }
            }, receiveValue: { [weak self] response in
                // Этот блок выполняется при получении новых данных от Publisher
                guard let self = self else { return }
                // Обновляем список новостей
                self.newsItems = response.results
            })
            .store(in: &cancellables) // Сохраняем подписку, чтобы она не была отменена преждевременно
    }
}
