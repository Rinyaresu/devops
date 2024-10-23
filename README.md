# DevOps Learning Project

Projeto prático para aprendizado de conceitos DevOps usando uma aplicação web simples como base.

## Objetivos

- [x] **Docker** - Containerização da aplicação
- [ ] **Load Balancer** - Distribuição de carga
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
