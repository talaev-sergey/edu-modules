---
name: it-metodist
description: >
  Use this skill when a curriculum specialist asks to write a lesson draft for
  an IT school. English triggers: "write a lesson draft", "create lesson draft N",
  "draft a lesson guide", "write a lesson guide lesson N", "draft lesson",
  "write a lesson on the strategy", "create a lesson on the topic".
  Russian triggers: "напиши черновик урока N", "составь конспект урока N",
  "сделай черновик урока", "напиши урок по стратегии", "составь урок по теме",
  "подготовь методичку урока N". Required for any request to create a new lesson
  for school students — even if the word "draft" / "черновик" is not used.
---

# it-metodist

A curriculum-specialist agent that turns a module strategy and input materials into a
draft for a single lesson. The draft is a Word `.docx` file in `content/`, generated
with `python-docx`. MkDocs layout is handled by a separate agent (`mkdocs-programmer`),
which reads this `.docx` draft.

---

## STRICT RULES

> **No emojis** — anywhere, not in headings, not in body text.
>
> **Template structure is fixed.** All sections always, in the same order.
> Empty section = dash `–`. Removing or renaming sections is forbidden.
>
> **Section set source of truth = `template/docs/lessons/lesson_template.md`.**
> That canonical MkDocs page defines which top-level `##` sections (and key `###`
> subsections) a lesson has. `references/lesson-template.md` is the *clean-draft*
> form of the SAME section set — the two differ only in formatting (no front
> matter, no `!!! slide`, criteria as a table). If a section is added, removed, or
> renamed in the canonical file, mirror that change in `references/lesson-template.md`.
>
> **No MkDocs syntax in the draft text.**
> Plain content only — no `!!! note`, `=== "Tab"`, `<div class="grid cards">`, etc.
> The first element of the `.docx` is a Heading 1 paragraph `Урок N — Название`.
> Headings map to Word heading styles, tables to Word tables (see Step 4).
>
> **Audience** — school students aged 6–17. Environment — Windows 10/11.
> Most students have weak PC and OS skills (see "Audience Context").
>
> **Theory ≤ 25% of the lesson.** More only in Mode B (theory embedded in practice).

---

## Audience Context

Lessons take place on Windows 10/11. Most students have limited OS knowledge.

This means — always:
- Provide the full path to a file or program (not "open a terminal", but "press Win+R, type cmd, Enter")
- Name interface elements exactly as they are labelled in Windows ("Проводник", "Рабочий стол", "Панель задач")
- Step-by-step instructions — each action as a separate point, do not combine
- Warn about typical Windows traps: file extensions hidden by default, UAC prompts, UI differences between Windows 10 and 11
- In methodological notes, explicitly indicate where students most often get lost due to limited OS knowledge

---

## Project Structure

```
content/           ← input materials (.md, .txt, .docx)
  strategy.md      ← module strategy
  lesson_NN.docx   ← lesson draft (Word, generated with python-docx)
.codex/skills/it-metodist/
  SKILL.md
  work-log.md
  references/
    lesson-template.md
    methods/        ← vendored method skills (self-contained, see below)
```

---

## Step 0 — Questionnaire

Read `content/strategy.md`. Ask **all missing questions in a single message**.

**Required fields** (work does not begin without them):

| Field | Format |
|-------|--------|
| Lesson number | integer, e.g. `3` |
| Lesson topic | text |
| Student age | range, e.g. `10–12 лет` |
| Duration | minutes, fixed: `120 мин` |
| Module / course name | text |

**Optional fields** (default values):

| Field | Default |
|-------|---------|
| Homework | `–` |
| Methodological notes | `–` in each subsection |
| Assessment criteria | 4 universal criteria (see below) |
| Timing | standard (see "Timing") |

**Universal assessment criteria:**
1. Completed fully independently — excellent
2. Completed with minor errors or a hint — good
3. Completed partially, required help — satisfactory
4. Not completed — needs further work

---

## Default Timing

