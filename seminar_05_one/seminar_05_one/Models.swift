import Foundation

// MARK: - Модели данных

/// Модель данных для тестирования
struct MockData: Codable {
    /// Список друзей
    let friends: [Friend]
    /// Список групп
    let groups: [Group]
    /// Список фотографий
    let photos: [Photo]
}

/// Модель друга
struct Friend: Codable {
    /// Идентификатор
    let id: Int
    /// Имя
    let name: String
    /// Аватар (ссылка на изображение)
    let avatarUrl: String
    /// Статус онлайн
    let isOnline: Bool
}

/// Модель группы
struct Group: Codable {
    /// Идентификатор
    let id: Int
    /// Название
    let name: String
    /// Описание группы
    let description: String?
    /// Аватар (ссылка на изображение)
    let avatarUrl: String
}

/// Модель фотографии
struct Photo: Codable {
    /// Идентификатор
    let id: Int
    /// Ссылка на изображение
    let url: String
}
