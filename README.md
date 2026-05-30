# Sistema de Reservas de Hotel

Backend PHP + PostgreSQL com boas práticas de segurança, transações e arquitetura em camadas.

## Stack

- **PHP 8.3** + PDO + PostgreSQL 16
- **JWT** (autenticação sem dependências externas)
- **Docker** + Docker Compose + Nginx
- **PHPUnit 11** (testes automatizados)
- **Logs estruturados** em JSON

---

## Como Executar o Projeto (Docker)

O projeto foi totalmente automatizado utilizando Docker e Docker Compose. Não é necessário instalar o PHP, Composer ou PostgreSQL localmente na sua máquina.

### Pré-requisitos

- Ter o **Docker** e o **Docker Compose** instalados.

### Passo a Passo

1. **Clonar o repositório:**

   ```bash
    git clone https://github.com/seu-usuario/sistema-hotel.git

    cd sistema-hotel
   ```

2. **Iniciar a aplicação:**
   Execute o comando abaixo na raiz do projeto. Ele irá baixar as imagens, configurar o banco de dados automaticamente (executando o schema inicial) e instalar todas as dependências do Composer em segundo plano:

```bash
docker compose up -d --build
```

3. Pronto!
   A aplicação estará rodando e pronta para receber requisições em: `http://localhost:8081 `

---

## Testando a API

Para validar o funcionamento do sistema e a criação automatizada do banco de dados, você pode disparar uma requisição de teste para criar um usuário.

**No Linux / Mac / WSL:** (No seu windows basicamente seria o git bash ou wsl)

```bash
curl -X POST http://localhost:8081/auth/registrar \
     -H "Content-Type: application/json" \
     -d '{"nome":"Joao Silva","email":"joao@email.com","senha":"senha123"}'
```

**No Windows (PowerShell):** (Não recomendo, funciona pra testar aqui, mas no dia a dia ninguém usa. muito ruim)

```powershell
Invoke-RestMethod -Uri "http://localhost:8081/auth/registrar" -Method Post -ContentType "application/json" -Body '{"nome":"Joao Carlos","email":"joaocarlos@email.com","senha":"senha123"}'
```

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
curl -X POST http://localhost:8081/auth/registrar \
  -H "Content-Type: application/json" \
  -d "{\"nome\":\"Joao Silva\",\"email\":\"joao@email.com\",\"senha\":\"senha123\"}"
```

### Login

```bash
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"joao@email.com\",\"senha\":\"senha123\"}"
```

### Criar reserva

```bash
curl -X POST http://localhost:8081/reservas \
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