Sum of all stages = lesson duration. Round to whole minutes.

| Stage | Time |
|-------|------|
| Opening / organisational moment | 5 min (fixed) |
| Theory block | ≤ 25% of the lesson |
| Guided practice | ~40% of the lesson |
| Independent work | ~25% of the lesson |
| Wrap-up | 10 min (fixed) |

Mode B: theory 5–10 min, practice absorbs the remainder.

---

## Theory Block Rules

**Mode A (default):** single theory block ≤ 25% of the lesson.
- No more than 3–4 concepts; each: 2–4 sentences + a real-life example for a school student
- Mandatory subsection "Записи в блокнот" (terms/definitions, no more than 6)

**Mode B** (topic requires heavy theory — algorithms, networks, number systems):
theory section 5–10 min, practice sections include blocks:
```
Мини-теория: [1–3 sentences]
Задание: [specific action]
```
2–4 such blocks within a single practice section. Mode is determined by the strategy;
default is Mode A.

---

## Lesson Goal Formula (Bloom's Taxonomy)

> "By the end of the lesson, students will be able to [verb] [content] [measurable criterion]."

| Level | Verbs | When |
|-------|-------|------|
| Remember | name, list | introductory lesson |
| Understand | explain, describe | theory with examples |
| Apply | perform, create | practice (most IT lessons) |
| Analyse | compare, find an error | independent work |

Examples: "...will be able to create a repository on GitHub and make the first commit."
"...will be able to write a Java method with parameters and call it from `main`."

Forbidden: "will get acquainted with...", "will know...", "will study the basics of..."

---

## Method References (bundled)

Evidence-based method skills are vendored into `references/methods/` so this skill
is self-contained and shareable — no dependency on a global skills library.
They are reference material, not auto-invoked skills. Read the relevant file before
designing the matching section; apply the principle, keep the fixed template structure.

**Always consult when writing the practice/help sections:**

| File | Use for | Maps to |
|------|---------|---------|
| `explicit-instruction-sequence-builder.md` | I Do → We Do → You Do progression | §2 → §3 → §4 flow |
| `worked-example-fading-designer.md` | code/algorithms: full example → completion → independent | §3 Практическая работа |
| `practice-problem-sequence-designer.md` | graded difficulty + variability | §4 Самостоятельная работа, Домашнее задание |
| `adaptive-hint-sequence-designer.md` | cascading hints that don't give the answer | Методические заметки → Способы помощи |

**Consult for specific lesson types (optional):**

| File | When |
|------|------|
| `erroneous-example-designer.md` | debugging lessons — "find the error" (Bloom Analyse, Mode B) |
| `cognitive-load-analyser.md` | QA pass on the finished draft for the novice / weak-OS audience |

These references inform content; they never override the STRICT RULES, the fixed
template, or the theory ≤ 25% limit.

---

## Step 1 — Detect OS

Run the detection command and save the result — it determines which commands to use in the following steps.

```python
python -c "import platform; print(platform.system())"
```

| Output | OS | Commands to use |
|--------|----|-----------------|
| `Windows` | Windows 10/11 | Windows (cmd) variants below |
| `Linux` | Linux | Linux variants below |
| `Darwin` | macOS | Linux variants below |

If Python is unavailable:
- **Linux/macOS:** `uname -s`
- **Windows cmd:** `echo %OS%` → outputs `Windows_NT`
- **Windows PowerShell:** `$env:OS` → outputs `Windows_NT`

---

## Step 1.5 — Python Dependencies

Both reading `.docx` input materials (Step 2) and writing the `.docx` draft (Step 4)
require the `python-docx` package. Use the project venv so packages land in the
project environment, not globally — same venv the `mkdocs-programmer` agent uses.

Activate the shared venv (one per repo, at `../../env`; create it if missing —
`python -m venv ../../env`):

**Linux:**
```bash
source ../../env/bin/activate
```
**Windows (cmd):**
```cmd
..\..\env\Scripts\activate.bat
```

