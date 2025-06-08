import Foundation

/// Модель, представляющая отдельную новость.
/// Реализует Codable для декодирования из JSON и Identifiable для использования в списках SwiftUI.
public struct NewsItem: Codable, Identifiable {
    /// Уникальный идентификатор новости.
    public let id: Int
    /// Заголовок новости.
    public let title: String
    /// Дата публикации новости в формате Unix timestamp (количество секунд с 1 января 1970 года).
    public let publication_date: Int
    /// Краткое описание новости (может отсутствовать).
    public let description: String?
    /// Полный текст новости (может отсутствовать).
    public let body_text: String?
    
    /// Отформатированная дата публикации для отображения.
    /// Преобразует Unix timestamp в строку формата "день месяц год, часы:минуты" с учетом русской локали.
    public var formattedDate: String {
        let date = Date(timeIntervalSince1970: TimeInterval(publication_date))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Стиль даты (например, "10 июн. 2024 г.")
        formatter.timeStyle = .short  // Стиль времени (например, "15:30")
        formatter.locale = Locale(identifier: "ru_RU") // Установка русской локали
        return formatter.string(from: date)
    }
}
