# AGENTS.md — инструкции для ИИ-агентов в репозитории Dream World

Этот файл описывает, как агентам (opencode и другим) работать в этом репозитории.
Полный контекст проекта, архитектура, текущее состояние и история — в
[`DREEMWORLD_CONTEXT.md`](DREEMWORLD_CONTEXT.md).

## 1. Что это за проект

**Dream World** — кроссплатформенное Flutter-приложение (Android / iOS / Web).
Основной актуальный продукт — неоновая «галактика интересов»: сообщества-планеты,
карта внутреннего мира планеты, лента новостей, чаты, безопасность, кошелёк и подписка.
Бэкенд-слой абстрагирован; сейчас в основном используются мок-реализации.
Firebase-зависимости в `app/pubspec.yaml` временно отключены (закомментированы) для упрощения CI-сборок; в коде есть заглушки/ветвление под Firebase. Деплой сайта — в приоритете.

> Важно: в репозитории есть исторические материалы (папки `01_Chronology` … `06_Limitations`,
> `docs/`, `README.txt`), которые описывают **более ранние концепции** и местами
> устарели. См. раздел «Противоречия и что требует уточнения» в `DREEMWORLD_CONTEXT.md`.

## 2. Технологии и архитектура

- **Клиент:** Flutter (Dart SDK `^3.13.5`, см. [`app/pubspec.yaml`](app/pubspec.yaml)), версия `1.0.0+1`.
- **Платформы:** Android, iOS, Web (основные целевые).
- **Состояние/навигация:** `flutter_riverpod`, `go_router`.
- **Модели/сериализация:** `freezed`/`freezed_annotation`, `json_serializable`/`json_annotation`, `equatable`.
- **Данные/интеграции:** `supabase_flutter` (в зависимостях), мок-сервисы; Firebase временно отключён.
- **UI/утилиты:** `flutter_animate`, `flutter_secure_storage`, `shared_preferences`, `image_picker`, `qr_flutter`, `intl`, `uuid`.
- **Структура кода:** `app/lib/` — приложение, `features/*` (экраны/фичи), `core/*` (тема, виджеты), `data/*` (модели, провайдеры, сервисы, репозитории). Следовать существующим паттернам.

## 3. Окружение и инструменты (важно!)

- ОС: **Windows**, оболочка — **PowerShell 5.1**. Файловая система — NTFS.
- Flutter: `C:\flutter\bin\flutter.bat`. Git: `C:\Program Files\Git\cmd\git.exe`.
  GitHub CLI: `C:\Program Files\GitHub CLI\gh.exe`.
- **PATH между командами не сохраняется** — всегда указывай полные пути к исполняемым файлам.
- В PowerShell **нет `&&`** — для последовательных зависимых команд используй
  `cmd1; if ($?) { cmd2 }`. В остальных случаях — `;`.
- Код приложения — в `app/`. Рабочая папка для Flutter-команд — `app`.
- Сообщения git в **stderr** PowerShell могут выглядеть как «error», но это не обязательно ошибка.
- Локальной сборки Android SDK нет → **APK собирается на GitHub Actions**
  (`.github/workflows/android-release.yml`). Локально проверяем Web-сборкой.

## 4. Язык и стиль

- Язык проекта, комментариев, документации и строк интерфейса — **только русский**.
- **Не добавляй комментарии к коду** без явной просьбы.
- Не добавляй новые зависимости без необходимости; сначала проверь, есть ли уже подходящая.
- Придерживайся существующих паттернов (`features/*`, Riverpod-провайдеры, токены темы).
- Форматирование/линт: [`app/analysis_options.yaml`](app/analysis_options.yaml) (включает `flutter_lints`). Генерация кода — [`app/build.yaml`](app/build.yaml).

## 5. Команды (из папки `app`)

```powershell
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat analyze
C:\flutter\bin\flutter.bat test
C:\flutter\bin\flutter.bat build web --release --base-href "/DreamWorld/"
```

- `analyze` и `test` должны проходить без ошибок перед завершением задачи.
- Для web-деплоя используется `--base-href "/DreamWorld/"` (см. `.github/workflows/web-deploy.yml`).
- Генерация (freezed/json), если нужна:
  ```powershell
  C:\flutter\bin\flutter.bat pub run build_runner build --delete-conflicting-outputs
  ```

