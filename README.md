# Как написать модуль

<p align="center">
  <a href="https://squidfunk.github.io/mkdocs-material/"><img src="https://img.shields.io/badge/Material_for_MkDocs-526CFE?logo=materialformkdocs&logoColor=white" alt="Material for MkDocs"></a>
  <img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python">
  <a href="https://github.com/talaev-sergey/edu-modules/commits/master"><img src="https://img.shields.io/github/last-commit/talaev-sergey/edu-modules" alt="Last commit"></a>
  <img src="https://img.shields.io/github/languages/top/talaev-sergey/edu-modules?logo=git&logoColor=white&color=F05032" alt="Top language">
  <img src="https://img.shields.io/github/repo-size/talaev-sergey/edu-modules" alt="Repo size">
</p>


### 1. Клонировать репозиторий и перейти в папку

```bash
git clone git@github.com:talaev-sergey/edu-modules.git   # или https://github.com/talaev-sergey/edu-modules.git
cd edu-modules
```

### 2. Создать ветку модуля

Имя — английский kebab-case с префиксом `module/` (например `module/python-basics`).

```bash
git switch -c module/python-basics
```

### 3. Переименовать шаблон в название модуля

Папку `module-template` переименуйте в имя модуля:

```bash
mv module-template python-basics
```

### 4. Открыть в Codex и начать работу

Откройте папку `python-basics` в Codex (File → Open Folder) — скиллы подключатся сами.

- **Методичка:** создайте файл урока в `content/` с номером (`lesson_01.md`, `.docx` или `.txt`).
  Вручную — пишите содержание сами; через агента — заполните `content/strategy.md`
  и напишите `напиши черновик урока 1` (`it-metodist`).
- **Вёрстка:** `верстай урок 1` (`mkdocs-programmer`). Проверка: `запусти сайт` → `останови сайт`.
