# Componentes

Este diretório centraliza todos os blocos modulares que compõem os _datapaths_ do processador.

Cada subdiretório (como `ULA`, `bancoRegistradores`, `ucPrincipal`, etc.) corresponde a um componente isolado e contém, via de regra:
- O arquivo `.circ` do componente, que pode ser importado no circuito principal.
- Uma imagem `.png` ilustrativa.
- Um `README.md` detalhado explicando sua **Interface**, **Funcionamento** e **Implementação**.