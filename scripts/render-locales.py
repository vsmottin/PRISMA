"""Renderiza as versões e reúne os resultados no site principal."""

import os
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
quarto = os.environ.get('QUARTO_PATH', 'quarto')
for language in ['pt', 'es', 'en']:
    project = ROOT / '_localized' / language
    subprocess.run([quarto, 'render', str(project)], check=True, cwd=ROOT)
    shutil.copytree(project / '_site', ROOT / '_site' / language, dirs_exist_ok=True)
