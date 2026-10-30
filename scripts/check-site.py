"""Verifica links locais e o isolamento dos índices de busca por idioma."""

import json
import re
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / '_site'


class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.targets = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        attribute = 'href' if tag == 'a' else 'src' if tag in {'img', 'script'} else None
        if attribute and attribute in attrs:
            self.targets.append(attrs[attribute])


def check():
    for language in ['pt', 'es', 'en']:
        config = json.loads((ROOT / '_localized' / language / '_quarto.yml').read_text(encoding='utf-8'))
        expected = {str(Path(path).with_suffix('.html')) for path in config['project']['render']}
        for page in sorted(expected):
            path = SITE / language / page
            html = path.read_text(encoding='utf-8')
            locale = 'pt-BR' if language == 'pt' else language
            assert f'lang="{locale}"' in html, path
            data = re.search(r'<script>window.PRISMA_I18N=(.*?);</script>', html)
            assert data and json.loads(data.group(1))['language'] == language, path
            links = Links()
            links.feed(html)
            for target in links.targets:
                url = urlsplit(target)
                if url.scheme or url.netloc or not url.path:
                    continue
                local = SITE / unquote(url.path.lstrip('/')) if url.path.startswith('/') else path.parent / unquote(url.path)
                assert local.exists(), f'{path.relative_to(SITE)}: {target}'
        records = json.loads((SITE / language / 'search.json').read_text(encoding='utf-8'))
        indexed = {urlsplit(record['href']).path.removeprefix('./') for record in records}
        assert indexed == expected, f'Índice de busca incorreto ({language}): {indexed ^ expected}'
        print(f'{language}: {len(expected)} páginas; links, scripts e busca verificados.')


if __name__ == '__main__':
    check()
