#!/usr/bin/env python3
"""Генерирует корневой dist/index.html — лендинг со списком собранных модулей.

Список строится из подпапок dist/<name>/ (реально собранные сайты). Заголовок
каждого модуля берётся из его site_name в modules/<name>/mkdocs.yml. Также кладёт
рядом .nojekyll, чтобы GitHub Pages не пропускал служебные файлы.

Запускается из build.sh после сборки всех модулей.
"""
from __future__ import annotations

import html
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
DIST = ROOT / "dist"
MODULES = ROOT / "modules"

# Капсулы карточек (автор + статус) — заполняются вручную по slug модуля.
# status: "готов" → зелёная капсула, любое другое значение → «в работе» (янтарная).
# Модуль без записи здесь выводится без капсул.
META: dict[str, dict[str, str]] = {
    "git-github": {"author": "Сергей", "status": "готов"},
    "producere": {"author": "Олеся", "status": "в работе"},
}


def site_name(name: str) -> str:
    """site_name из mkdocs.yml модуля; имя папки как запасной вариант."""
    cfg = MODULES / name / "mkdocs.yml"
    if cfg.is_file():
        data = yaml.safe_load(cfg.read_text(encoding="utf-8")) or {}
        title = data.get("site_name")
        if title:
            return str(title)
    return name


def discover() -> list[tuple[str, str]]:
    """Список (slug, title) по собранным сайтам в dist/, отсортирован по title."""
    found = []
    for d in sorted(DIST.iterdir()):
        if d.is_dir() and (d / "index.html").is_file():
            found.append((d.name, site_name(d.name)))
    return sorted(found, key=lambda x: x[1].lower())


PAGE = """<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Учебные модули</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Rubik:wght@400;500;700&display=swap" rel="stylesheet">
<style>
  :root {{
    --bg: #1a1a1a;
    --card: #242424;
    --card-hover: #2c2c2c;
    --border: #383838;
    --fg: #e0e0e0;
    --muted: #888;
    --accent: hsl(120, 35%, 58%);
  }}
  * {{ box-sizing: border-box; }}
  body {{
    margin: 0;
    min-height: 100vh;
    background: var(--bg);
    color: var(--fg);
    font-family: "Rubik", system-ui, sans-serif;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 4rem 1.5rem;
  }}
  h1 {{
    font-size: 2.4rem;
    font-weight: 700;
    margin: 0 0 .5rem;
    color: hsl(30, 70%, 65%);
  }}
  p.lead {{ color: var(--muted); margin: 0 0 3rem; font-size: 1.05rem; }}
  .grid {{
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 1.25rem;
    width: 100%;
    max-width: 900px;
  }}
  a.card {{
    display: flex;
    flex-direction: column;
    padding: 1.5rem 1.5rem 1.6rem;
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 12px;
    text-decoration: none;
    color: var(--fg);
    transition: background .15s, border-color .15s, transform .15s;
  }}
  a.card:hover {{
    background: var(--card-hover);
    border-color: var(--accent);
    transform: translateY(-2px);
  }}
  a.card .title {{ font-size: 1.25rem; font-weight: 500; margin: 0; }}
  a.card .go {{ color: var(--accent); font-size: .9rem; margin-top: .75rem; display: block; }}
  a.card .meta {{
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-end;
    gap: .4rem;
    margin-top: auto;
    padding-top: 1.25rem;
  }}
  .capsule {{
    font-size: .72rem;
    line-height: 1;
    padding: .35rem .65rem;
    border-radius: 999px;
    border: 1px solid var(--border);
    background: #1e1e1e;
    color: var(--fg);
    white-space: nowrap;
  }}
  .capsule.author {{
    color: hsl(205, 70%, 80%);
    border-color: hsla(205, 55%, 65%, .45);
    background: hsla(205, 60%, 65%, .10);
  }}
  .capsule.status-wip {{
    color: hsl(35, 80%, 66%);
    border-color: hsla(35, 55%, 45%, .55);
    background: hsla(35, 60%, 50%, .12);
  }}
  .capsule.status-done {{
    color: var(--accent);
    border-color: hsla(120, 35%, 45%, .55);
    background: hsla(120, 40%, 50%, .12);
  }}
  .empty {{ color: var(--muted); }}
  footer {{ margin-top: auto; padding-top: 3rem; color: var(--muted); font-size: .85rem; }}
</style>
</head>
<body>
  <h1>Учебные модули</h1>
  <p class="lead">Выберите модуль, чтобы открыть методичку.</p>
  <div class="grid">
{cards}
  </div>
  <footer>Собрано из MkDocs Material</footer>
</body>
</html>
"""

CARD = """    <a class="card" href="./{slug}/">
      <span class="title">{title}</span>
      <span class="go">Открыть →</span>
{meta}    </a>"""

CAPSULE = '        <span class="capsule {cls}">{text}</span>\n'


def capsules(slug: str) -> str:
    """Блок капсул (автор + статус) для карточки; пусто, если нет записи в META."""
    info = META.get(slug)
    if not info:
        return ""
    rows = ""
    author = info.get("author")
    if author:
        rows += CAPSULE.format(cls="author", text=html.escape(author))
    status = info.get("status")
    if status:
        cls = "status-done" if status.strip().lower() == "готов" else "status-wip"
        rows += CAPSULE.format(cls=cls, text=html.escape(status))
    if not rows:
        return ""
    return f'      <span class="meta">\n{rows}      </span>\n'


def main() -> None:
    modules = discover()
    if modules:
        cards = "\n".join(
            CARD.format(
                slug=html.escape(slug),
                title=html.escape(title),
                meta=capsules(slug),
            )
            for slug, title in modules
        )
    else:
        cards = '    <p class="empty">Пока нет собранных модулей.</p>'

    (DIST / "index.html").write_text(PAGE.format(cards=cards), encoding="utf-8")
    (DIST / ".nojekyll").touch()
    print(f"  dist/index.html ({len(modules)} модул.)")


if __name__ == "__main__":
    main()
