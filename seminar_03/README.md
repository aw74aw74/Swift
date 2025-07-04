# Приложение с интеграцией VK API

## Описание
Данное приложение демонстрирует использование UITabBarController для организации интерфейса с тремя экранами: Friends (Друзья), Groups (Группы) и Photos (Фото). Приложение имитирует работу с VK API, загружая данные из JSON-файла на GitHub.

Приложение позволяет просматривать списки друзей и групп, а также коллекцию фотографий. Данные загружаются с удаленного сервера с использованием URLSession.

## Функциональность

### Экран "Друзья"
- Отображает профиль с изображением и именем выбранного друга
- Содержит таблицу с друзьями, загруженными из JSON-файла
- При выборе друга в таблице обновляется имя в профиле
- Выводит список друзей в консоль при первом переходе на экран, имитируя запрос к API VK

### Экран "Группы"
- Отображает профиль с изображением, названием и описанием выбранной группы
- Содержит таблицу с группами, загруженными из JSON-файла
- Каждая группа имеет свое уникальное описание и ID
- При выборе группы в таблице обновляется название и описание в профиле
- Выводит список групп в консоль при первом переходе на экран, имитируя запрос к API VK

### Экран "Фото"
- Отображает коллекцию из 6 фотографий в сетке 2x3
- Изображения автоматически масштабируются с сохранением пропорций
- Фотографии загружаются из ресурсов приложения
- Ячейки с фотографиями имеют белый фон и скругленные углы

## Навигация и авторизация
- При запуске приложения отображается экран авторизации
- Приложение загружает данные с GitHub с использованием URLSession
- По клику на кнопку "Войти" происходит переход на UITabBarController
- Внизу экрана расположены три вкладки для переключения между экранами

## Технические особенности
- Использование URLSession для загрузки данных с удаленного сервера (GitHub)
- Декодирование JSON-данных с использованием протокола Codable
- Использование UITabBarController для организации многостраничного интерфейса
- Применение UITableView для отображения списков друзей и групп
- Использование UICollectionView для отображения фотографий
- Имитация запросов к API VK с выводом результатов в консоль
- Оптимизированный код без избыточных массивов и методов
- Динамическое обновление интерфейса при выборе элементов в таблицах
- Использование Auto Layout для адаптивного интерфейса
- Применение модификатора final для классов для предотвращения случайного наследования
- Разделение функций на мелкие с одной ответственностью (setupViewAppearance, addSubviews, setupDelegates, setupConstraints)

## Структура проекта
- **ViewController.swift**: Контроллер экрана авторизации, загружает данные из JSON-файла на GitHub
- **MainTabBarController.swift**: Контроллер с вкладками, отвечает за передачу данных в дочерние контроллеры
- **FriendsViewController.swift**: Контроллер для экрана "Друзья" с таблицей друзей и выводом списка в консоль
- **GroupsViewController.swift**: Контроллер для экрана "Группы" с таблицей групп и выводом списка в консоль
- **PhotosViewController.swift**: Контроллер для экрана "Фото" с коллекцией фотографий
- **PhotoCell**: Класс ячейки для коллекции фотографий (находится в файле PhotosViewController.swift)
- **AppDelegate.swift**: Отвечает за жизненный цикл приложения и настройку начального экрана
- **Assets.xcassets**: Ресурсы приложения, включая изображения
