# PRD — QRMesa (Documento de Requisitos do Produto)

## 1. Visão
Permitir que clientes de restaurantes façam pedidos pelo celular, escaneando um QR Code na mesa, sem instalar aplicativo, e que o pedido chegue imediatamente à cozinha, reduzindo erros de comanda e tempo de atendimento.

## 2. Público
| Persona | Necessidade |
|---|---|
| **Cliente** | Pedir rápido, ver preço e foto, acompanhar o pedido, chamar o garçom |
| **Cozinha** | Receber pedidos legíveis (tela + impressão), marcar como pronto |
| **Garçom/Caixa** | Ver chamados, fechar conta da mesa |
| **Dono/Gerente** | Editar cardápio, ver relatórios, conhecer seus clientes |

## 3. Fluxo principal (cliente)
1. Cliente escaneia o QR da mesa → abre `https://app/m/{tokenDaMesa}`.
2. Tela de identificação: **WhatsApp** (com máscara).
   - Se já cadastrado no restaurante → "Bem-vindo de volta, {nome}!" → entra.
   - Se novo → pede **nome** + aceite da política de privacidade → cadastra e entra.
3. Cardápio: cabeçalho com nome do restaurante, mesa e espera média; busca; categorias em abas; itens com foto, descrição e preço.
4. Adiciona itens ao carrinho (quantidade e observação opcional, se o restaurante permitir).
5. Confirma pedido → pedido vai para a cozinha (KDS + impressora).
6. Acompanha status em tempo real: Recebido → Em preparo → Pronto.
7. Menu **Serviços**: Chamar garçom, Pedir a conta / Pagar no caixa, Avaliar atendimento.
8. **Últimos pedidos**: histórico e "pedir de novo".

## 4. Requisitos funcionais
### Cliente
- RF01 Identificação por WhatsApp + nome, sem senha.
- RF02 Cardápio por categorias, com busca e itens esgotados ocultos ou marcados.
- RF03 Carrinho persistido no navegador durante a sessão.
- RF04 Envio de pedido vinculado à mesa e à sessão de mesa.
- RF05 Status do pedido em tempo real.
- RF06 Chamar garçom.
- RF07 Solicitar conta / pagar no caixa.
- RF08 Avaliar atendimento (1–5 estrelas + comentário); nota 5 sugere avaliação no Google.
- RF09 Histórico de pedidos do cliente naquele restaurante.

### Cozinha / Equipe
- RF10 Painel KDS com pedidos em colunas por status, com alerta sonoro de novo pedido.
- RF11 Impressão automática do pedido na impressora térmica.
- RF12 Reimpressão manual de um pedido.
- RF13 Lista de chamados de garçom com botão "atendido".
- RF14 Abrir/fechar sessão de mesa.

### Dono / Gerente
- RF15 CRUD de categorias e produtos (com foto, preço, ordem, ativo/esgotado).
- RF16 CRUD de mesas e geração de QR Codes para impressão (PDF).
- RF17 Gestão de usuários da equipe com papéis (Dono, Gerente, Cozinha, Garçom, Caixa).
- RF18 Configurações do restaurante (logo, cores, permite observação, espera média, link do Google).
- RF19 Relatórios: vendas por dia, itens mais vendidos, ticket médio, clientes recorrentes.

## 5. Requisitos não funcionais
- RNF01 **Mobile-first**: cardápio carrega em menos de 2 s em 4G.
- RNF02 **Multi-tenant**: dados de um restaurante nunca aparecem para outro.
- RNF03 **LGPD**: consentimento registrado, política de privacidade, exclusão de dados a pedido.
- RNF04 **Segurança**: HTTPS, JWT para equipe, rate limit em endpoints públicos, token de mesa não sequencial.
- RNF05 **Disponibilidade da impressão**: se o agente cair, pedidos ficam na fila e são impressos quando ele voltar.
- RNF06 **Qualidade**: CI com build e testes a cada push.

## 6. Fora do escopo da v1.0
- Delivery e retirada
- Integração com iFood
- Emissão de nota fiscal (NFC-e)
- App nativo

## 7. Métricas de sucesso do piloto
- % de pedidos feitos pelo QR (vs. garçom)
- Tempo médio entre pedido e "pronto"
- Nº de clientes cadastrados e taxa de retorno
- Nota média de avaliação