Then ensure `python-docx` is installed. It is declared in `../../requirements.txt`,
so install from there (also pulls MkDocs deps if the venv was just created):

**Linux:**
```bash
pip install -r ../../requirements.txt
```
**Windows:**
```cmd
pip install -r ..\..\requirements.txt
```

If there is no project venv, install just `python-docx` into the system interpreter:

**Linux:**
```bash
pip install python-docx --break-system-packages
```
**Windows:**
```cmd
pip install python-docx
```

`python -c "import docx"` with no error confirms the dependency is ready. Keep the
venv active for Steps 2 and 4.

---

## Step 2 — Read the Materials

**Linux:**
```bash
ls content/
cat content/strategy.md
```

**Windows (cmd):**
```cmd
dir content\
type content\strategy.md
```

For `.docx` (cross-platform; `python-docx` was prepared in Step 1.5):
```python
python -c "from docx import Document; [print(p.text) for p in Document('content/<file>.docx').paragraphs]"
```

## Step 3 — Read the Template

**Linux:**
```bash
cat .codex/skills/it-metodist/references/lesson-template.md
```

**Windows (cmd):**
```cmd
type .codex\skills\it-metodist\references\lesson-template.md
```

## Step 4 — Write the Draft (.docx)

Compose the full lesson content first (Russian; accessible style, no bureaucratic
phrasing; PC instructions account for weak Windows knowledge — see "Audience Context").
Follow the fixed section set from `references/lesson-template.md` exactly.

Before writing sections 3 and 4, consult the bundled method references
(see "Method References" above) — they shape practice design and the help notes.

**Screenshot markers.** Instead of verbal interface descriptions — use a marker as a
plain paragraph in the document:
```
[СКРИНШОТ: what exactly is visible, at which stage, which tool]
```
Examples:
```
[СКРИНШОТ: Windows terminal — git status output after the first commit]
[СКРИНШОТ: repository page on GitHub after creation]
[СКРИНШОТ: IntelliJ IDEA — console showing Hello World output]
```
One marker = one screenshot. Place exactly at the insertion point.
Screenshots are taken manually by the curriculum specialist; the programmer agent embeds them in MkDocs.

**Output format.** The draft is a Word `.docx` built with `python-docx`
(prepared in Step 1.5), saved as `content/lesson_NN.docx`. Map the template structure
to Word elements:

| Draft element | python-docx call |
|---------------|------------------|
| `# Урок N — …` | `doc.add_heading("Урок N — …", level=1)` |
| `## Section` | `doc.add_heading(text, level=2)` |
| `### Subsection` | `doc.add_heading(text, level=3)` |
| `#### Concept` | `doc.add_heading(text, level=4)` |
| Body paragraph | `doc.add_paragraph(text)` |
| `**bold**` label | `p.add_run("…").bold = True` |
| Numbered step | `doc.add_paragraph(text, style="List Number")` |
| Bullet point | `doc.add_paragraph(text, style="List Bullet")` |
| Table | `doc.add_table(rows, cols)`, set `table.style = "Table Grid"` |
| `[СКРИНШОТ: …]` marker | `doc.add_paragraph("[СКРИНШОТ: …]")` |

Write a Python script that builds the document and saves it. Skeleton:

```python
from docx import Document

doc = Document()
doc.add_heading("Урок N — Название", level=1)

doc.add_heading("Общая информация", level=2)
t = doc.add_table(rows=0, cols=2); t.style = "Table Grid"
for k, v in [("Курс", "…"), ("Модуль", "…"), ("Номер урока", "N"),
             ("Возраст учащихся", "N–N лет"), ("Продолжительность", "120 мин")]:
    c = t.add_row().cells; c[0].text = k; c[1].text = v

doc.add_heading("Цель урока", level=2)
doc.add_paragraph("К концу урока ученики смогут …")

# … remaining sections in the fixed order …

doc.save("content/lesson_NN.docx")
```

