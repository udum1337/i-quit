# «Не курю» / I Quit

iOS-приложение для отказа от никотина. Считает дни без сигарет, показывает восстановление организма и сколько денег осталось в кармане. Есть виджеты, напоминания и два языка.

Демо в браузере: https://udum1337.github.io/i-quit/prototype/

Код приложения лежит в `ios/`, прототип в `prototype/`. Сначала был HTML-прототип для проверки экранов, расчётов и онбординга, потом всё переехало в SwiftUI. Прототип остался в репозитории и ставится на iPhone как PWA.

## Что умеет

- Онбординг под пять продуктов: сигареты, вейп, IQOS, кальян, снюс. Для каждого свои единицы и цена.
- Главный экран со стриком, следующей вехой и эффектом на организм.
- Таймлайн из 16 вех. У каждой ссылка на WHO, CDC, NHS или другой источник.
- 17 достижений, тепловая карта и график экономии.
- Виджеты Small, Medium и для Lock Screen.
- RU/EN, светлая и тёмная тема, экспорт JSON.
- Данные лежат на устройстве. Аккаунтов, сервера и аналитики нет.

В PWA нет виджетов и настоящих уведомлений. Это демо интерфейса, а не замена приложению.

## Прототип

Можно открыть `prototype/index.html` или запустить сервер:

```powershell
cd prototype
python -m http.server 8000
```

Дальше открыть `http://localhost:8000`.

На iPhone ссылку добавляют на домашний экран через Safari: «Поделиться» → «На экран “Домой”». После первого открытия всё работает офлайн.

Подробности и список того, что стоит потыкать, лежат в `prototype/README.md`.

## iOS

Нужны macOS, Xcode 15+ и XcodeGen.

```bash
brew install xcodegen
cd ios
xcodegen generate
open IQuit.xcodeproj
```

Схема `IQuit`, любой iPhone-симулятор. Для запуска на телефоне нужна своя команда разработчика и App Group `group.com.iquit.ios`.

Тесты:

```bash
xcodebuild test \
  -project IQuit.xcodeproj \
  -scheme IQuit \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Если такого симулятора нет, подойдёт любой из `xcrun simctl list devices available`.

## Codemagic

`ios-verify` собирает приложение и виджет без подписи и запускает тесты. Apple Developer Program для него не нужен, поэтому ошибки компиляции видны до покупки аккаунта.

`ios-testflight` собирает IPA и отправляет в TestFlight. Нужны платный аккаунт Apple, App Store Connect API Key и переменные `APPLE_TEAM_ID` и `APP_STORE_CONNECT_*`.

Bundle ID пока плейсхолдеры: `com.iquit.ios`, `com.iquit.ios.widgets`. App Group: `group.com.iquit.ios`. Если будете менять, правьте `ios/project.yml`, `codemagic.yaml` и `WidgetStore.appGroup` вместе.

## Приватность

План и прогресс хранятся локально в SwiftData. Виджет читает снимок из App Group. Уведомления тоже локальные, в сеть ничего не уходит. В `PrivacyInfo.xcprivacy` трекинг выключен, сбор данных не заявлен.

## Здоровье

Приложение не медицинское изделие и не заменяет врача. Вехи собраны по публичным материалам WHO, CDC, NHS, American Cancer Society, American Lung Association, Cleveland Clinic и MedlinePlus; ссылки есть в приложении.

Исследования в основном про курение. Для вейпа, IQOS, кальяна и снюса сроки могут быть другими, приложение об этом предупреждает.

## Ограничения

В MVP нет Apple Watch, Live Activity, дневника тяги, iCloud и синхронизации. Валюта влияет только на отображение, курс не пересчитывается. Проверки на реальном iPhone и в TestFlight ещё не было: для них нужен Apple Developer Program.
