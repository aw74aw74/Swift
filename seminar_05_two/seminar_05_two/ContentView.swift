import SwiftUI

/// Главный экран приложения с кнопкой для перехода к списку новостей.
/// Это основное представление, которое отображается при запуске приложения.
struct ContentView: View {
    var body: some View {
        // NavigationView обеспечивает иерархическую навигацию
        NavigationView {
            // VStack располагает элементы вертикально
            VStack(spacing: 20) { // Отступы между элементами
                Text("Добро пожаловать!")
                    .font(.largeTitle) // Большой заголовок
                    .fontWeight(.bold) // Жирное начертание
                    .padding(.bottom, 30) // Отступ снизу
                
                // NavigationLink для перехода на экран NewsListView
                NavigationLink(destination: NewsListView()) {
                    Text("Посмотреть новости KudaGo")
                        .font(.headline) // Шрифт для заголовков
                        .foregroundColor(.white) // Белый цвет текста
                        .padding() // Внутренние отступы
                        .frame(minWidth: 200) // Минимальная ширина кнопки
                        .background(Color.blue) // Синий фон
                        .cornerRadius(10) // Скругленные углы
                        .shadow(radius: 3) // Небольшая тень
                }
                .buttonStyle(PlainButtonStyle()) // Стиль кнопки без стандартного оформления NavigationLink
            }
            .navigationTitle("Главная") // Заголовок навигационной панели
            .padding() // Внешние отступы для VStack
        }
    }
}

// MARK: - Preview для ContentView
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
