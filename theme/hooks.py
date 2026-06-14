"""Доставляет общие статические .html-ассеты в каждый собираемый сайт.

custom_dir трактует любые .html как Jinja-шаблоны и не копирует их в site,
поэтому presentation.html (просмотрщик слайдов) кладётся сюда, в
theme/static_assets/, и добавляется в сборку этим хуком. __file__ указывает
на общую тему, значит ассеты одни на все модули.
"""
import os
from mkdocs.structure.files import File

STATIC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "static_assets")


def on_files(files, config):
    if not os.path.isdir(STATIC_DIR):
        return files
    for root, _, names in os.walk(STATIC_DIR):
        for name in names:
            rel = os.path.relpath(os.path.join(root, name), STATIC_DIR)
            files.append(
                File(rel, src_dir=STATIC_DIR, dest_dir=config["site_dir"],
                     use_directory_urls=False)
            )
    return files
