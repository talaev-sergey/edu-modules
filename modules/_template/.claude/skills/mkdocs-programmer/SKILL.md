---
name: mkdocs-programmer
description: >
  Use this skill for any of the following Russian trigger phrases:
  "верстай урок N", "верстай все уроки", "запусти сайт", "собери сайт",
  "задеплой сайт", "проверь сайт", "скриншот урока N", "останови сайт".
  English equivalents: "build the instructional material", "lay out the lesson",
  "typeset the draft", "assemble lesson from content".
---

# mkdocs-programmer

Assembly agent: turns the methodist's lesson draft — a Word `.docx` file in
`content/` produced by `it-metodist` — into a formatted MkDocs Material page wired
into site navigation. Build history → `work-log.md`.

---

## OS detection — run first, use throughout

Determine the OS once at the start of every session and use the matching
command column for all steps below.

```bash
# Linux
uname -s            # → Linux

# Windows (PowerShell)
$PSVersionTable.OS  # → Microsoft Windows ...
```

| | Linux | Windows (PowerShell) |
|---|---|---|
| Path separator | `/` | `\` (or `/` in PS) |
| Activate venv | `source ../../env/bin/activate` | `..\..\env\Scripts\Activate.ps1` |
| Kill port 8000 | `fuser -k 8000/tcp` | `netstat -ano \| findstr :8000` → `taskkill /PID <pid> /F` |
| Temp dir | `/tmp/` | `$env:TEMP\` |
| List files | `ls` | `dir` or `ls` (PS) |
| Copy tree | `cp -r src/. dst/` | `Copy-Item -Recurse src\* dst\` |
| Read file | `cat file` | `Get-Content file` |

> All code blocks below show **Linux** first, then **Windows** where different.

---

## HARD RULES

> **The shared theme is read-only — never edit it.**
> Work from inside your module folder (`modules/<name>/`). The shared theme and
> base config live one level up and apply to every module:
> `../../theme/` (templates, `stylesheets/extra.css`, `presentation.html`) and
> `../../mkdocs.base.yml`. Editing them changes all modules — do not touch them.
>
> Inside the module folder, only permitted writes:
> - New files under `docs/lessons/`
> - `nav:` block in `mkdocs.yml`
>
> Never touch: `../../theme/` (any file), `../../mkdocs.base.yml`,
> `mkdocs.yml` (non-nav sections, incl. the `INHERIT:` line),
> `docs/index.md`, `docs/preparation.md`, `docs/homework.md`, `docs/test.md`,
> `docs/materials.md`, `docs/lessons/lesson_template.md`.
>
> **`docs/lessons/lesson_template.md` is the section-set source of truth.**
> It defines which `##`/`###` sections a lesson page must have. `it-metodist`'s
> `references/lesson-template.md` is the clean-draft mirror of the same sections.
> If you change sections here, the methodist draft must be regenerated to match.

---

## Project structure

Each module is a folder under `modules/` in the monorepo. You work from inside it;
the theme and base config are shared one level up and apply to every module.

```
../../                       ← repo root (SHARED, read-only from a module)
  mkdocs.base.yml            ← shared config, pulled in via INHERIT
  requirements.txt           ← shared deps
  env/                       ← shared Python venv
  theme/                     ← shared theme — DO NOT TOUCH
    main.html, home.html
    stylesheets/extra.css
    static_assets/assets/presentation.html

modules/<name>/              ← THIS module = the working copy (cwd)
  mkdocs.yml                 ← INHERIT + site_name; only nav: is editable (site_url is auto)
  docs/
    index.md, preparation.md, homework.md, test.md, materials.md  ← DO NOT TOUCH
    assets/images/
    lessons/
      lesson_template.md     ← DO NOT TOUCH (canonical section set)
      lesson_01.md, …        ← agent writes here
  content/                   ← INPUT: methodist draft lesson_NN.docx + images/
  .claude/skills/mkdocs-programmer/
    SKILL.md | work-log.md
```

---

## "Материалы урока" page (docs/materials.md)

This page is **not edited by the agent** — only by the curriculum specialist manually.
It contains download-link cards for files needed during the module.

Four categories:

