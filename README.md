# Как написать модуль

### 1. Клонировать репозиторий и перейти в папку

HTTPS:

```bash
git clone https://github.com/talaev-sergey/edu-modules.git
cd edu-modules
```

SSH:

```bash
git clone git@github.com:talaev-sergey/edu-modules.git
cd edu-modules
```

### 2. Создать ветку модуля и перейти в неё

Имя — на английском, kebab-case, префикс `module/` (например `module/python-basics`).

```bash
git checkout master
git pull origin master
git checkout -b module/python-basic
```

### 3. Создать папку модуля из шаблона

Копируем папку `module-template` в новую папку с именем модуля.

Windows (PowerShell):

```powershell
Copy-Item -Recurse module-template python-basics
```

### 4. Перейти в папку и подключить Codex

```bash
cd python-basics
```

Откройте папку `python-basics` в Codex (File → Open Folder). Скиллы подключатся сами.

### 5. Написать методичку

Создайте файл урока в `content/` (`.md`, `.docx` или `.txt`), имя с номером: `lesson_01.md`.

- **Вручную:** пишите содержание урока в этом файле.
- **Через агента:** заполните `content/strategy.md` и напишите в Codex
  `напиши черновик урока 1` — `it-metodist` создаст черновик.

### 6. Собрать урок

В Codex: `верстай урок 1` — `mkdocs-programmer` соберёт страницу сайта.
Проверить: `запусти сайт` → `останови сайт`.
