-- Resolve links dos documentos originais nas versões separadas por idioma.
local file = assert(io.open(quarto.project.directory .. '/_pages.json', 'r'))
local pages = quarto.json.decode(file:read('*a'))
file:close()

local function relative_target(language, key, input_dir)
  local project_dir = quarto.project.directory
  local depth = 0
  for part in pandoc.path.make_relative(input_dir, project_dir):gmatch('[^/]+') do
    if part ~= '.' then depth = depth + 1 end
  end
  if language == pages.language then
    return string.rep('../', depth) .. key
  end
  return string.rep('../', depth + 1) .. language .. '/' .. key
end

function Link(link)
  local path, suffix = link.target:match('^([^?#]*)(.*)$')
  if path == '' or path:match('^%a[%w+.-]*:') or path:match('^//') then return link end
  local input_dir = pandoc.path.directory(quarto.doc.input_file)
  local absolute = pandoc.path.normalize(pandoc.path.join({input_dir, path}))
  local parts = {}
  for part in pandoc.path.make_relative(absolute, quarto.project.directory):gmatch('[^/]+') do
    if part == '..' then table.remove(parts)
    elseif part ~= '.' then table.insert(parts, part) end
  end
  local source = table.concat(parts, '/')
  local document = pages.sources[source]
  -- Cópias antigas nas atividades podem referenciar um manual compartilhado
  -- que não existe na cópia local. Procura o mesmo caminho na raiz do projeto.
  if not document and (path:match('%.md$') or path:match('%.qmd$')) then
    local candidate = source
    while candidate:find('/') do
      candidate = candidate:gsub('^[^/]+/', '')
      if pages.sources[candidate] then
        document = pages.sources[candidate]
        source = candidate
        break
      end
    end
  end
  local directory = path:sub(-1) == '/' or not path:match('%.[^/]+$')
  if not document and directory then
    for _, name in ipairs({'README.md', 'index.md', 'index.qmd'}) do
      document = pages.sources[(source == '' and '' or source .. '/') .. name]
      if document then break end
    end
  end
  if document then
    local language = document.language
    local label = pandoc.utils.stringify(link.content)
    local explicit_language = path:match('%-en%.') or path:match('%-es%.') or path:match('%-pt%.')
    if not explicit_language and label ~= 'Português' then
      language = pages.language
    end
    if pages.translations[document.key][language] then
      link.target = relative_target(language, document.key, input_dir) .. suffix
    else
      link.target = 'https://github.com/vsmottin/PRISMA/blob/main/' .. source .. suffix
    end
  elseif directory then
    link.target = 'https://github.com/vsmottin/PRISMA/tree/main/' .. source .. suffix
  elseif source:match('^%.github/') then
    link.target = 'https://github.com/vsmottin/PRISMA/blob/main/' .. source .. suffix
  end
  return link
end
