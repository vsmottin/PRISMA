"""Gera projetos Quarto por idioma a partir da documentação original."""

import json
import os
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GENERATED = ROOT / '_localized'
LANGUAGES = {'pt': 'Português', 'es': 'Español', 'en': 'English'}
TITLES = {'pt': 'Projeto PRISMA', 'es': 'Proyecto PRISMA', 'en': 'PRISMA Project'}
LABELS = {
    'atividades': ('Atividades', 'Actividades', 'Activities'),
    'codigos': ('Códigos', 'Códigos', 'Programs'),
    'componentes': ('Componentes', 'Componentes', 'Components'),
    'datapaths': ('Datapaths', 'Datapaths', 'Datapaths'),
    'estagiosPipeline': ('Estágios do pipeline', 'Etapas del pipeline', 'Pipeline stages'),
    'pipelineComponentes': ('Componentes do pipeline', 'Componentes del pipeline', 'Pipeline components'),
    'pipeline_bubble': ('Pipeline com bolhas', 'Pipeline con burbujas', 'Pipeline with bubbles'),
}
MARKER = '<!-- Gerado por scripts/prepare-docs.py; não editar. -->'


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists() or path.read_text(encoding='utf-8') != text:
        path.write_text(text, encoding='utf-8')


def language_and_key(path):
    match = re.search(r'-(pt|en|es)$', path.stem)
    language = match.group(1) if match else 'pt'
    stem = path.stem[:match.start()] if match else path.stem
    key = path.with_name(stem).with_suffix('.html').as_posix()
    if key == 'README.html':
        key = 'index.html'
    return language, key


def title_and_body(text, fallback):
    frontmatter = ''
    if text.startswith('---\n'):
        match = re.match(r'^---\n(.*?)\n---\n', text, re.S)
        if match:
            frontmatter = match.group(1)
            text = text[match.end():].lstrip('\n')
    heading = re.search(r'^#\s+(.+)$', text, re.M)
    explicit = re.search(r'^title:\s*(.+)$', frontmatter, re.M)
    title = explicit.group(1).strip().strip('\"\'') if explicit else heading.group(1) if heading else fallback
    # As opções restantes do documento continuam disponíveis para o Quarto.
    frontmatter = re.sub(r'^(title|lang|output-file|title-block-style):[^\n]*\n?', '', frontmatter, flags=re.M)
    return title, text, frontmatter


def sidebar(documents, language):
    tree = {'pages': [], 'children': {}}
    for document in documents:
        if document['key'] == 'index.html':
            continue
        node = tree
        for part in Path(document['key']).parts[:-1]:
            node = node['children'].setdefault(part, {'pages': [], 'children': {}})
        node['pages'].append({'text': document['title'], 'href': document['key'].replace('.html', '.qmd')})

    def items(node):
        result = sorted(node['pages'], key=lambda item: item['text'].casefold())
        for name, child in sorted(node['children'].items()):
            if not child['children'] and len(child['pages']) == 1:
                result.extend(child['pages'])
                continue
            labels = LABELS.get(name)
            manual = next((page['text'] for page in child['pages'] if page['href'].endswith('/README.qmd')), None)
            label = labels[list(LANGUAGES).index(language)] if labels else manual or re.sub(r'(?<=[a-z])(?=[A-Z])', ' ', name).replace('_', ' ')
            result.append({'section': label, 'contents': items(child)})
        return result

    home = {'pt': 'Início', 'es': 'Inicio', 'en': 'Home'}[language]
    return [{'text': home, 'href': 'index.qmd'}] + items(tree)


def page_text(title, body, metadata, language, key, translations):
    depth = len(Path(key).parts) - 1
    data = {'language': language, 'root': '../' * (depth + 1), 'translations': translations.get(key, {})}
    script_path = '../' * depth + 'site-language.js'
    scripts = '<script>window.PRISMA_I18N=' + json.dumps(data, ensure_ascii=False) + ';</script>'
    scripts += '<script src="' + script_path + '"></script>'
    return (
        '---\n' + metadata + '\n'
        + 'title: ' + json.dumps(title, ensure_ascii=False) + '\n'
        + 'lang: ' + ('pt-BR' if language == 'pt' else language) + '\n'
        + 'title-block-style: none\n'
        + 'include-after-body:\n  - text: |\n      ' + scripts + '\n'
        + '---\n\n' + body
    )


