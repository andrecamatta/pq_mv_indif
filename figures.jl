using Plots

# Parâmetros globais
utility_level = 0.03  # Nível de utilidade desejado (certainty equivalent)

# Utilidade Média-Variância
function mean_variance_utility(E_rp, sigma_rp, gamma)
    return E_rp - (gamma/2) * sigma_rp^2
end

E_rp_range = 0.00:0.05:0.6 # Intervalo de retorno esperado
sigma_rp_range = 0:0.05:0.6 # Intervalo de desvio padrão

# Define diferentes coeficientes de aversão ao risco
gamma_values = [0.5, 1, 3, 5]

# Calcula os valores de utilidade para todos os valores de gamma
U_values = []
for gamma in gamma_values
    U = [mean_variance_utility(E_rp, sigma_rp, gamma) for E_rp in E_rp_range, sigma_rp in sigma_rp_range]
    push!(U_values, U)
end

# Encontra os valores mínimo e máximo de utilidade em todos os gráficos
min_U = minimum(minimum(U) for U in U_values)
max_U = maximum(maximum(U) for U in U_values)

# Cria subplots
p = []
for (i, gamma) in enumerate(gamma_values)
    # Cria um gráfico de contorno para cada valor de gamma
    push!(p, plot(sigma_rp_range, E_rp_range, U_values[i], st=:contourf,
                   xlabel="Desvio Padrão", ylabel="Retorno Esperado",
                   title="γ = $(gamma)", fill=true, colorbar=true,
                   titlefontsize=8, guidefontsize=7, tickfontsize=6,
                   clims=(min_U, max_U)))
end

# Combina os gráficos em uma única imagem
plot(p..., layout=(2, 2), size=(600, 400))
savefig("figures.png")

# Cria um único gráfico com múltiplas curvas de indiferença
p2 = plot(xlabel="Desvio Padrão", ylabel="Retorno Esperado",
         title="Curvas de Indiferença para diferentes valores de γ",
         titlefontsize=10, guidefontsize=8, tickfontsize=7,
         size=(600, 400), margin=10Plots.mm, legend=:topright,
         yticks=0:0.05:0.6, ylims=(0, 0.6))

# Encontra pontos onde a utilidade = utility_level para cada gamma
for (i, gamma) in enumerate(gamma_values)
    points = []
    for sigma in sigma_rp_range
        # Encontra E_rp onde a utilidade = utility_level
        E_rp = (gamma/2) * sigma^2 + utility_level  # Usa a variável global utility_level
        push!(points, (sigma, E_rp))
    end
    xs = first.(points)
    ys = last.(points)
    plot!(p2, xs, ys, label="γ = $(gamma)")
end

savefig("indifference_curves.png")

# Cria um gráfico com curvas de indiferença e a fronteira eficiente
# Definindo retornos e desvios padrão históricos para bonds e stocks
E_bonds = 0.03  # Retorno esperado para bonds (3%)
sigma_bonds = 0.05  # Desvio padrão para bonds (5%)
E_stocks = 0.08  # Retorno esperado para stocks (8%)
sigma_stocks = 0.20  # Desvio padrão para stocks (20%)

# Cria um gráfico para a fronteira eficiente e curvas de indiferença
p3 = plot(xlabel="Desvio Padrão", ylabel="Retorno Esperado",
         title="Fronteira Eficiente e Curvas de Indiferença (γ = 5.0, CE = 0.02-0.04)",
         titlefontsize=10, guidefontsize=8, tickfontsize=7,
         size=(1000, 600), margin=10Plots.mm, legend=:outerbottom,
         xlims=(0, 0.25), ylims=(0, 0.10))

# Calcula e plota a fronteira eficiente (variando de 0% a 100% de bonds)
weights = 0:0.01:1  # Pesos para bonds (0% a 100%)
frontier_points = []

for w in weights
    # Cálculo do retorno esperado da carteira
    E_p = w * E_bonds + (1-w) * E_stocks
    
    # Cálculo do desvio padrão da carteira (assumindo correlação = 0.2)
    corr = 0.2
    sigma_p = sqrt(w^2 * sigma_bonds^2 + (1-w)^2 * sigma_stocks^2 + 
                  2 * w * (1-w) * corr * sigma_bonds * sigma_stocks)
    
    # Armazena também o peso (w) junto com as coordenadas
    push!(frontier_points, (sigma_p, E_p, w))
end

# Extrai coordenadas x e y para a fronteira eficiente
frontier_x = [p[1] for p in frontier_points]
frontier_y = [p[2] for p in frontier_points]
frontier_w = [p[3] for p in frontier_points]  # Pesos correspondentes

