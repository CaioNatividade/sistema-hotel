
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

1. Clonar o repositório:
   ``` bash
   git clone https://github.com/CaioNatividade/sistema-hotel.git
   cd sistema-hotel
   ```

3. Iniciar a aplicação:
   Execute o comando abaixo na raiz do projeto. Ele irá baixar as imagens, configurar o banco de dados automaticamente (executando o schema inicial) e instalar todas as dependências do Composer em segundo plano:
   ```bash
   docker compose up -d --build
   ```

4. Pronto!
   A aplicação estará rodando e pronta para receber requisições em: http://localhost:8081

---

## Testando a API

Para validar o funcionamento do sistema e a criação automatizada do banco de dados, escolha o comando adequado para o seu terminal para disparar uma requisição de teste (criação de conta):

#### Linux / macOS / WSL / Git Bash
```bash
curl -X POST http://localhost:8081/auth/registrar -H "Content-Type: application/json" -d '{"nome":"Joao Silva","email":"joao@email.com","senha":"senha123"}'
```

#### Windows (PowerShell Nativo)
```bash
Invoke-RestMethod -Uri "http://localhost:8081/auth/registrar" -Method Post -ContentType "application/json" -Body '{"nome":"Joao Carlos","email":"joaocarlos@email.com","senha":"senha123"}'
```

---

## Endpoints da API

### Autenticação

| Método | Rota             | Descrição                |
| ------ | ---------------- | ------------------------ |
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
| GET    | `/reservas/{id}` | Detalhes da reserva    |
| DELETE | `/reservas/{id}` | Cancelar reserva       |

---

## Exemplos de Uso (Ambientes Unix / Git Bash)

Nota para usuários de Windows: Caso utilize o PowerShell, adapte os corpos (-Body) e cabeçalhos utilizando a sintaxe do Invoke-RestMethod demonstrada na seção de testes.

### 1. Login
```bash
curl -X POST http://localhost:8081/auth/login -H "Content-Type: application/json" -d '{"email":"joao@email.com","senha":"senha123"}'
```

### 2. Criar Reserva (Requer Token JWT)
```bash
curl -X POST http://localhost:8081/reservas -H "Authorization: Bearer SEU_TOKEN_AQUI" -H "Content-Type: application/json" -d '{"quarto_id": 1, "data_checkin": "2026-08-10", "data_checkout": "2026-08-15", "num_hospedes": 2, "metodo_pagamento": "pix"}'
```

---

## Executando os Testes Automatizados

Para rodar a suíte de testes do PHPUnit dentro do ambiente containerizado, execute:
```bash
composer test
```
---

## Estrutura do Projeto
```
hotel-reservas/
├── docker/           # Configurações do ambiente (Nginx / PHP)
├── logs/             # Logs estruturados em JSON (gerados em runtime)
├── public/           # Front Controller (index.php - ponto de entrada)
├── sql/              # Scripts DDL de estrutura e seeds iniciais
├── src/
│   ├── config/       # Conexão com Banco (PDO Singleton) e Logger
│   ├── controllers/  # Camada HTTP e manipulação de Requests/Responses
│   ├── middleware/   # Interceptadores (Validação de Token JWT)
│   └── models/       # Entidades, Lógica de Negócio e persistência SQL
├── tests/            # Testes automatizados com PHPUnit
├── Dockerfile
├── composer.json
└── docker-compose.yml
```

---

## Decisões Técnicas e Segurança

| Requisito | Solução Aplicada |
| :--- | :--- |
| **SQL Injection** | Utilização rigorosa de PDO + Prepared Statements em todas as consultas. |
| **Criptografia de Senhas** | Uso da função nativa `password_hash()` com algoritmo bcrypt e custo operacional (cost=12). |
| **Variáveis de Ambiente** | Credenciais sensíveis gerenciadas 100% via `getenv()`, sem valores estáticos no código. |
| **Transações** | Controle estrito com `beginTransaction`, `commit` e `rollBack` na camada de modelo de reservas. |
| **Concorrência e Race Conditions** | Implementação de bloqueio pessimista utilizando `SELECT ... FOR UPDATE SKIP LOCKED` para evitar dupla reserva do mesmo quarto. |
| **Exposição de Erros** | Mensagens genéricas e seguras para o cliente final; detalhes técnicos e exceções são direcionados exclusivamente aos logs. |
| **Auditoria e Logs** | Geração de logs estruturados em formato JSON com sanitização automática de dados sensíveis (como senhas). |

