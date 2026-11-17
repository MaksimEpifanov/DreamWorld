# Подключение Firebase Authentication и Firestore

Firebase отвечает за регистрацию по email, письма с подтверждением и хранение
анкеты пользователя. Пока параметры проекта не заполнены, приложение работает
в мок-режиме без сети.

> Текущее состояние: параметры проекта `dreamworld-34005` уже вписаны в
> `firebase_config.dart`. Ниже описан порядок на случай смены проекта.

## 1. Проект Firebase

1. Откройте <https://console.firebase.google.com> и войдите в Google-аккаунт.
2. «Создать проект», имя например `dream-world`. Google Analytics можно
   выключить. Карта не требуется, тариф Spark бесплатный.
3. Дождитесь создания проекта.

## 2. Регистрация по email

1. Слева **Authentication** → «Начать».
2. Вкладка **Sign-in method** → **Email/Password** → включить первый
   переключатель («Email link» не нужен) → «Сохранить».
3. Вкладка **Templates** → шаблон **Email address verification** должен быть
   включён. Там же можно перевести текст письма на русский.
4. Вкладка **Settings** → блок **Authorized domains** → добавьте
   `maksimepifanov.github.io`, чтобы письма и вход работали с сайта
   на GitHub Pages. `localhost` там уже есть по умолчанию.

## 3. Приложения

### Android

1. «Настройки проекта» (шестерёнка) → внизу «Ваши приложения» → значок
   Android.
2. Package name: `com.dreemworld.app.dreem_world` — ровно так, иначе Firebase
   не примет запросы приложения.
3. Имя приложения любое, SHA-1 не обязателен для входа по паролю.
4. Скачайте `google-services.json` — он понадобится для значений `appId`,
   `messagingSenderId`, `projectId`, `apiKey`.

### Web

1. Там же → значок Web (`</>`), имя `dream-world-web`.
2. Скопируйте объект `firebaseConfig` — из него берутся `apiKey`, `authDomain`,
   `projectId`, `storageBucket`, `messagingSenderId`, `appId`.

## 4. Firestore

1. Слева **Firestore Database** → «Создать базу данных».
2. Режим — **Production mode**, регион ближайший (например `europe-west3`).
3. Вкладка **Rules** → вставьте содержимое [`firestore.rules`](firestore.rules)
   → «Опубликовать».

Правила разрешают пользователю читать чужие анкеты и менять только свою, а
также переписываться в чатах, где он указан участником. В чужой анкете
разрешено менять **только** поля-списки `contactIds`,
`incomingContactRequestIds` и `outgoingContactRequestIds` — это нужно, чтобы
запросы в контакты и **взаимные** контакты работали без серверных функций, на
бесплатном тарифе.

Отметки на карте планет хранятся в `planets/{planetId}/spots/{spotId}` и общие
для всех участников: читать их может любой вошедший, создавать и удалять —
только автор, а комментарии и лайки (`comments`, `likedBy`) добавляет любой
вошедший. Это делает отметки видимыми всем участникам планеты на сайте и в
приложении.

> Правила нужно обновлять при каждом изменении [`firestore.rules`](firestore.rules):
> без публикации приложение работает локально, а чаты и поиск чужих анкет
> получают отказ `permission-denied`. Если не опубликовать обновлённые правила,
> запрос в контакты не дойдёт до собеседника, а добавление в контакты останется
> **односторонним** (в консоли браузера будет `permission-denied`). По той же
> причине без публикации отметки на карте планеты не увидят другие участники.

## 5. Заполнение параметров в приложении

Файл [`app/lib/data/services/firebase_config.dart`](../app/lib/data/services/firebase_config.dart):

| Поле | Откуда взять |
|---|---|
| `projectId` | `firebaseConfig.projectId` / `google-services.json → project_info.project_id` |
| `apiKey` | `firebaseConfig.apiKey` (веб-ключ) |
| `androidApiKey` | `google-services.json → client[].api_key[].current_key` |
| `authDomain` | `firebaseConfig.authDomain` (обычно `PROJECT.firebaseapp.com`) |
| `storageBucket` | `firebaseConfig.storageBucket` |
| `messagingSenderId` | `firebaseConfig.messagingSenderId` / `project_info.project_number` |
| `androidAppId` | `google-services.json → client[].client_info.mobilesdk_app_id` |
| `webAppId` | `firebaseConfig.appId` |

После заполнения приложение при запуске инициализирует Firebase, а провайдер
аутентификации автоматически переключится с мок-режима на Firebase.

## 6. Проверка

1. Зарегистрируйтесь на сайте или в APK с реального адреса.
2. Проверьте «Входящие» и «Спам» — письмо отправляет Google.
3. Перейдите по ссылке, вернитесь в приложение и нажмите
   «Я подтвердил почту».
4. Если письмо не пришло, на экране подтверждения есть кнопка повторной
   отправки (с ограничением по времени).

## Ограничения

- Письма подтверждения приходят с адреса Firebase (`no-reply@PROJECT.firebaseapp.com`),
  свой домен не нужен.
- На бесплатном тарифе Spark есть суточные лимиты на письма и операции
  Firestore; для теста 15–20 человек их достаточно с большим запасом.
- Firebase в России может быть недоступен без VPN: проверьте, что домены
  `*.googleapis.com`, `*.firebaseapp.com` и `www.gstatic.com` открываются на
  тестовом устройстве.
