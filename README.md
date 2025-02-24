# DevOps Learning Project

Projeto prático para aprendizado de conceitos DevOps usando uma aplicação web simples como base.

## Objetivos

- [x] **Docker** - Containerização da aplicação
- [x] **Load Balancer** - Distribuição de carga
- [ ] **Caching Server** - Cache para performance
- [ ] **Forward Proxy** - Proxy para requisições
- [ ] **Firewall** - Regras de segurança
- [ ] **Reverse Proxy** - Proxy reverso

## Como Executar

```bash
docker compose up --build
```

Acesse:

- Frontend: <http://localhost:5173>
- API: <http://localhost:4567>

## API Endpoints

- `GET /api/tasks` - Lista tasks
- `POST /api/tasks` - Cria task
- `PUT /api/tasks/:id` - Atualiza task
- `DELETE /api/tasks/:id` - Remove task

## Scripts de Teste

### Load Balancer Tester

O script `scripts/load_balancer_tester.rb` permite testar diferentes configurações do load balancer.

```bash
# Teste padrão (round-robin)
ruby scripts/load_balancer_tester.rb

# Testes com diferentes algoritmos
ruby scripts/load_balancer_tester.rb -a round-robin  # Round Robin (padrão)
ruby scripts/load_balancer_tester.rb -a least-conn   # Least Connections
ruby scripts/load_balancer_tester.rb -a ip-hash      # IP Hash (sticky sessions)
ruby scripts/load_balancer_tester.rb -a weighted     # Weighted Round Robin

# Número específico de requisições
ruby scripts/load_balancer_tester.rb -r 50           # 50 requisições

# Teste com simulação de falhas
ruby scripts/load_balancer_tester.rb -f              # Simula falha em backend

# Teste completo
ruby scripts/load_balancer_tester.rb -a least-conn -r 50 -f  # Combina opções
```

Opções disponíveis:

- `-a, --algorithm ALGO`: Algoritmo de balanceamento
- `-r, --requests NUM`: Número de requisições
- `-f, --test-failures`: Simula falhas nos backends
- `-h, --help`: Mostra ajuda com todas as opções
