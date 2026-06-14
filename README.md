# Как написать модуль

<p align="center">
  <a href="https://squidfunk.github.io/mkdocs-material/"><img src="https://img.shields.io/badge/Material_for_MkDocs-526CFE?logo=materialformkdocs&logoColor=white" alt="Material for MkDocs"></a>
  <img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python">
  <a href="https://github.com/talaev-sergey/edu-modules/commits/master"><img src="https://img.shields.io/github/last-commit/talaev-sergey/edu-modules" alt="Last commit"></a>
  <img src="https://img.shields.io/github/languages/top/talaev-sergey/edu-modules?logo=git&logoColor=white&color=F05032" alt="Top language">
  <img src="https://img.shields.io/github/repo-size/talaev-sergey/edu-modules" alt="Repo size">
</p>


Все модули живут в одном репозитории как папки в `modules/`. Общая тема, стили
и шаблоны лежат в `theme/` и `mkdocs.base.yml` — правишь один раз, меняется во
всех модулях. Отдельные ветки на модуль не нужны.

```
edu-modules/
├── theme/             ← общая тема: extra.css, шаблоны, presentation.html, баннер
├── mkdocs.base.yml    ← общий конфиг (подключается через INHERIT)
├── build.sh           ← сборка модуля в сайт + zip
└── modules/
    ├── _template/     ← заготовка для нового модуля
    ├── git-github/    ← модуль (свои docs/, content/, .claude, .codex)
    └── producere/
```

### 1. Клонировать репозиторий

```bash
git clone git@github.com:talaev-sergey/edu-modules.git   # или https://github.com/talaev-sergey/edu-modules.git
cd edu-modules
```

### 2. Создать модуль из заготовки

Имя — английский kebab-case (например `python-basics`).

```bash
cp -r modules/_template modules/python-basics
```

### 3. Открыть в Codex и начать работу

Откройте папку `modules/python-basics` в Codex (File → Open Folder) — скиллы подключатся сами.

- **Методичка:** создайте файл урока в `content/` с номером (`lesson_01.md`, `.docx` или `.txt`).
  Вручную — пишите содержание сами; через агента — заполните `content/strategy.md`
  и напишите `напиши черновик урока 1` (`it-metodist`).
- **Вёрстка:** `верстай урок 1` (`mkdocs-programmer`). Проверка: `запусти сайт` → `останови сайт`.

### 4. Собрать релиз

Каждый модуль собирается в самостоятельный сайт и пакуется в `dist/<name>.zip`:

```bash
./build.sh python-basics   # один модуль
./build.sh                 # все модули
```
