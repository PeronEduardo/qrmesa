# Roadmap — QRMesa

Cada linha é uma issue no GitHub (criadas pelo script `scripts/criar-issues.sh`). Faça na ordem: os números já respeitam as dependências.

## Fase 0 — Setup
| # | Issue | Labels |
|---|---|---|
| 1 | Criar solução .NET com projetos Api, Domain, Infrastructure, PrintAgent e Tests | setup, backend |
| 2 | Docker Compose com PostgreSQL | setup, infra |
| 3 | Criar projeto Next.js com TypeScript e Tailwind | setup, frontend |
| 4 | CI com GitHub Actions (build + testes) | setup, infra |
| 5 | README inicial com descrição, stack e como rodar | docs |

## MVP 1 — Pedido de ponta a ponta
| # | Issue | Labels |
|---|---|---|
| 6 | Entidades e migration inicial (Restaurante, Mesa, Categoria, Produto, Cliente, SessaoMesa, Pedido, ItemPedido) | backend, banco |
| 7 | Seed com restaurante e cardápio de exemplo | backend, banco |
| 8 | GET /api/mesas/{token}/cardapio | backend |
| 9 | POST /api/mesas/{token}/identificar (cliente por WhatsApp) | backend |
| 10 | Tela de identificação (WhatsApp + nome + LGPD) | frontend |
| 11 | Tela do cardápio com categorias e busca | frontend |
| 12 | Carrinho | frontend |
| 13 | POST /api/pedidos | backend |
| 14 | Hub SignalR: notificar cozinha de novo pedido | backend, tempo-real |
| 15 | Painel da cozinha (KDS) com mudança de status | frontend, tempo-real |
| 16 | Status do pedido em tempo real para o cliente | frontend, tempo-real |

## MVP 2 — Impressão e serviços
| # | Issue | Labels |
|---|---|---|
| 17 | PrintAgent: conexão SignalR autenticada por chave de dispositivo | impressao |
| 18 | PrintAgent: formatação ESC/POS do pedido | impressao |
| 19 | Fila de impressão com confirmação e reimpressão | impressao, backend |
| 20 | Chamar garçom | backend, frontend |
| 21 | Pedir a conta / Pagar no caixa | backend, frontend |
| 22 | Histórico de pedidos do cliente e "pedir de novo" | backend, frontend |
| 23 | Avaliação do atendimento com redirecionamento ao Google | backend, frontend |

## MVP 3 — Multi-restaurante e painel do dono
| # | Issue | Labels |
|---|---|---|
| 24 | Login da equipe (Identity + JWT + papéis) | backend, seguranca |
| 25 | Isolamento multi-tenant com Global Query Filter + testes | backend, seguranca |
| 26 | CRUD de categorias e produtos com upload de imagem | backend, frontend |
| 27 | Gestão de mesas e geração de QR Codes em PDF | backend, frontend |
| 28 | Sessão de mesa (abrir/fechar) + rate limit anti-trote | backend, seguranca |
| 29 | Botão "Esgotado" em tempo real | backend, frontend |

## v1.0 — Pronto para vender
| # | Issue | Labels |
|---|---|---|
| 30 | Conta da mesa com divisão por cliente | backend, frontend |
| 31 | Relatórios básicos | backend, frontend |
| 32 | Testes E2E com Playwright | testes |
| 33 | Política de privacidade e exclusão de dados (LGPD) | seguranca, docs |
| 34 | Deploy (Vercel + Railway) com domínio | infra |
| 35 | Piloto em restaurante real | negocio |

## Backlog (depois da v1.0)
- Pagamento via Pix (Mercado Pago / Asaas / Efí)
- OTP por WhatsApp
- Campanhas de retorno por WhatsApp
- Personalização visual por restaurante (cores e logo)
- Modo offline do KDS
