import SwiftUI
import Combine

/// Экран, отображающий список новостей.
/// Использует `NewsViewModel` для получения данных и управления состоянием.
public struct NewsListView: View {
    /// ViewModel для работы с данными новостей.
    /// `@StateObject` гарантирует, что ViewModel будет создан один раз и будет жить, пока View активно.
    @StateObject private var viewModel: NewsViewModel
    
    /// Инициализатор для NewsListView, позволяющий внедрять ViewModel.
    /// Это полезно для тестирования и предварительного просмотра с моковыми данными.
    /// - Parameter viewModel: Экземпляр NewsViewModel. По умолчанию создается новый.
    public init(viewModel: NewsViewModel = NewsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack {
            // Если идет загрузка, показываем индикатор прогресса
            if viewModel.isLoading {
                ProgressView("Загрузка новостей...")
                    .progressViewStyle(CircularProgressViewStyle()) // Стиль индикатора
                    .padding()
            } 
            // Если есть сообщение об ошибке, показываем его
            else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill") // Иконка ошибки
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    Text("Произошла ошибка")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.subheadline)
                        .multilineTextAlignment(.center) // Выравнивание текста по центру
                        .padding(.horizontal)
                    
                    Button("Повторить загрузку") {
                        viewModel.loadNews() // Повторный вызов загрузки новостей
                    }
                    .padding(.top, 16)
                    .buttonStyle(.borderedProminent) // Стиль кнопки
                }
                .padding()
            } 
            // Если новости загружены и нет ошибок, показываем список
            else {
                List {
                    // Перебираем массив новостей и для каждой создаем NewsItemRow
                    ForEach(viewModel.newsItems) { newsItem in
                        NewsItemRow(newsItem: newsItem)
                    }
                }
                .listStyle(PlainListStyle()) // Стиль списка без дополнительных украшений
            }
        }
        .navigationTitle("Новости KudaGo") // Заголовок экрана
        .onAppear {
            // Загружаем новости при появлении экрана, если они еще не загружены
            if viewModel.newsItems.isEmpty && !viewModel.isLoading {
                viewModel.loadNews()
            }
        }
    }
}

#if DEBUG
// MARK: - Preview для NewsListView
/// Предоставляет предварительный просмотр для `NewsListView` в Xcode.
struct NewsListView_Previews: PreviewProvider {
    static var previews: some View {
        // Для превью можно использовать ViewModel с моковым сервисом,
        // который возвращает предопределенные данные или имитирует задержку/ошибку.
        
        // 1. Моковый сервис, возвращающий успешные данные
        class MockSuccessNewsService: NewsFetching {
            func fetchNews(page: Int, pageSize: Int) -> AnyPublisher<NewsResponse, Error> {
                let items = [
                    NewsItem(id: 1, title: "Новость 1: Успех!", publication_date: Int(Date().timeIntervalSince1970), description: "Описание 1", body_text: "Тело 1"),
                    NewsItem(id: 2, title: "Новость 2: Все отлично!", publication_date: Int(Date().timeIntervalSince1970 - 1000), description: "Описание 2", body_text: "Тело 2")
                ]
                let response = NewsResponse(count: 2, next: nil, previous: nil, results: items)
                return Just(response)
                    .delay(for: .seconds(1), scheduler: DispatchQueue.main) // Имитация задержки сети
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }
        
        // 2. Моковый сервис, имитирующий ошибку
        class MockFailureNewsService: NewsFetching {
            func fetchNews(page: Int, pageSize: Int) -> AnyPublisher<NewsResponse, Error> {
                return Fail(error: URLError(.notConnectedToInternet))
                    .delay(for: .seconds(1), scheduler: DispatchQueue.main) // Имитация задержки сети
                    .eraseToAnyPublisher()
            }
        }
        
        // 3. Моковый сервис, имитирующий длительную загрузку (для отображения ProgressView)
        class MockLoadingNewsService: NewsFetching {
             func fetchNews(page: Int, pageSize: Int) -> AnyPublisher<NewsResponse, Error> {
                 // Publisher, который никогда не отправляет значение и не завершается
                 return PassthroughSubject<NewsResponse, Error>().eraseToAnyPublisher()
             }
         }

        return Group {
            NavigationView {
                NewsListView(viewModel: NewsViewModel(newsService: MockSuccessNewsService()))
            }
            .previewDisplayName("Успешная загрузка")

            NavigationView {
                NewsListView(viewModel: NewsViewModel(newsService: MockFailureNewsService()))
            }
            .previewDisplayName("Ошибка загрузки")
            
            NavigationView {
                 // Для имитации состояния isLoading, мы можем создать ViewModel
                 // с сервисом, который долго грузит, и вызвать loadNews() или установить isLoading вручную.
                 let loadingViewModel = NewsViewModel(newsService: MockLoadingNewsService())
                 // Можно было бы вызвать loadingViewModel.loadNews() здесь, 
                 // но для превью проще напрямую установить isLoading, если сервис не имитирует это сам.
                 // Однако, если MockLoadingNewsService правильно имитирует "вечную" загрузку, 
                 // то вызов loadNews() должен показать ProgressView.
                 // Для надежности превью состояния isLoading, лучше установить его явно.
                 // Вместо этого, мы сделаем так, чтобы ViewModel сам перешел в состояние isLoading
                 // при вызове loadNews с MockLoadingNewsService.
                 // Поэтому, создаем ViewModel и в onAppear он вызовет loadNews.
                NewsListView(viewModel: loadingViewModel)
            }
            .previewDisplayName("Состояние загрузки")
        }
    }
}
#endif
