#!/usr/bin/env bash
# =============================================================================
# QRMesa — cria labels, milestones, issues e o quadro (GitHub Projects)
#
# Pré-requisitos:
#   1. GitHub CLI instalado (https://cli.github.com)
#   2. gh auth login
#   3. gh auth refresh -s project      (permissão para criar o quadro)
#   4. Rodar DENTRO da pasta do repositório (no Windows, use o Git Bash)
#
# Uso:  bash scripts/criar-issues.sh
# =============================================================================
set -euo pipefail

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
OWNER=$(gh repo view --json owner -q .owner.login)
echo "Repositório: $REPO"

# -----------------------------------------------------------------------------
# 1. Labels
# -----------------------------------------------------------------------------
echo "==> Criando labels..."
label() { gh label create "$1" --color "$2" --description "$3" --force >/dev/null; }
label setup        "BFD4F2" "Configuração inicial"
label backend      "1D76DB" "API ASP.NET Core"
label frontend     "0E8A16" "Next.js"
label banco        "5319E7" "PostgreSQL / EF Core"
label tempo-real   "FBCA04" "SignalR"
label impressao    "D93F0B" "Agente de impressão ESC/POS"
label seguranca    "B60205" "Segurança, LGPD, multi-tenant"
label infra        "C5DEF5" "Docker, CI, deploy"
label testes       "006B75" "Testes automatizados"
label docs         "0075CA" "Documentação"
label negocio      "F9D0C4" "Produto e vendas"

# -----------------------------------------------------------------------------
# 2. Milestones (fases)
# -----------------------------------------------------------------------------
echo "==> Criando milestones..."
milestone() {
  gh api "repos/$REPO/milestones" -f title="$1" -f description="$2" >/dev/null 2>&1 \
    || echo "   (milestone '$1' já existe)"
}
milestone "Fase 0 - Setup"            "Estrutura do repositório, Docker, CI"
milestone "MVP 1 - Pedido"            "Cliente faz pedido e a cozinha recebe em tempo real"
milestone "MVP 2 - Impressao"         "Impressão automática e menu de serviços"
milestone "MVP 3 - Painel"            "Multi-restaurante, login e painel do dono"
milestone "v1.0 - Pronto para vender" "Conta da mesa, relatórios, deploy e piloto"

# -----------------------------------------------------------------------------
# 3. Quadro (GitHub Projects)
# -----------------------------------------------------------------------------
echo "==> Criando o quadro..."
PROJECT_NUM=$(gh project create --owner "$OWNER" --title "QRMesa" --format json --jq .number)
gh project link "$PROJECT_NUM" --owner "$OWNER" --repo "$REPO" >/dev/null 2>&1 || true
echo "   Quadro nº $PROJECT_NUM criado"

# -----------------------------------------------------------------------------
# 4. Issues
# -----------------------------------------------------------------------------
issue() {
  local titulo="$1" milestone="$2" labels="$3" corpo="$4"
  local url
  url=$(gh issue create --title "$titulo" --milestone "$milestone" --label "$labels" --body "$corpo")
  gh project item-add "$PROJECT_NUM" --owner "$OWNER" --url "$url" >/dev/null
  echo "   ✔ $titulo"
}

echo "==> Criando issues..."