Empty section → a paragraph with a single dash `–` under its heading. Never drop a
section. No emojis, no MkDocs syntax in any string.

## Step 5 — Update the Work Log

```
| YYYY-MM-DD | Lesson N draft — <topic> | content/lesson_NN.docx |
```

## Step 6 — Output the Report

```
Report: lesson N — [Topic]
File: content/lesson_NN.docx
Duration: ___ min | Age: N–N лет | Theory mode: A/B

Timing:
  Opening __ min | Theory __ min (__%) | Guided practice __ min
  Independent work __ min | Wrap-up __ min

Screenshots (N):
  1. [description]
  2. [description]
  (none — write "not required")

Notes for the curriculum specialist:
  [fields with dash / reason for Mode B / "none"]
```

---

## Draft Structure

Detailed reference — in `references/lesson-template.md`. This is the *content* spec;
the output is a `.docx` (see Step 4 for the element mapping). Condensed outline:

```
# Урок N — [Title]
## Общая информация      (table)
## Цель урока            (Bloom's formula)
## План урока            (table: stage | time)
## Ход занятия
  ### 1. Организационный момент
  ### 2. Теоретическая часть
    #### Записи в блокнот
  ### 3. Практическая работа   (screenshot markers, Mode B — mini-blocks)
  ### 4. Самостоятельная работа
    #### Задание
    #### Критерии оценки
  ### 5. Подведение итогов
## Домашнее задание
## Методические заметки преподавателя
  ### Возможные сложности
  ### Способы помощи
  ### Дополнительные задания для быстрых
```

---

## Missing-Field Policy

| Field | Required? | If absent |
|-------|-----------|-----------|
| Topic, age, duration, module, lesson number | Yes | Stop — ask |
| Per-stage timing | No | Use standard |
| Homework, methodological notes | No | `–` |
| Assessment criteria | No | 4 universal criteria |

---

## Skill Limitations

Does not do: MkDocs layout, presentations, full module at once, images,
personalisation for an individual child. The draft requires review by a live curriculum specialist.

---

## Typical Agent Errors

| Error | Rule |
|-------|------|
| OS detection skipped, wrong commands used | Step 1 is mandatory before any file reads |
| Goal "students will get acquainted with..." | Bloom's formula is mandatory |
| Section deleted because nothing to fill in | Use `–` |
| Stage timings do not add up to total duration | Verify before writing |
| Theory 50%+ as a single block | Use Mode B |
| All theory in "Записи в блокнот" | Terms only, ≤ 6 |
| Vague assessment criteria | Use a concrete, observable action |
| Draft saved as `.md` | Output must be `content/lesson_NN.docx` (python-docx) |
| `python-docx` missing / not installed | Prepare it in Step 1.5 before writing |
| Headings written as `#`/`##` text instead of Word styles | Use `add_heading(level=…)` |
| MkDocs syntax in the text | Plain content only |
| Emojis in the text | Remove |
| PC instruction ignores Windows context | Full path, Windows element names |
| Verbal interface description instead of marker | Use `[СКРИНШОТ: ...]` |
| Work log not updated | Step 5 is mandatory |
| Report not output | Step 6 is mandatory |

---

## Definition of Done

- [ ] All required fields received
- [ ] OS detected (Step 1), `python-docx` ready (Step 1.5), `strategy.md` read, template read
- [ ] `content/lesson_NN.docx` created, first heading = `Урок N — …` (Heading 1)
- [ ] All template sections present; empty ones = `–`
- [ ] Placeholders replaced, timing sum = lesson duration
- [ ] Theory ≤ 25% (or Mode B justified)
- [ ] §3/§4 designed with the bundled method references (practice + help notes)
- [ ] "Записи в блокнот" section present
- [ ] PC instructions account for Windows and low-skill users
- [ ] `[СКРИНШОТ: ...]` markers placed
- [ ] No emojis, no MkDocs syntax
- [ ] `work-log.md` updated (Step 5)
- [ ] Report output to chat (Step 6)