> Тесты: `pumpAndSettle` может таймаутить из-за остаточных таймеров `flutter_animate`;
> в таких местах используй `pump(Duration)`. `tester.view.physicalSize` / `resetPhysicalSize`
> / `resetDevicePixelRatio` — для задания размеров окна.

## 6. Git, CI и деплой

- Репозиторий: **https://github.com/MaksimEpifanov/DreamWorld** (удалённый может отображаться как `DreamWorld`; локальная папка — `DreemWorld`), ветка `main`.
- Сайт: **https://maksimepifanov.github.io/DreamWorld/**.
- Релизы: APK — `v1.0.0`; iOS unsigned IPA (устройство) — `v1.0.0-ios`; iOS simulator — `v1.0.0-ios-sim` (по состоянию репозитория; проверять актуальность в Releases/Actions).
- Workflows: [`.github/workflows/web-deploy.yml`](.github/workflows/web-deploy.yml), [`.github/workflows/android-release.yml`](.github/workflows/android-release.yml), [`.github/workflows/ios-release.yml`](.github/workflows/ios-release.yml). Push в `main` при изменениях в `app/**` или workflow-файлах запускает соответствующие сборки.
- Проверка сайта:

```powershell
Invoke-WebRequest -UseBasicParsing -Uri "https://maksimepifanov.github.io/DreamWorld/main.dart.js" -Method Head
```

  Сравнивай `Content-Length` с предыдущим значением; так проверяется, что задеплоилась новая сборка.
- Наблюдение за workflow: `gh run watch <id> --exit-status --interval 15` (через полный путь к `gh.exe` при необходимости).
- Push иногда падает с `Recv failure: Connection was reset` — ретраить циклом с паузой.

### Правило безопасности (важно)

**Не выполняй `git push`, не публикуй сайт и не изменяй удалённый репозиторий
без отдельного явного разрешения пользователя.** Коммит и push — только по запросу.

## 7. Синхронизация контекста и совместная работа

- Пользователь может параллельно работать с другим ИИ (ChatGPT) на телефоне; тот даёт **текстовые промты/планы**,
  а изменения в репозиторий вносит **этот агент локально** (push делает человек/агент здесь только по разрешению).
- После **существенных** изменений и решений — обновляй `DREEMWORLD_CONTEXT.md`
  (не удаляй существующий ценный материал, а дополняй).
- Не выдумывай факты. Неизвестное помечай как «требует уточнения».

## 8. Рабочий процесс (рекомендуемый)

1. **Планирование:** начать с уточнения цели, ограничений и затрагиваемых файлов; при неоднозначности — задать вопросы. Для крупных задач использовать режим планирования (агент `plan`/плановый режим OpenCode, если доступен) или согласованный план в чате.
2. **Реализация:** вносить минимально достаточные изменения, следуя паттернам проекта; при необходимости использовать кодогенерацию (`build_runner`).
3. **Проверка:** запустить `/check` (или из `app`: `flutter analyze` и `flutter test`); для визуальных/web-задач — при необходимости `build web`.
4. **Ревью:** запустить `/review` для анализа последних изменений (агент `code-reviewer`), сверить результат с требованиями и рисками (адаптивность, регрессии, CI).
5. **Отчёт:** кратко перечислить изменения, файлы, результаты проверок и следующие шаги.
6. **Коммит/push/релиз:** только по явному разрешению пользователя.

## 9. Важные файлы конфигурации

- [`AGENTS.md`](AGENTS.md) — правила для агентов.
- [`DREEMWORLD_CONTEXT.md`](DREEMWORLD_CONTEXT.md) — контекст и история проекта.
- [`app/pubspec.yaml`](app/pubspec.yaml), [`app/pubspec.lock`](app/pubspec.lock) — зависимости.
- [`app/analysis_options.yaml`](app/analysis_options.yaml) — анализ/линты.
- [`app/build.yaml`](app/build.yaml) — настройки build_runner.
- [`.github/workflows/web-deploy.yml`](.github/workflows/web-deploy.yml), [`.github/workflows/android-release.yml`](.github/workflows/android-release.yml), [`.github/workflows/ios-release.yml`](.github/workflows/ios-release.yml) — CI/CD.

## 10. Известное ограничение инструментов

- Инструмент точечного редактирования (`edit`) к файлу
  `app/lib/features/planets/cosmos/orbital_catalog.dart` **иногда не применяется/откатывается**.
  Для этого файла (и при сомнениях — для других) используй полную перезапись (`write`) и
  затем проверяй содержимое поиском по строке.
