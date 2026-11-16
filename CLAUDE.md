# CLAUDE.md — QRMesa

Este arquivo é lido automaticamente pelo Claude Code. Mantenha-o atualizado.

## O que é
SaaS multi-restaurante de pedidos por QR Code na mesa. O cliente escaneia o QR, se identifica pelo WhatsApp + nome, faz o pedido pelo cardápio digital e o pedido chega à cozinha (tela KDS + impressora térmica).

Documentação completa em `/docs`: `PRD.md`, `ARQUITETURA.md`, `MODELO-DADOS.md`, `ROADMAP.md`.

## Stack
| Camada | Tecnologia |
|---|---|
| API | ASP.NET Core (.NET 10), Minimal APIs ou Controllers, EF Core |
| Banco | PostgreSQL 17 (via Docker em desenvolvimento) |
| Tempo real | SignalR |
| Frontend | Next.js (App Router) + TypeScript + Tailwind CSS |
| Impressão | .NET Worker Service + ESC/POS (impressora térmica 80mm) |
| Testes | xUnit + FluentAssertions (backend), Playwright (E2E) |
| CI | GitHub Actions |

## Estrutura de pastas
```
/src
  QRMesa.Api/             → endpoints, hubs SignalR, configuração, Program.cs
  QRMesa.Domain/          → entidades, enums, regras de negócio (sem dependências externas)
  QRMesa.Infrastructure/  → DbContext, migrations, repositórios, serviços externos
  QRMesa.PrintAgent/      → Worker Service que roda no PC da cozinha
/tests
  QRMesa.Tests/           → testes unitários e de integração
/web                      → Next.js (cliente em /m/[token], painel em /admin)
/docs                     → documentação do produto
/scripts                  → automações (ex.: criar issues)
docker-compose.yml
```

## Comandos
```bash
docker compose up -d                       # sobe o PostgreSQL
dotnet build                               # compila a solução
dotnet test                                # roda os testes
dotnet run --project src/QRMesa.Api        # sobe a API
dotnet ef migrations add <Nome> -p src/QRMesa.Infrastructure -s src/QRMesa.Api
dotnet ef database update -p src/QRMesa.Infrastructure -s src/QRMesa.Api
cd web && npm run dev                      # sobe o frontend
```

## Convenções
- **Código em inglês ou português?** Código (classes, métodos, variáveis) em **português**, para manter a linguagem do domínio (`Pedido`, `Mesa`, `Cliente`). Termos técnicos padrão ficam em inglês (`Controller`, `Repository`, `Hub`, `Dto`).
- Classes e métodos em PascalCase; variáveis locais em camelCase; campos privados `_camelCase`.
- DTOs de entrada terminam em `Request`, de saída em `Response`.
- Commits no padrão Conventional Commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`. Referencie a issue: `feat: cria endpoint de pedidos (#13)`.
- Uma branch por issue: `feat/13-endpoint-pedidos`.

## Regras de negócio obrigatórias
1. **Multi-tenant**: toda entidade de negócio tem `RestauranteId`. Use Global Query Filter do EF Core. Nunca escreva consulta que ignore o tenant sem justificar.
2. **Dinheiro**: `decimal` no C#, `numeric(10,2)` no banco.
3. **Preço congelado**: `ItemPedido.PrecoUnitario` é copiado do produto no momento do pedido.
4. **Privacidade (LGPD)**: telefone nunca volta completo em endpoints públicos (mascarar: `(12) 9****-6812`). Registrar data do consentimento.
5. **Anti-trote**: pedido exige token de mesa válido + sessão de mesa aberta + rate limit por cliente.
6. **Status do pedido**: `Recebido → EmPreparo → Pronto → Entregue` (ou `Cancelado`). Não permitir voltar status.

## Como trabalhar neste repositório
1. Leia a issue indicada (`gh issue view <N>`).
2. Apresente um plano antes de editar arquivos.
3. Implemente somente o escopo da issue.
4. Escreva/atualize testes e rode `dotnet test`.
5. Ao final, liste os critérios de aceite atendidos e sugira a mensagem de commit.
6. Não altere `docs/` sem eu pedir, exceto para corrigir algo que ficou desatualizado pela issue (avise).
