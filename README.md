# QuitOnClose

A lightweight native macOS menu-bar utility that quits an application when you click its window's red close button.

**English** | [Русский](#русский)

## Features

- Click the red close button to quit the application instead of closing only its window.
- Hold **Option (⌥)** while clicking to keep the standard macOS behavior.
- Temporarily enable or disable interception from the menu bar.
- Starts automatically at login after installation.
- Uses the application's normal **Command-Q** action, so it can still ask you to save unsaved changes.
- No Dock icon and no third-party dependencies.

## Requirements

- macOS 13 or later.
- Xcode Command Line Tools with Swift (only required to build from source).

## Install

```sh
git clone git@github.com:JIEgOKOJI/quitonclose.git
cd quitonclose
./install.sh
```

The installer builds the application, copies it to `/Applications/QuitOnClose.app`, and enables its LaunchAgent.

On first launch, macOS requests the following permissions under **System Settings → Privacy & Security**:

1. **Accessibility** — required to identify the red close button.
2. **Input Monitoring** — required to intercept clicks and send Command-Q.

Enable both permissions for QuitOnClose, then restart the utility:

```sh
pkill -x QuitOnClose
open /Applications/QuitOnClose.app
```

If macOS asks again after an update, approve the permissions again. The ⊗ icon in the menu bar indicates that the utility is running.

## Usage

- **Red button:** quit the application.
- **Option (⌥) + red button:** close only the window.
- **Menu-bar icon → Перехват включён / выключен:** toggle interception.
- **Menu-bar icon → Выйти из QuitOnClose:** quit the utility.

## Build without installing

```sh
./build.sh
open QuitOnClose.app
```

## Uninstall

```sh
./uninstall.sh
```

You can also remove the application's permissions in **System Settings → Privacy & Security**.

## How it works

QuitOnClose uses a Core Graphics event tap and the Accessibility API. When a left-click targets a window's close button, it consumes that click and sends Command-Q directly to the owning process. Option-click events are left untouched.

## Privacy

QuitOnClose runs entirely locally. It does not collect, store, or transmit any data.

---

<a id="русский"></a>

# QuitOnClose

Лёгкая нативная утилита для строки меню macOS, которая завершает приложение при нажатии красной кнопки закрытия окна.

## Возможности

- Красная кнопка завершает приложение, а не закрывает только его окно.
- **Option (⌥) + красная кнопка** сохраняет стандартное поведение macOS.
- Перехват можно временно включить или выключить через строку меню.
- После установки утилита автоматически запускается при входе в систему.
- Используется штатное действие **Command-Q**, поэтому приложение может запросить сохранение несохранённых изменений.
- Нет значка в Dock и сторонних зависимостей.

## Требования

- macOS 13 или новее.
- Xcode Command Line Tools со Swift — только для сборки из исходников.

## Установка

```sh
git clone git@github.com:JIEgOKOJI/quitonclose.git
cd quitonclose
./install.sh
```

Установщик соберёт приложение, скопирует его в `/Applications/QuitOnClose.app` и включит автозапуск через LaunchAgent.

При первом запуске macOS запросит разрешения в разделе **«Настройки» → «Конфиденциальность и безопасность»**:

1. **«Универсальный доступ»** — для определения красной кнопки закрытия.
2. **«Мониторинг ввода»** — для перехвата нажатий и отправки Command-Q.

Включите оба разрешения для QuitOnClose и перезапустите утилиту:

```sh
pkill -x QuitOnClose
open /Applications/QuitOnClose.app
```

Если macOS повторно запросит разрешения после обновления, выдайте их снова. Значок ⊗ в строке меню показывает, что утилита запущена.

## Использование

- **Красная кнопка:** завершить приложение.
- **Option (⌥) + красная кнопка:** закрыть только окно.
- **Значок в строке меню → «Перехват включён / выключен»:** переключить перехват.
- **Значок в строке меню → «Выйти из QuitOnClose»:** завершить утилиту.

## Сборка без установки

```sh
./build.sh
open QuitOnClose.app
```

## Удаление

```sh
./uninstall.sh
```

При желании также удалите разрешения приложения в разделе **«Настройки» → «Конфиденциальность и безопасность»**.

## Принцип работы

QuitOnClose использует Core Graphics event tap и Accessibility API. Когда левый клик приходится на красную кнопку окна, утилита отменяет этот клик и отправляет Command-Q непосредственно процессу приложения. Клики с зажатой клавишей Option не перехватываются.

## Конфиденциальность

QuitOnClose работает полностью локально и не собирает, не сохраняет и не передаёт никакие данные.
