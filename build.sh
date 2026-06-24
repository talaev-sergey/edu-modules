#!/usr/bin/env bash
# Собирает каждый модуль в отдельный самодостаточный сайт и пакует в dist/<name>.zip.
# Общая тема (theme/) и базовый конфиг (mkdocs.base.yml) инлайнятся в каждый сайт
# на этапе сборки, поэтому архивы автономны.
#
#   ./build.sh            — собрать все модули
#   ./build.sh "От Git до Github" — собрать один модуль
set -euo pipefail
cd "$(dirname "$0")"

# Локальный venv (env/) имеет приоритет, если он есть; в CI зависимости ставятся в систему.
if [[ -x env/bin/mkdocs ]]; then
  PATH="$PWD/env/bin:$PATH"
fi

# Базовый адрес GitHub Pages. site_url каждого модуля собирается отсюда + имя
# папки и прокидывается в mkdocs через переменную SITE_URL (см. mkdocs.base.yml).
BASE_URL="https://talaev-sergey.github.io/edu-modules"

# Кладёт в собранный сайт скрипты-запускалки локального сервера, чтобы тьютор
# мог открыть модуль двойным кликом без терминала и без установки чего-либо.
# Сервер — встроенный http.server Python (он уже есть у того, кто ставил MkDocs).
add_launchers() {
  local site="$1"   # dist/<name>

  cat > "$site/start.command" <<'EOF'
#!/usr/bin/env bash
# macOS/Linux: двойной клик — поднимает локальный сервер и открывает браузер.
cd "$(dirname "$0")"

PY="$(command -v python3 || command -v python || true)"

# Если Python не найден — ставим штатным для системы менеджером пакетов.
if [[ -z "$PY" ]]; then
  echo "Python не найден. Пробую установить..."
  if [[ "$(uname)" == "Darwin" ]]; then
    if command -v brew >/dev/null 2>&1; then
      brew install python
    else
      echo "Homebrew не установлен. Поставьте его: https://brew.sh — затем снова запустите."
      read -r -p "Нажмите Enter для выхода..."; exit 1
    fi
  elif command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y python3
  elif command -v dnf     >/dev/null 2>&1; then sudo dnf install -y python3
  elif command -v pacman  >/dev/null 2>&1; then sudo pacman -S --noconfirm python
  elif command -v zypper  >/dev/null 2>&1; then sudo zypper install -y python3
  else
    echo "Не удалось определить менеджер пакетов. Установите Python вручную: https://www.python.org/downloads/"
    read -r -p "Нажмите Enter для выхода..."; exit 1
  fi
  PY="$(command -v python3 || command -v python)"
fi

"$PY" -m http.server 8000 &
SRV=$!
sleep 1
(open http://localhost:8000 2>/dev/null || xdg-open http://localhost:8000 2>/dev/null) || true
echo "Сайт открыт на http://localhost:8000 — закройте это окно, чтобы остановить сервер."
wait "$SRV"
EOF
  cp "$site/start.command" "$site/start.sh"
  chmod +x "$site/start.command" "$site/start.sh"

  cat > "$site/start.bat" <<'EOF'
@echo off
rem Windows: двойной клик — открывает браузер и поднимает локальный сервер.
rem pushd (в отличие от cd) понимает сетевые UNC-пути \\host\share, временно
rem подключая их как диск, — иначе запуск с сетевой шары отдал бы C:\Windows.
pushd "%~dp0"

rem Ищем Python (python или py). Если нет — пробуем поставить через Chocolatey.
where python >nul 2>nul && (set PY=python& goto run)
where py     >nul 2>nul && (set PY=py& goto run)

echo Python не найден. Пробую установить через Chocolatey...
where choco >nul 2>nul || (
  echo.
  echo Chocolatey не установлен. Установите его, запустив PowerShell от имени
  echo администратора: https://chocolatey.org/install — затем снова запустите start.bat.
  pause
  exit /b 1
)
choco install python -y || (
  echo.
  echo Не удалось установить Python. Запустите start.bat от имени администратора
  echo (правый клик — «Запуск от имени администратора»).
  pause
  exit /b 1
)
set PY=python

:run
start "" http://localhost:8000
%PY% -m http.server 8000 --directory "%~dp0"
popd
EOF
}

build_one() {
  local name="$1"
  local dir="modules/$name"
  [[ -f "$dir/mkdocs.yml" ]] || { echo "пропуск $name: нет mkdocs.yml"; return; }
  echo "→ Сборка $name"
  ( cd "$dir" && SITE_URL="$BASE_URL/$name/" mkdocs build -q -d "../../dist/$name" )
  add_launchers "dist/$name"
  ( cd dist && rm -f "$name.zip" && zip -rq "$name.zip" "$name" )
  echo "  dist/$name.zip"
}

rm -rf dist
if [[ $# -gt 0 ]]; then
  build_one "$1"
else
  for m in modules/*/; do
    name="$(basename "$m")"
    [[ "$name" == _* ]] && continue   # _template — заготовка, не модуль
    build_one "$name"
  done
  # Корневой лендинг со списком модулей + .nojekyll для GitHub Pages
  python tools/gen_index.py
fi
