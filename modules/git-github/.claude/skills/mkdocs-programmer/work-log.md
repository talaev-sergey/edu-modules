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
| 2026-06-17 | Built lesson 3 — История изменений: просмотр, отмена, возврат к версии (4 embedded images extracted → lesson_03_*.webp; mapped to blocks 1,2,5,6) | docs/lessons/lesson_03.md, docs/assets/images/lesson_03_*.webp, mkdocs.yml |
| 2026-06-18 | Built lesson 4 — Ветки: создание, переключение, слияние (5 content/*.png recoded → lesson_04_*.webp, originals deleted; mapped to blocks 1,3,4,5) | docs/lessons/lesson_04.md, docs/assets/images/lesson_04_*.webp, mkdocs.yml |
| 2026-06-19 | Built lesson 5 — GitHub: аккаунт, удалённый репозиторий, push и pull (12 content/*.png recoded → lesson_05_*.webp, originals deleted; slide titles без «Блок N») | docs/lessons/lesson_05.md, docs/assets/images/lesson_05_*.webp, mkdocs.yml |
| 2026-06-20 | Built lesson 6 — Клонирование и работа с чужими проектами: clone, fork (11 content/*.png recoded → lesson_06_*.webp, originals deleted; image.png → lesson_06_code_button.webp inserted at Блок 1 шаг 4, where draft had no ![] marker; quiz-6.html (5 Q, grade scale /5) on quiz-3 base; homework copied into homework.md) | docs/lessons/lesson_06.md, docs/interactives/quiz-6.html, docs/assets/images/lesson_06_*.webp, docs/homework.md, mkdocs.yml |
| 2026-06-21 | Built lesson 7 — Командная работа: Pull Request, Issues, обзор кода (23 content/*.png recoded → lesson_07_image*.webp, originals deleted, all 23 embedded with descriptive alt; 1 [СКРИНШОТ] left as TODO comment; quiz-7.html (5 Q, grade /5) on quiz-6 base; homework copied into homework.md; slide titles без «Блок N») | docs/lessons/lesson_07.md, docs/interactives/quiz-7.html, docs/assets/images/lesson_07_*.webp, docs/homework.md, mkdocs.yml |
