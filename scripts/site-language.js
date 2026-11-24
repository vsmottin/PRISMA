// Troca para a tradução da página atual ou para a página inicial do idioma.
(() => {
  const data = window.PRISMA_I18N;
  if (!data) return;
  const languages = { Português: 'pt', Español: 'es', English: 'en' };
  const remember = (language) => {
    try { localStorage.setItem('prisma-language', language); } catch (_) {}
  };
  if (!data.language) {
    let language = 'pt';
    try { language = localStorage.getItem('prisma-language') || language; } catch (_) {}
    if (!Object.values(languages).includes(language)) language = 'pt';
    location.replace(new URL(`${language}/index.html`, location.href));
    return;
  }
  remember(data.language);
  const initialize = () => {
    document.querySelectorAll('#quarto-header .dropdown-item').forEach((item) => {
      const language = languages[item.textContent.trim()];
      if (!language) return;
      const page = data.translations[language] || 'index.html';
      item.href = new URL(`${data.root}${language}/${page}`, location.href).href;
      item.addEventListener('click', () => remember(language));
      if (language === data.language) item.setAttribute('aria-current', 'true');
    });
    // O Quarto abre os ancestrais da página ativa; aqui todos começam fechados.
    document.querySelectorAll('#quarto-sidebar .sidebar-item-section .collapse').forEach((group) => {
      group.classList.remove('show');
      document.querySelectorAll(`[data-bs-target="#${group.id}"]`).forEach((toggle) => {
        toggle.classList.add('collapsed');
        toggle.setAttribute('aria-expanded', 'false');
      });
    });
  };
  if (document.readyState === 'complete') initialize();
  else window.addEventListener('load', initialize, { once: true });
})();
