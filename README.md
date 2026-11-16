# «Не курю» / I Quit

Нативное iOS-приложение для отказа от никотина: стрик без никотина, таймлайн восстановления организма, сэкономленные деньги, достижения, виджеты и локальные напоминания.

Проект вырос из утверждённого интерактивного HTML-прототипа. Сейчас в репозитории лежат прототип и исходники iOS-приложения; сборка в TestFlight ещё не выполнялась, потому что нужны Apple Developer Program и доступ к Codemagic.

Репозиторий: https://github.com/udum1337/i-quit

## Статус

| Часть | Статус |
|---|---|
| HTML-прототип | ✅ Собран и проверен |
| iOS-исходники (SwiftUI, iOS 17+) | ✅ Подготовлены |
| Локализация RU / EN | ✅ 215 общих строк + InfoPlist |
| Виджет WidgetKit | ✅ Small, Medium, Lock Screen |
| Юнит-тесты расчётов | ✅ Написаны |
| XcodeGen-проект | ✅ `ios/project.yml` |
| Codemagic / TestFlight | ⏳ Нужны Apple Developer Program и секреты |
| Проверка компиляции | ⏳ Нет Mac; будет в Codemagic |

## Структура

```
.
├── prototype/              # утверждённый интерактивный прототип
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── README.md
├── ios/
│   ├── project.yml         # XcodeGen: приложение, виджет, тесты
│   ├── codemagic.yaml      # сборка и публикация в TestFlight
│   ├── Support/            # Signing.xcconfig (генерируемые plist/entitlements в .gitignore)
│   ├── Shared/             # WidgetSnapshot, общий для приложения и виджета
│   ├── IQuit/              # SwiftUI-приложение
│   │   ├── App/
│   │   ├── Core/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Views/
│   │   └── Resources/      # Assets, RU/EN Localizable.strings, InfoPlist.strings
│   ├── IQuitWidgets/       # WidgetKit-расширение
│   └── IQuitTests/         # XCTest
└── README.md
```

`android/` и `jelly-stack/` — посторонние локальные папки, они исключены через `.gitignore`.

## Прототип

Откройте `prototype/index.html` в браузере. Подробности, демо-данные и чек-лист проверки — в [`prototype/README.md`](prototype/README.md).

Прототип показывает продуктовые решения: 5 шагов онбординга, 5 продуктов, 8 валют, 16 вех здоровья, 17 достижений, срыв с отменой, экспорт JSON и переключение RU/EN.

## iOS-приложение

### Стек

- iOS 17+, iPhone, портретная ориентация
- SwiftUI + SwiftData
- Swift Charts: график экономии и тепловая карта
- WidgetKit: домашний экран и Lock Screen
- UserNotifications: локальные напоминания о вехах и достижениях
- XcodeGen: `.xcodeproj` не хранится в репозитории
- Локальные данные, без аккаунтов, бэкенда и аналитики

### Что реализовано

- **Главная**: кольцо стрика, лучший результат, следующая веха, текущий эффект на организм, экономия, «не использовано», достижения.
- **Таймлайн**: 16 вех по группам (часы, дни, месяцы, годы), маркер «Ты здесь», раскрытие вехи с длинным описанием и ссылками на источники.
- **Прогресс**: тепловая карта 12 недель, график накопленной экономии, сетка 17 достижений, прогресс по вехам.
- **Настройки**: продукт, дата отказа, расход, цена, валюта, уведомления, тема, язык, экспорт JSON, сброс, источники, дисклеймер.
- **Онбординг**: 5 шагов, 5 продуктов (сигареты, вейп, IQOS / стики, кальян, снюс), 8 валют, live-расчёт стоимости.
- **Срыв**: сохраняет лучший стрик, достижения и накопленные деньги; текущий отсчёт начинается заново. Есть undo в тосте.
- **Виджеты**: Small и Medium с кольцом, стриком, следующей вехой и экономией; accessory-виджеты для Lock Screen.

### Продукты и единицы

| Продукт | Единица расхода | Цена |
|---|---|---|
| Сигареты | сигарет в день | за пачку |
| Вейп | мл в день | за бутылку |
| IQOS / стики | стиков в день | за пачку |
| Кальян | сессий в неделю | за сессию |
| Снюс / паучи | паучей в день | за банку |

### Валюты

RUB, USD, EUR, KZT, UAH, BYN, GBP, TRY. Выбор валюты меняет только отображение суммы; курс не применяется. Цену нужно вводить в выбранной валюте.

## Сборка

### Локально на Mac

Требования: macOS, Xcode 15+, XcodeGen, Apple ID с командой разработчика.

```bash
brew install xcodegen
cd ios

# Укажите Team ID для локальной подписи:
# Support/Signing.xcconfig
# DEVELOPMENT_TEAM = XXXXXXXXXX

xcodegen generate
open IQuit.xcodeproj
```

