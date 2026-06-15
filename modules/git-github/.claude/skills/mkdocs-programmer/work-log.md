# Work log — mkdocs-programmer

| Date | Action | Files touched |
|------|--------|---------------|
| 2026-06-09 | Skill created | `.claude/skills/mkdocs-programmer/SKILL.md` |
| 2026-06-11 | Added [СКРИНШОТ:…] marker handling; derive screenshot base path from site_url instead of hardcoded /mkdocs-test/ | `SKILL.md` |
| 2026-06-11 | Section-set contract (canonical template = source of truth) + Step 2 drift-guard; aligned front-matter keys to canonical (dropped title/description) | `SKILL.md` |
| 2026-06-14 | Verified lesson 1 — Что такое контроль версий. Установка Git и первая настройка (page already built & registered; HTTP 200, render OK) | docs/lessons/lesson_01.md, mkdocs.yml |
| 2026-06-14 | Rebuilt lesson 1 strictly from content/lesson_01.docx (git -v / git config -l, 4-step solo task, тьютор, no screenshot TODOs / core.editor extras) | docs/lessons/lesson_01.md |
| 2026-06-14 | Extracted 5 embedded images from lesson_01.docx and placed them in theory/blocks 1,3,4 | docs/lessons/lesson_01.md, docs/assets/images/lesson_01_*.png |
| 2026-06-15 | Rebuilt lesson 1 from updated draft — fixed «прав тьютора» → «прав администратора» in Возможные сложности | docs/lessons/lesson_01.md |
| 2026-06-15 | Built lesson 2 — Первый репозиторий: init, add, commit, status, log (6 embedded images extracted; reused lesson_01_gitbash_open.png for «Open Git Bash here» marker) | docs/lessons/lesson_02.md, docs/assets/images/lesson_02_*.png, mkdocs.yml |