# ---------------- Fase 0 ----------------
M="Fase 0 - Setup"
issue "Criar solução .NET (Api, Domain, Infrastructure, PrintAgent, Tests)" "$M" "setup,backend" \
"## Objetivo
Criar a estrutura da solução conforme \`CLAUDE.md\`.

## Critérios de aceite
- [ ] \`QRMesa.sln\` com os projetos em \`/src\` e \`/tests\`
- [ ] Referências: Api → Infrastructure → Domain; Tests → todos
- [ ] \`dotnet build\` e \`dotnet test\` passam
- [ ] \`.gitignore\` e \`.editorconfig\` configurados"

issue "Docker Compose com PostgreSQL" "$M" "setup,infra" \
"## Critérios de aceite
- [ ] \`docker-compose.yml\` com PostgreSQL 17 e volume persistente
- [ ] Connection string em \`appsettings.Development.json\` (sem senha real commitada)
- [ ] \`docker compose up -d\` sobe o banco"

issue "Criar projeto Next.js com TypeScript e Tailwind" "$M" "setup,frontend" \
"## Critérios de aceite
- [ ] Projeto em \`/web\` (App Router, TypeScript, Tailwind, ESLint)
- [ ] Página inicial placeholder
- [ ] Variável \`NEXT_PUBLIC_API_URL\` em \`.env.example\`"

issue "CI com GitHub Actions (build + testes)" "$M" "setup,infra" \
"## Critérios de aceite
- [ ] Workflow roda em push e pull request
- [ ] Job .NET: restore, build, test
- [ ] Job web: npm ci, lint, build
- [ ] Badge do CI no README"

issue "README inicial" "$M" "docs" \
"## Critérios de aceite
- [ ] Descrição do problema e da solução
- [ ] Stack e diagrama de arquitetura
- [ ] Como rodar localmente
- [ ] Link para \`/docs\`"

# ---------------- MVP 1 ----------------
M="MVP 1 - Pedido"
issue "Entidades e migration inicial" "$M" "backend,banco" \
"## Objetivo
Implementar as entidades de \`docs/MODELO-DADOS.md\`: Restaurante, Mesa, Categoria, Produto, Cliente, SessaoMesa, Pedido, ItemPedido.

## Critérios de aceite
- [ ] Entidades no projeto Domain, configurações (Fluent API) no Infrastructure
- [ ] Dinheiro em \`numeric(10,2)\`
- [ ] Índices únicos: Cliente(RestauranteId, Telefone), Mesa(QrToken)
- [ ] Migration aplicada com sucesso"

issue "Seed com restaurante e cardápio de exemplo" "$M" "backend,banco" \
"## Critérios de aceite
- [ ] 1 restaurante, 10 mesas com QrToken aleatório, 3 categorias, 8 produtos
- [ ] Seed só roda em Development
- [ ] Tokens das mesas exibidos no log ao iniciar (para testes)"

issue "GET /api/mesas/{token}/cardapio" "$M" "backend" \
"## Critérios de aceite
- [ ] Retorna restaurante (nome, logo, espera média), número da mesa e categorias com produtos ativos ordenados
- [ ] Token inválido → 404
- [ ] Produtos esgotados vêm com \`esgotado: true\`
- [ ] Teste de integração"

issue "POST /api/mesas/{token}/identificar (cliente por WhatsApp)" "$M" "backend" \
"## Regras
- Telefone normalizado só com dígitos
- Se existe no restaurante → retorna cliente (nome) e atualiza UltimaVisitaEm
- Se não existe e veio nome + consentimento → cadastra
- Se não existe e não veio nome → \`{ novo: true }\`

## Critérios de aceite
- [ ] Telefone mascarado na resposta
- [ ] Retorna token de sessão do cliente (cookie ou JWT curto)
- [ ] Testes para cliente novo, existente e telefone inválido"

issue "Tela de identificação (WhatsApp + nome + LGPD)" "$M" "frontend" \
"## Critérios de aceite
- [ ] Máscara (12) 99999-9999
- [ ] Cliente existente: \"Bem-vindo de volta, {nome}!\"
- [ ] Cliente novo: campo nome + checkbox de política de privacidade obrigatório
- [ ] Layout mobile-first"

issue "Tela do cardápio com categorias e busca" "$M" "frontend" \
"## Critérios de aceite
- [ ] Cabeçalho: logo, \"Olá, {nome}\", mesa, espera média
- [ ] Abas de categorias com scroll horizontal; clique rola até a seção
- [ ] Busca filtra por nome/descrição
- [ ] Card com foto, descrição (2 linhas), preço em R\$ e botão +
- [ ] Item esgotado desabilitado"

issue "Carrinho" "$M" "frontend" \
"## Critérios de aceite
- [ ] Adicionar, remover, alterar quantidade
- [ ] Observação por item somente se \`permiteObservacao\`
- [ ] Total calculado
- [ ] Persistência em localStorage durante a sessão
- [ ] Ícone do carrinho com contador no cabeçalho"

issue "POST /api/pedidos" "$M" "backend" \
"## Regras
- Exige cliente identificado e token de mesa válido
- Copia nome e preço do produto para ItemPedido
- Rejeita produto inativo/esgotado ou de outro restaurante
- Total calculado no servidor (nunca confiar no front)

## Critérios de aceite
- [ ] Pedido criado com status Recebido e número do dia
- [ ] Testes de cálculo de total e validações"

issue "Hub SignalR: notificar cozinha de novo pedido" "$M" "backend,tempo-real" \
"## Critérios de aceite
- [ ] \`PedidosHub\` com grupos por restaurante
- [ ] Evento \`NovoPedido\` ao criar pedido
- [ ] Evento \`StatusPedidoAlterado\`
- [ ] PATCH /api/pedidos/{id}/status (não permite voltar status)"

issue "Painel da cozinha (KDS)" "$M" "frontend,tempo-real" \
"## Critérios de aceite
- [ ] Colunas: Recebido | Em preparo | Pronto
- [ ] Card: número, mesa, itens, observações, tempo decorrido
- [ ] Botão para avançar status
- [ ] Som ao chegar novo pedido
- [ ] Reconexão automática do SignalR"

issue "Status do pedido em tempo real para o cliente" "$M" "frontend,tempo-real" \
"## Critérios de aceite
- [ ] Após enviar o pedido, tela de acompanhamento
- [ ] Linha do tempo: Recebido → Em preparo → Pronto
- [ ] Atualiza sem recarregar a página"

# ---------------- MVP 2 ----------------
M="MVP 2 - Impressao"
issue "PrintAgent: conexão SignalR autenticada" "$M" "impressao" \
"## Critérios de aceite
- [ ] Worker Service lê ApiUrl e ChaveDispositivo de appsettings.json
- [ ] Conecta ao hub e entra no grupo do restaurante
- [ ] Reconexão automática com backoff
- [ ] Logs claros (conectado / desconectado)
- [ ] Pode ser instalado como serviço do Windows"

issue "PrintAgent: formatação ESC/POS do pedido" "$M" "impressao" \
"## Critérios de aceite
- [ ] Cabeçalho: restaurante, MESA em fonte grande, nº do pedido, hora
- [ ] Itens com quantidade e observação destacada
- [ ] Corte de papel ao final
- [ ] Envio por TCP 9100 (rede)
- [ ] Modo \"simulação\" que salva o cupom em .txt (para testar sem impressora)"

issue "Fila de impressão com confirmação e reimpressão" "$M" "impressao,backend" \
"## Critérios de aceite
- [ ] Pedido nasce com StatusImpressao = Pendente
- [ ] Agente confirma após imprimir → Impresso
- [ ] Ao reconectar, agente busca pendentes
- [ ] Botão \"Reimprimir\" no KDS
- [ ] Painel mostra se o agente está online"

issue "Chamar garçom" "$M" "backend,frontend" \
"## Critérios de aceite
- [ ] Botão no menu Serviços (bottom sheet, sem cobrir o cardápio)
- [ ] Limite: 1 chamado aberto por mesa
- [ ] Equipe recebe em tempo real e marca como atendido"

issue "Pedir a conta / Pagar no caixa" "$M" "backend,frontend" \
"## Critérios de aceite
- [ ] Cliente vê o resumo da conta da mesa
- [ ] Botão solicita a conta → SessaoMesa.StatusConta = ContaSolicitada
- [ ] Caixa recebe notificação com a mesa e o total"

issue "Histórico de pedidos e \"pedir de novo\"" "$M" "backend,frontend" \
"## Critérios de aceite
- [ ] Ícone de histórico no cabeçalho
- [ ] Lista de pedidos do cliente naquele restaurante
- [ ] \"Pedir de novo\" adiciona itens disponíveis ao carrinho"

issue "Avaliação do atendimento" "$M" "backend,frontend" \
"## Critérios de aceite
- [ ] 1–5 estrelas + comentário opcional
- [ ] Uma avaliação por sessão de mesa
- [ ] Nota 5 → convida a avaliar no Google (LinkAvaliacaoGoogle)"

# ---------------- MVP 3 ----------------
M="MVP 3 - Painel"
issue "Login da equipe (Identity + JWT + papéis)" "$M" "backend,seguranca" \
"## Critérios de aceite
- [ ] Papéis: Dono, Gerente, Cozinha, Garcom, Caixa
- [ ] Endpoints de admin protegidos por papel
- [ ] Tela de login em /admin/login"

issue "Isolamento multi-tenant com Global Query Filter" "$M" "backend,seguranca" \
"## Critérios de aceite
- [ ] Filtro global por RestauranteId em todas as entidades de negócio
- [ ] Tenant resolvido pelo JWT (equipe) ou token da mesa (cliente)
- [ ] Teste: usuário do restaurante A não acessa dados do B"

issue "CRUD de categorias e produtos com upload de imagem" "$M" "backend,frontend" \
"## Critérios de aceite
- [ ] Criar, editar, ordenar e desativar
- [ ] Upload de imagem com redimensionamento
- [ ] Validação de preço > 0"

issue "Gestão de mesas e geração de QR Codes em PDF" "$M" "backend,frontend" \
"## Critérios de aceite
- [ ] Criar/desativar mesas
- [ ] Regenerar token de uma mesa
- [ ] Gerar PDF com QR Codes (nº da mesa + logo) para impressão"

issue "Sessão de mesa + rate limit anti-trote" "$M" "backend,seguranca" \
"## Critérios de aceite
- [ ] Equipe abre/fecha sessão; sessão expira após X horas sem pedido
- [ ] Pedido sem sessão aberta → erro amigável
- [ ] Rate limit em /identificar e /pedidos"

issue "Botão \"Esgotado\" em tempo real" "$M" "backend,frontend" \
"## Critérios de aceite
- [ ] Toggle no painel
- [ ] Cardápio dos clientes atualiza via SignalR sem recarregar"

# ---------------- v1.0 ----------------
M="v1.0 - Pronto para vender"
issue "Conta da mesa com divisão por cliente" "$M" "backend,frontend" \
"## Critérios de aceite
- [ ] Total da mesa e total por cliente
- [ ] Divisão igual entre N pessoas"

issue "Relatórios básicos" "$M" "backend,frontend" \
"## Critérios de aceite
- [ ] Vendas por dia, itens mais vendidos, ticket médio, clientes recorrentes
- [ ] Filtro por período"

issue "Testes E2E com Playwright" "$M" "testes" \
"## Critérios de aceite
- [ ] Fluxo: escanear → identificar → pedir → cozinha recebe
- [ ] Roda no CI"

issue "Política de privacidade e exclusão de dados (LGPD)" "$M" "seguranca,docs" \
"## Critérios de aceite
- [ ] Página de política de privacidade
- [ ] Cliente pode pedir exclusão dos dados
- [ ] Dono pode exportar/excluir dados de um cliente"

issue "Deploy (Vercel + Railway) com domínio" "$M" "infra" \
"## Critérios de aceite
- [ ] Front na Vercel, API + PostgreSQL no Railway (ou similar)
- [ ] HTTPS e domínio próprio
- [ ] Variáveis de ambiente documentadas"

issue "Piloto em restaurante real" "$M" "negocio" \
"## Critérios de aceite
- [ ] Restaurante parceiro definido
- [ ] Treinamento da equipe
- [ ] Coleta das métricas do PRD por 2 semanas
- [ ] Relatório de aprendizados"

echo ""
echo "✅ Pronto! Abra: https://github.com/users/$OWNER/projects/$PROJECT_NUM"