В Xcode выберите схему `IQuit`, симулятор iPhone и запустите. Для запуска на устройстве включите автоматическую подпись и App Groups для `group.com.iquit.ios` у обоих таргетов.

Тесты:

```bash
xcodebuild test \
  -project IQuit.xcodeproj \
  -scheme IQuit \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Если такого симулятора нет, подставьте любой доступный iPhone из `xcrun simctl list devices available`.

Проверяются расчёты стоимости для сигарет, вейпа и кальяна, вехи, достижения, срыв и undo, `PlanDraft`, плюрализация виджета и прогресс.

### Codemagic → TestFlight

Нужно подготовить:

1. **Apple Developer Program** и доступ в App Store Connect.
2. **Bundle IDs** в Apple Developer:
   - `com.iquit.ios` — приложение;
   - `com.iquit.ios.widgets` — расширение;
   - App Group `group.com.iquit.ios` для обоих.
3. **App Store Connect API Key** (`.p8`, Key ID, Issuer ID).
4. **Codemagic**:
   - подключить GitHub-репозиторий;
   - создать переменную группу `app_store_connect`;
   - добавить `APPLE_TEAM_ID`, `APP_STORE_CONNECT_PRIVATE_KEY`, `APP_STORE_CONNECT_KEY_IDENTIFIER`, `APP_STORE_CONNECT_ISSUER_ID`;
   - включить интеграцию App Store Connect и загрузить ключ;
   - в **Code signing identities** создать или загрузить сертификат **Apple Distribution**;
   - там же получить (Fetch profiles) профили **App Store** для `com.iquit.ios` и `com.iquit.ios.widgets`. Codemagic подхватывает и профили расширений с префиксом `com.iquit.ios.*`.
5. В App Store Connect создать приложение с bundle ID `com.iquit.ios`.

Затем в Codemagic запустить workflow **I Quit — TestFlight** (`ios-testflight`). Он:

- устанавливает XcodeGen;
- перезаписывает `ios/Support/Signing.xcconfig` Team ID из `APPLE_TEAM_ID`;
- генерирует проект;
- применяет provisioning profiles для `com.iquit.ios.*`;
- собирает IPA;
- отправляет сборку в TestFlight.

Bundle ID и App Group — **плейсхолдеры**. Если будете менять, обновите одновременно:

- `ios/project.yml` (bundle IDs и entitlements);
- `ios/codemagic.yaml` (`BUNDLE_ID`, signing `bundle_identifier`);
- `ios/Shared/WidgetSnapshot.swift` (`WidgetStore.appGroup`).

### Подпись

`ios/Support/Signing.xcconfig` хранится в репозитории как пустой шаблон. Codemagic перезаписывает его перед сборкой. Для локальной сборки впишите свой `DEVELOPMENT_TEAM` вручную.

## Приватность

- Нет аккаунтов, сервера, трекинга и рекламы.
- Все данные плана хранятся локально в SwiftData.
- Виджет читает снимок из общего App Group на устройстве.
- Уведомления локальные, данные никуда не отправляются.
- `PrivacyInfo.xcprivacy` есть у приложения и виджета: трекинг выключен, данные не собираются, для `UserDefaults` указаны причины `CA92.1` и `1C8F.1` (App Group).
- Для App Store: **App Privacy → Data Not Collected**.

## Медицинская информация

Приложение помогает отслеживать прогресс и напоминает об известных фактах восстановления организма. Оно **не является медицинским изделием**, не ставит диагноз и не заменяет консультацию врача.

- 16 вех собраны по публичным материалам WHO, CDC, NHS, American Cancer Society, American Lung Association, Cleveland Clinic и MedlinePlus.
- У каждой вехи в приложении есть ссылки на источники и дисклеймер.
- Исследования в основном посвящены отказу от курения. Для вейпа, IQOS, кальяна и снюса сроки и эффекты могут отличаться — приложение показывает предупреждение.

## Ограничения MVP

- Нет Apple Watch, Live Activity, дневника тяги, iCloud и синхронизации.
- Нет аккаунтов и аналитики.
- Валюта — только отображение, без конвертации по курсу.
- Нет проверки сборки на реальном устройстве и в TestFlight до подключения Apple/Codemagic.

## Следующие шаги

1. Зарегистрировать Apple Developer Program и создать bundle IDs + App Group.
2. Подключить GitHub-репозиторий к Codemagic.
3. Добавить секреты `app_store_connect`.
4. Запустить workflow и исправить возможные ошибки компиляции.
5. Проверить приложение на iPhone: онбординг, оба языка, темы, уведомления, виджеты, срыв/undo, экспорт, сброс.
6. Собрать скриншоты и заполнить карточку App Store.
7. Отправить сборку в TestFlight.
