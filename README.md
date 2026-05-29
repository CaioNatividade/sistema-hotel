# Sistema de Reservas de Hotel

Backend PHP + PostgreSQL com boas práticas de segurança, transações e arquitetura em camadas.

## Stack

- **PHP 8.3** + PDO + PostgreSQL 16
- **JWT** (autenticação sem dependências externas)
- **Docker** + Docker Compose + Nginx
- **PHPUnit 11** (testes automatizados)
- **Logs estruturados** em JSON

---

## Início Rápido

### 1. Clonar e configurar ambiente

```bash
git clone <repositorio>
cd hotel-reservas
cp .env.example .env
# Edite .env com suas credenciais se desejar (o padrão já vem pronto para Docker)
```

### 2. Subir com Docker

```bash
# Sobe os containers do Banco de Dados, PHP e Nginx
docker compose up -d --build

# Instala as dependências do PHP (Obrigatório na primeira execução)
docker compose exec app composer install

# Cria a estrutura de tabelas e sementes no Banco de Dados
cat sql/01_schema.sql | docker compose exec -T db psql -U postgres -d hotel_reservas
```

A aplicação estará disponível em `http://localhost:8080`.

### 3. Sem Docker (desenvolvimento local)

```bash
composer install
# Configure .env com credenciais do PostgreSQL local
psql -U seu_usuario -d hotel_reservas -f sql/01_schema.sql
php -S localhost:8080 -t public
```

---

## Endpoints da API

### Autenticação

| Método | Rota              | Descrição                |
| ------ | ----------------- | ------------------------ |
| POST   | `/auth/registrar` | Criar conta              |
| POST   | `/auth/login`     | Autenticar (retorna JWT) |

### Quartos

| Método | Rota       | Descrição                                  |
| ------ | ---------- | ------------------------------------------ |
| GET    | `/quartos` | Listar quartos (com `?checkin=&checkout=`) |

### Reservas (requer JWT)

| Método | Rota             | Descrição              |
| ------ | ---------------- | ---------------------- |
| GET    | `/reservas`      | Listar minhas reservas |
| POST   | `/reservas`      | Criar reserva          |
| GET    | `/reservas/{id}` | Detalhe da reserva     |
| DELETE | `/reservas/{id}` | Cancelar reserva       |

---

## Exemplos de uso

### Registrar usuário

```bash
curl -X POST http://localhost:8080/auth/registrar \
  -H "Content-Type: application/json" \
  -d "{\"nome\":\"Joao Silva\",\"email\":\"joao@email.com\",\"senha\":\"senha123\"}"
```

### Login

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"joao@email.com\",\"senha\":\"senha123\"}"
```

### Criar reserva

```bash
curl -X POST http://localhost:8080/reservas \
  -H "Authorization: Bearer SEU_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"quarto_id\": 1,
    \"data_checkin\": \"2025-08-10\",
    \"data_checkout\": \"2025-08-15\",
    \"num_hospedes\": 2,
    \"metodo_pagamento\": \"pix\"
  }"
```

---

## Testes

```bash
composer test
```

---

## Estrutura do Projeto

```
hotel-reservas/
├── docker/           # Configuração Nginx
├── logs/             # Logs JSON (gerados em runtime)
├── public/           # Front controller (index.php)
├── sql/              # Scripts DDL e seed
├── src/
│   ├── config/       # Database (PDO singleton) + Logger
│   ├── controllers/  # Camada HTTP
│   ├── middleware/   # JWT
│   └── models/       # Lógica de negócio + SQL
├── tests/            # PHPUnit
├── Dockerfile
├── composer.json
└── docker-compose.yml
```

---

## Decisões Técnicas

| Requisito                   | Solução                                              |
| --------------------------- | ---------------------------------------------------- |
| SQL Injection               | PDO + Prepared Statements em todo SQL                |
| Senhas                      | `password_hash()` bcrypt cost=12                     |
| Credenciais                 | 100% via `getenv()`, sem hardcode                    |
| Transações                  | `beginTransaction/commit/rollBack` em ReservaModel   |
| Disponibilidade concorrente | `SELECT ... FOR UPDATE SKIP LOCKED`                  |
| Erros ao usuário            | Mensagens genéricas; detalhes vão apenas ao log      |
| Logs                        | JSON estruturado com sanitização de campos sensíveis |
