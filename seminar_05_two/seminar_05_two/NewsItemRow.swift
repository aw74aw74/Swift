import SwiftUI

// MARK: - Views

/// Ячейка для отображения отдельной новости в списке.
/// Представляет собой `View` в SwiftUI.
public struct NewsItemRow: View {
    /// Новость, которую необходимо отобразить.
    public let newsItem: NewsItem
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок новости
            Text(newsItem.title)
                .font(.headline) // Стиль шрифта для заголовка
                .lineLimit(2)    // Ограничение на две строки, чтобы избежать слишком длинных заголовков
            
            // Отформатированная дата публикации
            Text(newsItem.formattedDate)
                .font(.subheadline) // Стиль шрифта для подзаголовка
                .foregroundColor(.secondary) // Цвет текста для второстепенной информации
        }
        .padding(.vertical, 8) // Вертикальные отступы для ячейки
    }
}

#if DEBUG
// MARK: - Preview для NewsItemRow
/// Предоставляет предварительный просмотр для `NewsItemRow` в Xcode.
/// Использует моковые данные для отображения.
struct NewsItemRow_Previews: PreviewProvider {
    static var previews: some View {
        // Пример новости для предварительного просмотра
        let mockNewsItem = NewsItem(
            id: 1,
            title: "Пример заголовка очень интересной новости, который может быть довольно длинным",
            publication_date: Int(Date().timeIntervalSince1970 - 3600), // час назад
            description: "Краткое описание новости.",
            body_text: "Полный текст новости."
        )
        
        // Отображение ячейки с моковой новостью
        NewsItemRow(newsItem: mockNewsItem)
            .previewLayout(.sizeThatFits) // Размер превью подгоняется под содержимое
            .padding() // Добавляем отступы вокруг для наглядности
    }
}
#endif
