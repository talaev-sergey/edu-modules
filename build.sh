#!/usr/bin/env bash
# Собирает каждый модуль в отдельный самодостаточный сайт и пакует в dist/<name>.zip.
# Общая тема (theme/) и базовый конфиг (mkdocs.base.yml) инлайнятся в каждый сайт
# на этапе сборки, поэтому архивы автономны.
#
#   ./build.sh            — собрать все модули
#   ./build.sh git-github — собрать один модуль
set -euo pipefail
cd "$(dirname "$0")"

build_one() {
  local name="$1"
  local dir="modules/$name"
  [[ -f "$dir/mkdocs.yml" ]] || { echo "пропуск $name: нет mkdocs.yml"; return; }
  echo "→ Сборка $name"
  ( cd "$dir" && mkdocs build -q -d "../../dist/$name" )
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
fi