| Category | Folder in docs/assets/ | File types |
|----------|------------------------|------------|
| Презентации | `presentations/` | `.pptx`, `.pdf` — lesson slide decks |
| Код проекта | `code/` | `.zip` archive or a repository link |
| Программы для установки | `software/` | `.exe`/`.msi` installers, or an external link without the `download` attribute |
| Прочие материалы | `extra/` | Cheat sheets, worksheets, `.pdf`, `.docx` |

Each card is an HTML block `<div class="presentation-card">` (see the template in the file).
For external links (e.g. an official software website) remove the `download` attribute.

---

## Step 0 — Check location and environment

No bootstrap/copy step — the module folder is already the working copy. Confirm
you are inside a module (`modules/<name>/`) and the shared parts are reachable.

**Linux:**
```bash
ls mkdocs.yml docs/lessons/lesson_template.md ../../theme/main.html ../../mkdocs.base.yml
```
**Windows:**
```powershell
Test-Path mkdocs.yml, docs\lessons\lesson_template.md, ..\..\theme\main.html, ..\..\mkdocs.base.yml
```

All paths must exist. If `mkdocs.yml`/`docs/` are missing → you are not in a module
folder; `cd` into `modules/<name>/` first.

Ensure the shared venv exists (one per repo, at `../../env`):

**Linux:**
```bash
test -d ../../env || python -m venv ../../env
source ../../env/bin/activate && pip install -q -r ../../requirements.txt
```
**Windows:**
```powershell
if (-not (Test-Path ..\..\env)) { python -m venv ..\..\env }
..\..\env\Scripts\Activate.ps1; pip install -q -r ..\..\requirements.txt
```

---

## Step 1 — Read inputs

The methodist draft is a Word `.docx` file in `content/` (e.g. `lesson_03.docx`).
Look for it first.