def prepare():
    documents, assets, pdfs = [], [], []
    for directory, folders, files in os.walk(ROOT):
        folders[:] = sorted(name for name in folders if not name.startswith(('.', '_')) and name not in {'scripts', 'node_modules', 'venv', 'site_libs'})
        for name in sorted(files):
            path = Path(directory) / name
            relative = path.relative_to(ROOT)
            if name.startswith(('.', '_')) or name in {'index.qmd', 'materiais.qmd'} and path.parent == ROOT or name == 'README-site.qmd':
                continue
            if path.suffix.lower() in {'.md', '.qmd'}:
                language, key = language_and_key(relative)
                title, body, metadata = title_and_body(path.read_text(encoding='utf-8'), relative.stem)
                documents.append({'source': relative.as_posix(), 'language': language, 'key': key, 'title': title, 'body': body, 'metadata': metadata})
            elif path.suffix.lower() in {'.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp', '.circ', '.pdf', '.txt', '.s', '.hex', '.bin', '.css'} or not path.suffix:
                assets.append(relative)
                if path.suffix.lower() == '.pdf':
                    pdfs.append(relative.as_posix())

    translations = {}
    sources = {}
    for document in documents:
        key, language = document['key'], document['language']
        if language in translations.setdefault(key, {}):
            raise ValueError(f'Documentos com o mesmo destino: {language}/{key}')
        translations[key][language] = key
        sources[document['source']] = {'language': language, 'key': key}
    translations.setdefault('index.html', {}).update({language: 'index.html' for language in LANGUAGES})

    for language in LANGUAGES:
        directory = GENERATED / language
        directory.mkdir(parents=True, exist_ok=True)
        selected = [doc for doc in documents if doc['language'] == language]
        pages = set()
        for document in selected:
            page = Path(document['key']).with_suffix('.qmd')
            pages.add(page)
            write(directory / page, page_text(document['title'], document['body'], document['metadata'], language, document['key'], translations))
        if Path('index.qmd') not in pages:
            body = {
                'es': '# Proyecto PRISMA\n\nDocumentación del procesador RISC-V implementado en Logisim-Evolution. El menú muestra únicamente los documentos disponibles en español.\n',
                'en': '# PRISMA Project\n\nDocumentation for the RISC-V processor implemented in Logisim-Evolution. The menu shows only the documents available in English.\n',
                'pt': '# Projeto PRISMA\n\nDocumentação do processador RISC-V.\n',
            }[language]
            write(directory / 'index.qmd', page_text(TITLES[language], body, '', language, 'index.html', translations))
            pages.add(Path('index.qmd'))

        if language == 'pt' and pdfs:
            body = '# Materiais em PDF\n\n' + '\n'.join(f'- [{path}]({path})' for path in sorted(pdfs)) + '\n'
            key = 'materiais.html'
            write(directory / 'materiais.qmd', page_text('Materiais em PDF', body, '', language, key, translations))
            pages.add(Path('materiais.qmd'))
            selected.append({'key': key, 'title': 'Materiais em PDF'})
        # Remove apenas páginas auxiliares obsoletas do diretório gerado.
        for stale in directory.rglob('*.qmd'):
            if stale.relative_to(directory) not in pages:
                stale.unlink()
        for asset in assets:
            target = directory / asset
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / asset, target)
        for script in ['site-links.lua', 'site-language.js']:
            shutil.copy2(ROOT / 'scripts' / script, directory / script)
        write(directory / '_pages.json', json.dumps({'language': language, 'sources': sources, 'translations': translations}, ensure_ascii=False))
        config = {
            'project': {'type': 'website', 'output-dir': '_site', 'render': sorted(page.as_posix() for page in pages), 'resources': [asset.as_posix() for asset in assets] + ['site-language.js']},
            'website': {
                'title': TITLES[language], 'site-url': f'https://vsmottin.github.io/PRISMA/{language}/', 'search': True,
                'navbar': {'right': [{'text': LANGUAGES[language], 'icon': 'translate', 'menu': [{'text': label, 'href': f'../{code}/index.html'} for code, label in LANGUAGES.items()]}]},
                'sidebar': {'style': 'docked', 'collapse-level': 1, 'contents': sidebar(selected, language)},
            },
            'format': {'html': {'lang': 'pt-BR' if language == 'pt' else language, 'theme': {'light': 'cosmo', 'dark': 'darkly'}, 'toc': True, 'toc-depth': 3, 'css': 'site.css'}},
            'filters': ['site-links.lua'],
        }
        write(directory / '_quarto.yml', json.dumps(config, ensure_ascii=False, indent=2) + '\n')
        print(f'{LANGUAGES[language]}: {len(pages)} páginas.')


if __name__ == '__main__':
    prepare()
