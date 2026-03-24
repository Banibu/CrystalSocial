# CrystalSocial - Docker & Vercel Setup Guide

Este projeto é totalmente híbrido e pode ser executado tanto na **Vercel** (como estava originalmente) quanto em uma **VPS com Docker**.

## Índice
- [Execução com Docker (VPS)](#execução-com-docker-vps)
- [Execução na Vercel](#execução-na-vercel)
- [Desenvolvimento Local](#desenvolvimento-local)

---

## Execução com Docker (VPS)

### Pré-requisitos
- Docker e Docker Compose instalados na VPS
- Acesso SSH à VPS
- Domínio (opcional, mas recomendado)

### Passo 1: Clonar o repositório

```bash
git clone https://github.com/Banibu/CrystalSocial.git
cd CrystalSocial
```

### Passo 2: Configurar variáveis de ambiente

Copie o arquivo de exemplo e configure as variáveis:

```bash
cp .env.docker .env.local
```

Edite o arquivo `.env.local` com suas configurações:

```bash
nano .env.local
```

**Variáveis importantes:**

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `POSTGRES_PASSWORD` | Senha do PostgreSQL | `minha_senha_segura_123` |
| `AUTH_SECRET` | Chave de autenticação (mín. 32 caracteres) | `seu_secret_aqui_com_32_caracteres_ou_mais` |
| `NEXT_PUBLIC_BASE_URL` | URL da aplicação | `https://seu-dominio.com` |
| `GOOGLE_CLIENT_ID` | ID do Google OAuth (opcional) | `seu_google_id.apps.googleusercontent.com` |
| `GOOGLE_CLIENT_SECRET` | Secret do Google OAuth (opcional) | `seu_google_secret` |
| `UPLOADTHING_SECRET` | Secret do Uploadthing (opcional) | `seu_uploadthing_secret` |
| `NEXT_PUBLIC_UPLOADTHING_APP_ID` | App ID do Uploadthing (opcional) | `seu_app_id` |

### Passo 3: Iniciar os containers

```bash
docker-compose up -d --build
```

Este comando irá:
- ✅ Construir a imagem Docker da aplicação
- ✅ Criar um container PostgreSQL
- ✅ Criar um container da aplicação Next.js
- ✅ Executar automaticamente as migrações do Prisma
- ✅ Iniciar a aplicação

### Passo 4: Verificar o status

```bash
docker-compose ps
```

Você deve ver dois containers rodando:
- `crystal_db` (PostgreSQL)
- `crystal_app` (Next.js)

### Passo 5: Acessar a aplicação

A aplicação estará disponível em:
- **Localmente**: `http://localhost:3000`
- **Remotamente**: `https://seu-dominio.com` (se configurado com Nginx/Traefik)

### Comandos úteis

```bash
# Ver logs da aplicação
docker-compose logs -f app

# Ver logs do banco de dados
docker-compose logs -f db

# Parar os containers
docker-compose down

# Remover tudo (incluindo dados)
docker-compose down -v

# Reiniciar
docker-compose restart

# Executar comando no container
docker-compose exec app npx prisma studio
```

### Configurar Nginx como Reverse Proxy (Opcional)

Se você quer usar um domínio customizado com SSL:

```nginx
server {
    listen 80;
    server_name seu-dominio.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name seu-dominio.com;

    ssl_certificate /etc/letsencrypt/live/seu-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/seu-dominio.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Execução na Vercel

O projeto continua totalmente compatível com a Vercel. Nenhuma mudança foi feita que quebre a compatibilidade.

### Passo 1: Conectar repositório

1. Acesse [vercel.com](https://vercel.com)
2. Clique em "New Project"
3. Selecione seu repositório GitHub

### Passo 2: Configurar variáveis de ambiente

Na dashboard da Vercel, vá para **Settings → Environment Variables** e adicione:

```
POSTGRES_PRISMA_URL=postgresql://...
POSTGRES_URL_NON_POOLING=postgresql://...
AUTH_SECRET=seu_secret_aqui
GOOGLE_CLIENT_ID=seu_google_id
GOOGLE_CLIENT_SECRET=seu_google_secret
UPLOADTHING_SECRET=seu_uploadthing_secret
NEXT_PUBLIC_UPLOADTHING_APP_ID=seu_app_id
NEXT_PUBLIC_STREAM_KEY=sua_stream_key
STREAM_SECRET=seu_stream_secret
```

### Passo 3: Deploy

Clique em "Deploy" e a Vercel fará o resto automaticamente.

---

## Desenvolvimento Local

Para desenvolvimento local **sem Docker**:

```bash
# Instalar dependências
npm install --legacy-peer-deps

# Configurar banco de dados local (você precisa ter PostgreSQL instalado)
# Edite o .env.local com suas credenciais locais

# Rodar migrações
npx prisma db push

# Iniciar servidor de desenvolvimento
npm run dev
```

Acesse `http://localhost:3000`

---

## Troubleshooting

### Erro: "Database connection refused"
- Verifique se o container do PostgreSQL está rodando: `docker-compose ps`
- Verifique os logs: `docker-compose logs db`

### Erro: "Prisma migration failed"
- Verifique se as variáveis de ambiente estão corretas
- Tente resetar o banco: `docker-compose down -v && docker-compose up -d --build`

### Porta 3000 já está em uso
- Mude a porta no `docker-compose.yml`: altere `"3000:3000"` para `"3001:3000"`

### Aplicação lenta no Docker
- Verifique recursos da VPS: `docker stats`
- Aumente a memória alocada se necessário

---

## Segurança

### Recomendações para Produção

1. **Mude as senhas padrão** no `.env.local`
2. **Use um AUTH_SECRET forte** (mínimo 32 caracteres aleatórios)
3. **Configure HTTPS** com Let's Encrypt
4. **Restrinja acesso ao PostgreSQL** (não exponha a porta 5432)
5. **Use variáveis de ambiente seguras** (não commite `.env.local`)
6. **Faça backup regular** do volume `postgres_data`

### Backup do Banco de Dados

```bash
# Fazer backup
docker-compose exec db pg_dump -U postgres crystal_social > backup.sql

# Restaurar backup
docker-compose exec -T db psql -U postgres crystal_social < backup.sql
```

---

## Estrutura do Projeto

```
CrystalSocial/
├── Dockerfile              # Configuração Docker para Next.js
├── docker-compose.yml      # Orquestração de containers
├── docker-entrypoint.sh    # Script de inicialização
├── .env.docker             # Exemplo de variáveis para Docker
├── .dockerignore            # Arquivos ignorados no build
├── DOCKER_SETUP.md         # Este arquivo
├── src/
│   ├── app/                # Rotas Next.js
│   ├── components/         # Componentes React
│   └── lib/                # Utilitários
├── prisma/
│   └── schema.prisma       # Schema do banco de dados
└── package.json            # Dependências
```

---

## Suporte

Se encontrar problemas, verifique:
1. Os logs: `docker-compose logs`
2. O status dos containers: `docker-compose ps`
3. A conectividade do banco: `docker-compose exec app npx prisma db execute --stdin < /dev/null`

---

**Última atualização**: Março 2026
