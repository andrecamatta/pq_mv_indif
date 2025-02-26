# Otimização de Portfólio Média-Variância com Curvas de Indiferença

Este projeto implementa a otimização de portfólio média-variância com curvas de indiferença em Julia. Ele visualiza:

- Gráficos de contorno de utilidade para diferentes coeficientes de aversão ao risco
- Curvas de indiferença para vários valores de aversão ao risco
- A fronteira eficiente com alocação ótima de portfólio

## Arquivos

- `figures.jl`: Script Julia que gera todas as visualizações
- Arquivos de saída (não incluídos no repositório):
  - `figures.png`: Gráficos de contorno mostrando utilidade para diferentes coeficientes de aversão ao risco
  - `indifference_curves.png`: Curvas de indiferença para diferentes valores de aversão ao risco
  - `efficient_frontier.png`: A fronteira eficiente com curvas de indiferença

## Uso

Execute o script Julia para gerar as visualizações:

```julia
julia figures.jl
```
