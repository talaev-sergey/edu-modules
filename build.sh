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

build_one() {
  local name="$1"
  local dir="modules/$name"
  [[ -f "$dir/mkdocs.yml" ]] || { echo "пропуск $name: нет mkdocs.yml"; return; }
  echo "→ Сборка $name"
  ( cd "$dir" && SITE_URL="$BASE_URL/$name/" mkdocs build -q -d "../../dist/$name" )
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