**Linux:** `ls content/`  
**Windows:** `dir content\`

Extract lesson number from filename (case-insensitive, normalise to `lesson_NN`):

| Filename example | Slug |
|-----------------|------|
| `lesson_01.docx`, `1 урок.docx`, `Lesson 1.docx` | `lesson_01` |
| `12 урок.docx` | `lesson_12` |

If no number can be extracted → stop and ask.

Read the `.docx` draft (both platforms — only venv activation differs):

**Linux:**
```bash
source ../../env/bin/activate
python -c "from docx import Document; [print(p.text) for p in Document('content/<file>.docx').paragraphs]"
```
**Windows:**
```powershell
..\..\env\Scripts\Activate.ps1
python -c "from docx import Document; [print(p.text) for p in Document('content/<file>.docx').paragraphs]"
```
Install if needed: `pip install python-docx --break-system-packages`

> `Document(...).paragraphs` yields paragraph text but not tables. Read tables too —
> Общая информация, План урока, and Критерии оценки are tables in the draft:
> `for tbl in Document(...).tables: for row in tbl.rows: print([c.text for c in row.cells])`

If a draft happens to be plain `.md`/`.txt` instead, read it directly
(**Linux:** `cat "content/<file>"` · **Windows:** `Get-Content "content\<file>"`).

Read canonical template:

**Linux:** `cat docs/lessons/lesson_template.md`  
**Windows:** `Get-Content docs\lessons\lesson_template.md`

Copy images if present:

**Linux:** `cp -r content/images/. docs/assets/images/`  
**Windows:** `Copy-Item -Recurse content\images\* docs\assets\images\`

**Convert PNG → WebP and delete the originals.** Do this right after copying,
before resolving screenshot markers in Step 2, so every link points at a `.webp`
file. Uses ImageMagick (`magick`); lossy quality 85, compression method 6. Leave
only the `.webp` files in `docs/assets/images/` (drop the source `.png`).

**Linux:**
```bash
for f in docs/assets/images/*.png; do
  [ -e "$f" ] || continue
  magick "$f" -quality 85 -define webp:method=6 "${f%.png}.webp" && rm "$f"
done
```
**Windows:**
```powershell
Get-ChildItem docs\assets\images\*.png | ForEach-Object {
  magick $_.FullName -quality 85 -define webp:method=6 ($_.FullName -replace '\.png$','.webp')
  if ($?) { Remove-Item $_.FullName }
}
```

**Missing field policy:**

| Field | Required? | If missing |
|-------|-----------|------------|
| title, age, duration | Yes | Stop and ask |
| Stage timings | No | Default distribution (see below) |
| homework | No | `–` |
| Teacher notes | No | `–` in each subsection |
| Evaluation criteria | No | 4 generic criteria |

---

## Step 2 — Write output file

Create `docs/lessons/<slug>.md`. Follow `lesson_template.md` exactly —
same sections, same heading hierarchy, same front-matter keys.

**Drift-guard (run before writing).** Compare the `##` section set of the source
draft against `docs/lessons/lesson_template.md`:
- Section present in the canonical template but missing from the draft → do NOT
  silently drop it. Emit the section (filled if the draft has matching content,
  else `–`) and flag it in the final report as "section absent in draft".
- Section in the draft but not in the canonical template → keep it, but flag it —
  it signals the two templates have drifted and need re-syncing.

**Front matter** — exactly the keys present in the canonical template
(`lesson_number`, `duration`, `age`). The page title comes from the `# Урок …` H1.
```yaml
---
lesson_number: 2
duration: 120 мин
age: 10–12 лет
---
```
If you add `title`/`description` keys to the canonical template later, mirror them
here — the canonical template stays the source of truth for the key set.

**Formatting rules:**
- Concept explanations → `!!! note "…"`
- Warnings → `!!! warning`
- Tips → `!!! tip "…"`
- Multi-step tool variants → `=== "Tab"` tabbed blocks
- Feature overviews → `<div class="grid cards" markdown>`

**Screenshot markers** (`[СКРИНШОТ: описание]`, placed by `it-metodist`):
Each marker = one image insertion point. Resolve each one:
- Image exists in `docs/assets/images/` (copied & converted to WebP in Step 1) → replace the marker with
  `![описание](../assets/images/<file>.webp)`. Match by lesson number / order of markers.
- No matching image yet → keep the marker text as a visible HTML comment so nothing
  silently disappears: `<!-- TODO СКРИНШОТ: описание -->`, and list it in the report.
Never leave a raw `[СКРИНШОТ: …]` marker in the published page.

**`!!! slide` blocks** — wrap every fragment shown to students:

| Section | Slides |
|---------|--------|
| Цель урока | 1 |
| Теоретическая часть | 1 per concept |
| Практическая работа | 1 |
| Самостоятельная работа → Задание | 1 |
| Подведение итогов | 1 |
| Домашнее задание | 1 |

Never put `!!! slide` inside: Методические заметки, Действия преподавателя,
Критерии оценки, timing tables.

```markdown
!!! slide "Заголовок (3–6 слов)"
    Контент — любой markdown, отступ 4 пробела.
```

---

## Step 3 — Register in navigation

Edit only `nav:` in `mkdocs.yml`:
```yaml
  - Уроки:
      - 1 урок: lessons/lesson_01.md
      - N урок: lessons/<slug>.md    # ← add here
```

If slug already listed → update path, don't duplicate.

---

## Step 4 — Visual verification

**Linux:**
```bash
fuser -k 8000/tcp 2>/dev/null; sleep 1
source ../../env/bin/activate && mkdocs serve > /tmp/mkdocs.log 2>&1 &
sleep 4 && tail -5 /tmp/mkdocs.log
```
**Windows:**
```powershell
$pid8000 = (netstat -ano | findstr :8000 | Select-String "LISTENING" | ForEach-Object { ($_ -split "\s+")[-1] } | Select-Object -First 1)
if ($pid8000) { taskkill /PID $pid8000 /F }
..\..\env\Scripts\Activate.ps1
Start-Process -NoNewWindow mkdocs -ArgumentList "serve" -RedirectStandardOutput "$env:TEMP\mkdocs.log"
Start-Sleep 4; Get-Content "$env:TEMP\mkdocs.log" -Tail 5
```

Expect: `Serving on http://127.0.0.1:8000/...` — if errors appear, fix before continuing.

Install Playwright and take screenshot:

**Linux:**
```bash
pip3 install playwright --break-system-packages -q
python3 -m playwright install chromium
```
**Windows:**
```powershell
pip install playwright -q
python -m playwright install chromium
```

Screenshot script (same on both platforms, adjust temp path).
`site_url` is injected at build time (SITE_URL) and is absent from `mkdocs.yml`,
so local `mkdocs serve` runs at the site root — the base path is just `/`:
```python
import asyncio
from playwright.async_api import async_playwright

SCREENSHOT = "/tmp/lesson_verify.png"          # Linux
# SCREENSHOT = r"C:\Users\<user>\AppData\Local\Temp\lesson_verify.png"  # Windows
SLUG = "lesson_01"                              # ← set to the slug just written

url = f"http://127.0.0.1:8000/lessons/{SLUG}/"

async def main():
    async with async_playwright() as p:
        page = await (await p.chromium.launch()).new_context(
            viewport={"width":1440,"height":900}).new_page()
        await page.goto(url)
        await page.wait_for_load_state("networkidle")
        await page.screenshot(path=SCREENSHOT)
asyncio.run(main())
```

Verify in screenshot:
- [ ] Title and breadcrumbs correct
- [ ] Admonitions render (colour + icon)
- [ ] Code blocks have syntax highlighting
- [ ] No raw Markdown visible
- [ ] Nav sidebar correct position
- [ ] No 404

Fix any issues, re-screenshot. Stop server:

**Linux:** `fuser -k 8000/tcp`  
**Windows:** `taskkill /PID $pid8000 /F`

---

## Step 5 — Update work log

```
| YYYY-MM-DD | Built lesson N — <title> | docs/lessons/<slug>.md, mkdocs.yml |
```

---

## Default timing distribution

Stages must sum exactly to total duration. Round to whole minutes.

| Stage | Default |
|-------|---------|
| Организационный момент | 5 мин (fixed) |
| Теоретическая часть | 25% of remaining |
| Практическая работа | 40% of remaining |
| Самостоятельная работа | 25% of remaining |
| Подведение итогов | 10 мин (fixed) |

---

## Field mapping

| Raw content | Template section |
|-------------|-----------------|
| Title, number | Front matter + H1 |
| Course / module | Общая информация |
| Age, duration | Front matter + Общая информация |
| Goal | Цель урока |
| Timings | План урока + stage headings |
| Theory | §2 Теоретическая часть |
| Guided task | §3 Практическая работа |
| Solo task + rubric | §4 Самостоятельная работа |
| Wrap-up | §5 Подведение итогов |
| Homework | Домашнее задание |
| Difficulties / hints / extension | Методические заметки (3 subsections) |

---

## Common gotchas

| Problem | Fix |
|---------|-----|
| `mkdocs.yml`/`docs/` not found | You are not in a module folder — `cd modules/<name>/` |
| `../../theme` not found | Run from inside `modules/<name>/`, not the repo root |
| Port 8000 in use (Linux) | `fuser -k 8000/tcp` |
| Port 8000 in use (Windows) | `netstat -ano \| findstr :8000` → `taskkill /PID <pid> /F` |
| Activate.ps1 blocked (Windows) | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| `custom_dir` not found | It is `../../theme` in `mkdocs.base.yml`; run from the module folder, don't override it |
| Front matter not parsed | Add `meta` plugin under `plugins:` in `mkdocs.yml` |
| Page missing from nav | Add path under `nav: → Уроки:` |
| Admonition not rendering | Indent content exactly 4 spaces |
| Screenshot blank | Increase sleep to 6–8 s after `mkdocs serve` |

---

## Definition of done

- [ ] Run from inside the module folder (`modules/<name>/`, `mkdocs.yml` present)
- [ ] `docs/lessons/<slug>.md` written; all placeholders replaced
- [ ] Front matter keys match the canonical template (`lesson_number`, `duration`, `age`)
- [ ] Stage timings sum to total duration
- [ ] `nav:` updated in `mkdocs.yml`
- [ ] Screenshot confirms correct rendering
- [ ] No raw placeholder text (`[Название урока]`, `___ мин`, etc.)
- [ ] All `[СКРИНШОТ: …]` markers resolved (image embed or `<!-- TODO -->` comment)
- [ ] `!!! slide` present in every content section; absent from teacher sections
- [ ] Shared theme unchanged (`git diff ../../theme ../../mkdocs.base.yml` is clean)
- [ ] Row appended to `work-log.md`
