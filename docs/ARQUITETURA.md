# Arquitetura — QRMesa

## 1. Visão geral
```
┌──────────────┐   HTTPS (REST)   ┌──────────────────────┐      ┌────────────┐
│ Cliente      │ ───────────────▶ │ QRMesa.Api           │ ───▶ │ PostgreSQL │
│ (Next.js)    │ ◀── SignalR ──── │ ASP.NET Core + EF    │      └────────────┘
└──────────────┘                  │ Hubs SignalR         │
┌──────────────┐                  │                      │
│ Painel admin │ ◀── SignalR ──── │                      │
│ KDS / Caixa  │ ───── REST ────▶ │                      │
└──────────────┘                  └──────────┬───────────┘
                                             │ SignalR (saída 443)
                                  ┌──────────▼───────────┐     TCP 9100 / USB
                                  │ QRMesa.PrintAgent    │ ──────────────────▶ 🖨️
                                  │ (PC da cozinha)      │      ESC/POS
                                  └──────────────────────┘
```

## 2. Decisões técnicas (ADRs resumidos)

### ADR-01 — Backend em ASP.NET Core
- **Motivo:** domínio de C# pelo desenvolvedor, desempenho, SignalR nativo, mercado brasileiro forte em .NET.
- **Alternativa descartada:** Node.js (seria uma linguagem a mais para aprender junto).

### ADR-02 — Banco PostgreSQL com multi-tenant por coluna
- Um único banco, todas as tabelas de negócio com `RestauranteId`.
- Isolamento garantido por **Global Query Filter** do EF Core, lendo o tenant do usuário logado (equipe) ou do token da mesa (cliente).
- **Por quê:** simples e barato. Banco por cliente só faz sentido com muitos clientes grandes.

### ADR-03 — Tempo real com SignalR
- Grupos SignalR: `restaurante:{id}:cozinha`, `restaurante:{id}:garcons`, `pedido:{id}` (cliente acompanhando).
- Eventos: `NovoPedido`, `StatusPedidoAlterado`, `NovoChamado`, `ImprimirPedido`.

### ADR-04 — Impressão por agente local
- Navegadores não imprimem silenciosamente, por isso existe um **Worker Service** no PC da cozinha.
- O agente **inicia a conexão** com a API (saída pela porta 443). Assim não é preciso abrir porta no roteador do restaurante.
- O agente se autentica com uma **chave de dispositivo** gerada no painel.
- Envia comandos ESC/POS por **TCP porta 9100** (impressora de rede) ou USB.
- Fila de impressão no banco (`StatusImpressao`): se o agente estiver offline, imprime ao reconectar. Após imprimir, confirma (`ack`) para a API.

### ADR-05 — Frontend único em Next.js
- Rotas do cliente: `/m/[token]` (cardápio), `/m/[token]/carrinho`, `/m/[token]/pedidos`.
- Rotas da equipe: `/admin/*` (login JWT), `/admin/kds`, `/admin/cardapio`, `/admin/mesas`.

### ADR-06 — Identificação do cliente sem senha
- Cliente identificado por telefone + restaurante. Na API pública, o telefone é mascarado.
- Fase futura: OTP por WhatsApp para proteger o histórico.

## 3. Segurança
| Ameaça | Mitigação |
|---|---|
| Pedido de fora do restaurante | Token de mesa aleatório (não sequencial) + sessão de mesa aberta pela equipe ou com expiração |
| Spam de pedidos | Rate limiting (`Microsoft.AspNetCore.RateLimiting`) por IP e por cliente |
| Ver dados de outro restaurante | Global Query Filter + testes automatizados de isolamento |
| Vazamento de telefone | Mascaramento nos DTOs de resposta |
| Acesso indevido ao painel | JWT + papéis (`[Authorize(Roles = ...)]`) |

## 4. Ambientes
| Ambiente | Frontend | API + Banco |
|---|---|---|
| Local | `npm run dev` | `dotnet run` + Docker Compose |
| Produção | Vercel | Railway / Render / Fly.io + PostgreSQL gerenciado |