# Plota a fronteira eficiente
plot!(p3, frontier_x, frontier_y, label="Fronteira Eficiente", linewidth=2, color=:blue)

# Adiciona pontos para 100% bonds e 100% stocks
scatter!(p3, [sigma_bonds], [E_bonds], label="100% Bonds", markersize=6, color=:green)
scatter!(p3, [sigma_stocks], [E_stocks], label="100% Stocks", markersize=6, color=:red)

# Fixa gamma em 5.0 e varia o utility level
gamma_fixed = 5.0
utility_levels = [0.02, 0.025, 0.0309, 0.035, 0.04]
# Usa tons de cinza claro para as curvas de indiferença
colors = [RGBA(0.8, 0.8, 0.8, 0.7), RGBA(0.7, 0.7, 0.7, 0.7), 
          RGBA(0.5, 0.5, 0.5, 0.7), RGBA(0.7, 0.7, 0.7, 0.7), 
          RGBA(0.8, 0.8, 0.8, 0.7)]

# Dicionário para armazenar pontos de intersecção
intersections = Dict()

# Ordena os pontos da fronteira eficiente pelo desvio padrão (eixo x)
sorted_indices = sortperm(frontier_x)
sorted_frontier_x = frontier_x[sorted_indices]
sorted_frontier_y = frontier_y[sorted_indices]
sorted_frontier_w = frontier_w[sorted_indices]  # Ordena também os pesos

for (i, u_level) in enumerate(utility_levels)
    # Função para a curva de indiferença com gamma fixo em 5.0 e utility level variável
    indiff_func(sigma) = u_level + (gamma_fixed/2) * sigma^2
    
    # Gera pontos para a curva de indiferença
    indiff_points = []
    for sigma in 0:0.002:0.25  # Incremento menor para curvas mais suaves
        E_rp = indiff_func(sigma)
        push!(indiff_points, (sigma, E_rp))
    end
    
    indiff_x = first.(indiff_points)
    indiff_y = last.(indiff_points)
    
    # Plota a curva de indiferença
    plot!(p3, indiff_x, indiff_y, 
          label="Curva de Indiferença (CE = $(u_level))", 
          linestyle=:dash, linewidth=2, color=colors[i])
    
    # Encontra o ponto de intersecção (aproximado) apenas para utility_level = 0.03
    if u_level == 0.0309
        intersection_sigma = nothing
        intersection_return = nothing
        
        for j in 1:(length(sorted_frontier_x)-1)
            sigma_current = sorted_frontier_x[j]
            sigma_next = sorted_frontier_x[j+1]
            
            # Valores na fronteira eficiente
            frontier_current = sorted_frontier_y[j]
            frontier_next = sorted_frontier_y[j+1]
            
            # Valores na curva de indiferença
            indiff_current = indiff_func(sigma_current)
            indiff_next = indiff_func(sigma_next)
            
            # Verifica se há uma mudança de sinal na diferença (indicando intersecção)
            if (frontier_current - indiff_current) * (frontier_next - indiff_next) <= 0
            # Interpolação linear para encontrar o ponto exato
            t = abs(frontier_current - indiff_current) / 
                abs((frontier_next - indiff_next) - (frontier_current - indiff_current))
            
            intersection_sigma = sigma_current + t * (sigma_next - sigma_current)
            intersection_return = frontier_current + t * (frontier_next - frontier_current)
            
            # Interpola também o peso correspondente
            w_current = sorted_frontier_w[j]
            w_next = sorted_frontier_w[j+1]
            intersection_weight = w_current + t * (w_next - w_current)
            
            # Armazena o ponto de intersecção com o peso
            intersections[u_level] = (intersection_sigma, intersection_return, intersection_weight)
                break
            end
        end
    end
end

# Plota os pontos de intersecção apenas para utility_level = 0.03
for (u_level, (sigma, ret, w)) in intersections
    scatter!(p3, [sigma], [ret], 
             label="Intersecção (CE = $(u_level))", 
             markersize=6, markershape=:circle)
    
    # Calcula as porcentagens de bonds e stocks
    bond_pct = w * 100
    stock_pct = (1-w) * 100
    
    # Adiciona anotações com os valores
    annotate!(p3, [(sigma + 0.03, ret - 0.008, 
              text("CE = $(u_level)", 7, :black))])
    
    # Adiciona anotação com as proporções
    annotate!(p3, [(sigma + 0.03, ret - 0.012, 
              text("Bonds: $(round(bond_pct, digits=1))%, Stocks: $(round(stock_pct, digits=1))%", 7, :black))])
end

savefig("efficient_frontier.png")
