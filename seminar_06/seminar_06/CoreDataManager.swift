import Foundation
import CoreData

/// Класс-менеджер для работы с Core Data.
/// Отвечает за настройку стека Core Data, сохранение и извлечение данных.
final class CoreDataManager {
    
    /// Синглтон для доступа к менеджеру Core Data.
    static let shared = CoreDataManager()
    
    /// Имя файла модели данных Core Data (без расширения .xcdatamodeld).
    private let modelName = "AppModel"
    
    // MARK: - Core Data Stack
    
    /// Контейнер персистентности Core Data.
    /// Инициализируется лениво при первом обращении.
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Обработка ошибки инициализации контейнера
                // В реальном приложении здесь должна быть более сложная логика обработки ошибок,
                // например, логирование, отображение сообщения пользователю и т.д.
                print("🔴 Не удалось загрузить хранилище Core Data: \(error), \(error.userInfo)")
                // Можно рассмотреть вариант удаления хранилища и попытки создания заново,
                // но это может привести к потере данных.
                // fatalError() здесь использовать не рекомендуется для продакшн кода без крайней необходимости.
            }
        })
        return container
    }()
    
    /// Контекст управляемых объектов для основной очереди.
    /// Используется для всех операций с данными, выполняемых на главном потоке.
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Создает новый фоновый контекст для выполнения операций с данными в фоновом потоке.
    /// Фоновые контексты полезны для длительных операций, чтобы не блокировать UI.
    func newBackgroundTaskContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Сохранение контекста
    
    /// Сохраняет изменения в контексте управляемых объектов.
    /// - Parameter context: Контекст, в котором нужно сохранить изменения. По умолчанию используется `viewContext`.
    /// - Returns: `true` если сохранение прошло успешно, иначе `false`.
    @discardableResult
    func saveContext(context: NSManagedObjectContext? = nil) -> Bool {
        let contextToSave = context ?? viewContext
        if contextToSave.hasChanges {
            do {
                try contextToSave.save()
                print("✅ Контекст Core Data успешно сохранен.")
                return true
            } catch {
                let nserror = error as NSError
                print("🔴 Ошибка сохранения контекста Core Data: \(nserror), \(nserror.userInfo)")
                // В реальном приложении здесь также нужна обработка ошибок.
                return false
            }
        }
        print("ℹ️ В контексте Core Data нет изменений для сохранения.")
        return true // Нет изменений, считаем успешным
    }
    
    // MARK: - Операции с Друзьями (FriendCD)
    
    /// Сохраняет массив друзей в Core Data.
    /// Если друг с таким ID уже существует, его данные обновляются.
    /// - Parameters:
    ///   - friends: Массив моделей `Friend` для сохранения.
    ///   - context: Контекст, в котором выполняется операция. По умолчанию используется `viewContext`.
    func saveFriends(_ friends: [Friend], in context: NSManagedObjectContext? = nil) {
        let managedContext = context ?? viewContext
        
        managedContext.performAndWait { // Используем performAndWait для синхронного выполнения на контексте
            for friendModel in friends {
                let fetchRequest: NSFetchRequest<FriendCD> = FriendCD.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %lld", friendModel.id)
                
                do {
                    let existingFriends = try managedContext.fetch(fetchRequest)
                    let friendCD: FriendCD
                    
                    if let existingFriend = existingFriends.first {
                        // Обновляем существующего друга
                        friendCD = existingFriend
                        print("ℹ️ Обновление друга в Core Data: ID \(friendModel.id)")
                    } else {
                        // Создаем нового друга
                        friendCD = FriendCD(context: managedContext)
                        friendCD.id = Int64(friendModel.id) // Преобразуем Int в Int64
                        print("ℹ️ Создание нового друга в Core Data: ID \(friendModel.id)")
                    }
                    
                    friendCD.name = friendModel.name
                    friendCD.avatarUrl = friendModel.avatarUrl
                    friendCD.isOnline = friendModel.isOnline
                    
                } catch {
                    print("🔴 Ошибка при поиске/создании друга в Core Data: \(error)")
                }
            }
            saveContext(context: managedContext)
        }
    }
    
    /// Извлекает всех друзей из Core Data.
    /// - Parameter context: Контекст, из которого выполняется извлечение. По умолчанию используется `viewContext`.
    /// - Returns: Массив объектов `FriendCD` или пустой массив, если данных нет или произошла ошибка.
    func fetchFriends(in context: NSManagedObjectContext? = nil) -> [FriendCD] {
        let managedContext = context ?? viewContext
        let fetchRequest: NSFetchRequest<FriendCD> = FriendCD.fetchRequest()
        // Можно добавить сортировку, если необходимо
        // let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        // fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let friends = try managedContext.fetch(fetchRequest)
            print("ℹ️ Извлечено \(friends.count) друзей из Core Data.")
            return friends
        } catch {
            print("🔴 Ошибка извлечения друзей из Core Data: \(error)")
            return []
        }
    }
    
    /// Удаляет всех друзей из Core Data.
    /// - Parameter context: Контекст, в котором выполняется операция. По умолчанию используется `viewContext`.
    func deleteAllFriends(in context: NSManagedObjectContext? = nil) {
        let managedContext = context ?? viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FriendCD.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        managedContext.performAndWait {
            do {
                try managedContext.execute(deleteRequest)
                saveContext(context: managedContext)
                print("ℹ️ Все друзья удалены из Core Data.")
            } catch {
                print("🔴 Ошибка удаления всех друзей из Core Data: \(error)")
            }
        }
    }
    
    // MARK: - Операции с Группами (GroupCD)
    
    /// Сохраняет массив групп в Core Data.
    /// Если группа с таким ID уже существует, ее данные обновляются.
    /// - Parameters:
    ///   - groups: Массив моделей `Group` для сохранения.
    ///   - context: Контекст, в котором выполняется операция. По умолчанию используется `viewContext`.
    func saveGroups(_ groups: [Group], in context: NSManagedObjectContext? = nil) {
        let managedContext = context ?? viewContext
        
        managedContext.performAndWait {
            for groupModel in groups {
                let fetchRequest: NSFetchRequest<GroupCD> = GroupCD.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %lld", groupModel.id)
                
                do {
                    let existingGroups = try managedContext.fetch(fetchRequest)
                    let groupCD: GroupCD
                    
                    if let existingGroup = existingGroups.first {
                        // Обновляем существующую группу
                        groupCD = existingGroup
                        print("ℹ️ Обновление группы в Core Data: ID \(groupModel.id)")
                    } else {
                        // Создаем новую группу
                        groupCD = GroupCD(context: managedContext)
                        groupCD.id = Int64(groupModel.id) // Преобразуем Int в Int64
                        print("ℹ️ Создание новой группы в Core Data: ID \(groupModel.id)")
                    }
                    
                    groupCD.name = groupModel.name
                    groupCD.groupDescription = groupModel.description // Используем groupDescription
                    groupCD.photoUrl = groupModel.avatarUrl // Используем avatarUrl из модели Group
                    groupCD.membersCount = Int32(groupModel.membersCount) // Преобразуем в Int32
                    
                } catch {
                    print("🔴 Ошибка при поиске/создании группы в Core Data: \(error)")
                }
            }
            saveContext(context: managedContext)
        }
    }
    
    /// Извлекает все группы из Core Data.
    /// - Parameter context: Контекст, из которого выполняется извлечение. По умолчанию используется `viewContext`.
    /// - Returns: Массив объектов `GroupCD` или пустой массив, если данных нет или произошла ошибка.
    func fetchGroups(in context: NSManagedObjectContext? = nil) -> [GroupCD] {
        let managedContext = context ?? viewContext
        let fetchRequest: NSFetchRequest<GroupCD> = GroupCD.fetchRequest()
        // Можно добавить сортировку, если необходимо
        // let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        // fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let groups = try managedContext.fetch(fetchRequest)
            print("ℹ️ Извлечено \(groups.count) групп из Core Data.")
            return groups
        } catch {
            print("🔴 Ошибка извлечения групп из Core Data: \(error)")
            return []
        }
    }
    
    /// Удаляет все группы из Core Data.
    /// - Parameter context: Контекст, в котором выполняется операция. По умолчанию используется `viewContext`.
    func deleteAllGroups(in context: NSManagedObjectContext? = nil) {
        let managedContext = context ?? viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = GroupCD.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        managedContext.performAndWait {
            do {
                try managedContext.execute(deleteRequest)
                saveContext(context: managedContext)
                print("ℹ️ Все группы удалены из Core Data.")
            } catch {
                print("🔴 Ошибка удаления всех групп из Core Data: \(error)")
            }
        }
    }
    
    // MARK: - Хранение времени последнего обновления (Пример)
    
    private let lastUpdateFriendsKey = "lastUpdateFriendsTimestamp"
    private let lastUpdateGroupsKey = "lastUpdateGroupsTimestamp"
    
    /// Сохраняет время последнего успешного обновления данных о друзьях.
    func setLastUpdateTimestampForFriends(date: Date = Date()) {
        UserDefaults.standard.set(date, forKey: lastUpdateFriendsKey)
        print("ℹ️ Установлено время последнего обновления друзей: \(date)")
    }
    
    /// Получает время последнего успешного обновления данных о друзьях.
    /// - Returns: `Date` последнего обновления или `nil`, если не установлено.
    func getLastUpdateTimestampForFriends() -> Date? {
        return UserDefaults.standard.object(forKey: lastUpdateFriendsKey) as? Date
    }
    
    /// Сохраняет время последнего успешного обновления данных о группах.
    func setLastUpdateTimestampForGroups(date: Date = Date()) {
        UserDefaults.standard.set(date, forKey: lastUpdateGroupsKey)
        print("ℹ️ Установлено время последнего обновления групп: \(date)")
    }
    
    /// Получает время последнего успешного обновления данных о группах.
    /// - Returns: `Date` последнего обновления или `nil`, если не установлено.
    func getLastUpdateTimestampForGroups() -> Date? {
        return UserDefaults.standard.object(forKey: lastUpdateGroupsKey) as? Date
    }
}
