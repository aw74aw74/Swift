# Приложение с UITabBarController

## Описание
Данное приложение демонстрирует использование UITabBarController для организации интерфейса с тремя экранами: Friends (Друзья), Groups (Группы) и Photos (Фото).

Приложение позволяет просматривать списки друзей и групп, а также коллекцию фотографий мотоциклов с автомасштабированием.

## Функциональность

### Экран "Друзья"
- Отображает профиль с изображением и именем выбранного друга
- Содержит таблицу с друзьями (Иван Иванов, Петр Петров и др.)
- При выборе друга в таблице обновляется имя в профиле

### Экран "Группы"
- Отображает профиль с изображением, названием и описанием выбранной группы
- Содержит таблицу с группами (Программирование на Swift, iOS разработка и др.)
- Каждая группа имеет свое уникальное описание
- При выборе группы в таблице обновляется название и описание в профиле

### Экран "Фото"
- Отображает коллекцию из 6 фотографий мотоциклов в сетке 2x3
- Изображения автоматически масштабируются с сохранением пропорций
- Каждая фотография имеет подпись с названием мотоцикла (Harley-Davidson, Yamaha R1 и др.)
- Ячейки с фотографиями имеют белый фон и скругленные углы

## Навигация
- Внизу экрана расположены три вкладки для переключения между экранами
- По клику на кнопку "Войти" на экране авторизации происходит переход на UITabBarController

## Технические особенности
- Использование UITabBarController для организации многостраничного интерфейса
- Применение UITableView для отображения списков друзей и групп
- Использование UICollectionView для отображения фотографий мотоциклов
- Автомасштабирование изображений с сохранением пропорций (contentMode = .scaleAspectFit)
- Динамическое обновление интерфейса при выборе элементов в таблицах
- Использование Auto Layout для адаптивного интерфейса
- Применение модификатора final для классов для предотвращения случайного наследования
- Разделение функций на мелкие с одной ответственностью (setupViewAppearance, addSubviews, setupDelegates, setupConstraints)

## Структура проекта
- **FriendsViewController.swift**: Контроллер для экрана "Друзья" с таблицей друзей
- **GroupsViewController.swift**: Контроллер для экрана "Группы" с таблицей групп и их описаниями
- **PhotosViewController.swift**: Контроллер для экрана "Фото" с коллекцией фотографий мотоциклов
- **PhotoCell**: Класс ячейки для коллекции фотографий (находится в файле PhotosViewController.swift)
- **Assets.xcassets**: Ресурсы приложения, включая изображения мотоциклов
