#!/usr/bin/env bash
# Публикует zip каждого модуля в GitHub Releases (лучшая практика).
#
# Версия берётся из git-тегов модуля (тег <slug>-vMAJOR.MINOR) — надёжная история,
# не теряется при ручном удалении релиза. В разделе Releases остаётся ровно одна
# (последняя) версия модуля: старый релиз удаляется, тег-история сохраняется.
#
# Слаг тега отделён от имени папки: имя папки/zip/заголовка может быть на русском,
# а тег обязан быть ASCII без пробелов. Слаг берётся из modules/<имя>/.release-slug
# (одна строка), иначе — из имени папки.
#
#   ./tools/release.sh                       — выпустить все модули (minor +1)
#   ./tools/release.sh "От Git до Github"    — выпустить один модуль
#   BUMP=major ./tools/release.sh "От Git до Github" — поднять major (X+1.0)
#   DRY_RUN=true ./tools/release.sh          — только показать план, ничего не публиковать
#
# Требует gh CLI и токен с правом contents:write (GH_TOKEN в CI).
set -euo pipefail
cd "$(dirname "$0")/.."

target="${1:-all}"
BUMP="${BUMP:-minor}"      # minor | major
DRY_RUN="${DRY_RUN:-false}"

slug_for() {
  # ASCII-слаг модуля для git-тега: из .release-slug, иначе имя папки.
  local name="$1" f="modules/$1/.release-slug"
  if [[ -f "$f" ]]; then
    head -n1 "$f" | tr -d '[:space:]'
  else
    echo "$name"
  fi
}

next_version() {
  # Эхо следующей версии модуля по его git-тегам (по слагу).
  local slug="$1" last major minor
  last="$(git tag --list "${slug}-v*" \
    | sed "s|^${slug}-v||" \
    | sort -t. -k1,1n -k2,2n \
    | tail -n1)"
  if [[ -z "$last" ]]; then
    echo "1.0"; return
  fi
  major="${last%%.*}"; minor="${last#*.}"
  if [[ "$BUMP" == major ]]; then
    echo "$(( major + 1 )).0"
  else
    echo "${major}.$(( minor + 1 ))"
  fi
}

release_one() {
  local name="$1"
  local zip="dist/$name.zip"
  [[ -f "$zip" ]] || { echo "пропуск $name: нет $zip"; return; }

  local slug
  slug="$(slug_for "$name")"

  # Текущий опубликованный релиз модуля (будет удалён после нового).
  local old_release
  old_release="$(gh release list --json tagName --jq \
    "map(.tagName) | map(select(startswith(\"${slug}-v\"))) | first // \"\"")"

  local ver new_tag
  ver="$(next_version "$slug")"
  new_tag="${slug}-v${ver}"

  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] $name → $new_tag (bump=$BUMP); удалил бы релиз: ${old_release:-<нет>}"
    return
  fi

  echo "→ Релиз $name $ver (тег $new_tag)"
  ( cd dist && sha256sum "$name.zip" > "$name.zip.sha256" )

  gh release create "$new_tag" "$zip" "dist/$name.zip.sha256" \
    --target "${GITHUB_SHA:-$(git rev-parse HEAD)}" \
    --title "${name} ${ver}" \
    --generate-notes \
    --latest=false

  if [[ -n "$old_release" && "$old_release" != "$new_tag" ]]; then
    echo "  удаляю прошлый релиз $old_release (тег-история сохраняется)"
    gh release delete "$old_release" --yes
  fi
}

if [[ "$target" == all ]]; then
  ./build.sh
  for m in modules/*/; do
    name="$(basename "$m")"
    [[ "$name" == _* ]] && continue
    release_one "$name"
  done
else
  ./build.sh "$target"
  release_one "$target"
fi
