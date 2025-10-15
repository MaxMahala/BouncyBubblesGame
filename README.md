# 🌌 BouncyBubblesGame

> Коротко: аркадна 2D-гра на SpriteKit. Керуйте астронавтом, ухиляйтесь від куль, гемсів та розбивайте об’єкти пострілами. Великі об’єкти діляться на уламки, є підрахунок очок і фонова музика, пауза.

---

## Вимоги

- **iOS:** 14.0+
- **Xcode:** 15.x+
- **Swift:** 5.9+
- **Фреймворки:** SpriteKit, SwiftUI, AVFAudio (для музики)

---

## Як запустити

1. **Клонувати репозиторій**
   ```bash
   git clone https://github.com/MaxMahala/BouncyBubblesGame.git
   cd BouncyBubblesGame
   open BouncyBubblesGame.xcodeproj

## Керування

- Пересування: ведіть пальцем по екрану — гравець слідує по осі X.
- Постріл: тап під час дотику.
- Пауза/Продовжити: кнопка ⏸/▶ у правому верхньому куті.
- Музика: кнопка 🔊/🔇 у правому верхньому куті.

## Особливості геймплею

- 80px об’єкти (кулі/гемси) при влучанні діляться на два 40px уламки зі зменшеною швидкістю.
- 40px міні-кулі зникають від першого влучання.
- Об’єкти, що лежать і не рухаються протягом ~30 с, автоматично видаляються.
- Більш пружний відскок від підлоги для динамічного відчуття.

## 📁 Структура проєкту

BouncyBubblesGame/

├─ BouncyBubblesGameApp.swift # Точка входу SwiftUI (App)

├─ Assets/ # Зображення, іконки, шрифти

│

├─ Coordinator/

│ ├─ Protocol/

│ │ └─ GameCoordinatorDelegate.swift # Протокол оновлення рахунку тощо

│ └─ GameCoordinator.swift # Ігрова логіка: спавн, колізії, стрільба, рестарт

│

├─ Features/

│ ├─ Model/

│ │ └─ Cat.swift # Бітові маски фізики (player, bullet, …)

│ ├─ View/

│ │ ├─ GameView.swift # Головний SwiftUI-екран (SpriteView + кнопки)

│ │ └─ LoadingView.swift # Екран завантаження (фон, титул, підзаголовок)

│ └─ ViewModel/

│ └─ GameViewModel.swift # MVVM-стан: пауза, музика, рахунок; зʼєднання зі сценою

│

├─ Music/ # Аудіо (наприклад, interstellar.mp3)

│
├─ Preview Content/ # Дані для SwiftUI Preview (опційно)

│

├─ Scene/

│ └─ GameScene.swift # SpriteKit-сцена: торкання, делегування в Coordinator

│
└─ Services/

├─ AudioService.swift # AVAudioSession + SKAudioNode, керування музикою

├─ EntityFactory.swift # Створення спрайтів/тіл: гравець, кулі, гемси, уламки, куля

├─ MotionLimiter.swift # Клемпи швидкостей, авто-видалення після бездіяльності

└─ SpawnService.swift # Лічильник/фільтр обʼєктів, допоміжний спавн

## Screenshots

![Main Menu](Screenshots/01-menu.png)
![Gameplay](Screenshots/02-gameplay.png)

## Контакти / Автор

- Автор: Максим
- Email: maximmagala@gmail.com
- Telegram: @M_Maksyym
- Ліцензія: MIT
