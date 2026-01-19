# Truck Signs API - Deployment

This repository contains the **containerized deployment** for the Truck Signs API, a Django-based REST API for truck signage management. The setup uses Docker to orchestrate a production-ready environment with PostgreSQL database, Stripe payment integration, and email functionality.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quickstart](#quickstart)
3. [Usage](#usage)
   - [Environment Configuration](#environment-configuration)
   - [Building and Running](#building-and-running)
   - [Accessing the Application](#accessing-the-application)
   - [Managing Containers](#managing-containers)
   - [Working with Logs](#working-with-logs)
4. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- **Docker**: Version 20.10 or higher
- **Git**: For repository management
- **Stripe Account**: For payment integration (test keys for development)
- **Gmail Account**: With app password for email functionality

Verify Docker installation:
```bash
docker --version
docker images
docker ps
```

---

## Quickstart

### 1. Clone the repository
```bash
git clone -b feature/api-containerization git@github.com:Ozinho78/truck_signs_api.git
cd truck_signs_api
```

### 2. Create environment file
```bash
# Windows
copy env.template .env

# Linux/macOS
cp env.template .env
```

### 3. Configure environment variables
Edit `.env` and set **required** values:

**Database Configuration:**
```bash
POSTGRES_HOST=truck-signs-db
POSTGRES_PORT=5432
POSTGRES_DB=truck_signs_db
POSTGRES_USER=truck_signs_user
POSTGRES_PASSWORD=your_secure_password_here
```

**Django Configuration:**
```bash
DJANGO_ENV=production
DOCKER_SECRET_KEY=your_generated_secret_key_here
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1,YOUR_SERVER_IP
```

**Stripe Configuration:**
```bash
DOCKER_STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key
DOCKER_STRIPE_SECRET_KEY=sk_test_your_secret_key
```

**Email Configuration:**
```bash
DOCKER_EMAIL_HOST_USER=your-email@gmail.com
DOCKER_EMAIL_HOST_PASSWORD=your_app_password
```

**Generate Django Secret Key:**
```bash
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

### 4. Build Docker image
```bash
docker build -t truck-signs-api:latest .
```

### 5. Create Docker network
```bash
docker network create truck-signs-network
```

### 6. Start PostgreSQL database
```bash
docker run -d \
    --name truck-signs-db \
    --network truck-signs-network \
    -e POSTGRES_DB=truck_signs_db \
    -e POSTGRES_USER=truck_signs_user \
    -e POSTGRES_PASSWORD=secure_password_123 \
    -v truck-signs-data:/var/lib/postgresql/data \
    postgres:15-alpine
```

**Wait for database initialization (5 seconds recommended):**
```bash
# Windows
timeout /t 5 /nobreak

# Linux/macOS
sleep 5
```

### 7. Start Django API
```bash
docker run -d \
    --name truck-signs-api \
    --network truck-signs-network \
    -p 8020:8000 \
    --env-file .env \
    truck-signs-api:latest
```

### 8. Verify deployment
```bash
docker ps --filter "name=truck-signs"
```

Expected output:
```
CONTAINER ID   IMAGE                    STATUS         PORTS                    NAMES
abc123def456   truck-signs-api:latest   Up 10 seconds  0.0.0.0:8020->8000/tcp  truck-signs-api
def456ghi789   postgres:15-alpine       Up 15 seconds  5432/tcp                 truck-signs-db
```

### 9. Access application
- **API**: `http://localhost:8020`
- **Admin Panel**: `http://localhost:8020/admin`
- **API Documentation**: `http://localhost:8020/api/`

---

## Usage

### Environment Configuration

The `.env` file contains all configuration for the deployment. This file is **not** stored in Git for security reasons.

**Create from template:**
```bash
# Windows
copy .env.example .env
notepad .env

# Linux/macOS
cp .env.example .env
nano .env
```

**Critical settings to modify:**

#### 1. Database Configuration (REQUIRED)
```bash
POSTGRES_HOST=truck-signs-db          # Container name
POSTGRES_PORT=5432                     # Default PostgreSQL port
POSTGRES_DB=truck_signs_db            # Database name
POSTGRES_USER=truck_signs_user        # Database user
POSTGRES_PASSWORD=use_strong_password # CHANGE THIS!
```

> [!WARNING]
> Never use default passwords in production!

#### 2. Django Secret Key (REQUIRED)
Generate using Python:
```bash
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```
Then set in `.env`:
```bash
DOCKER_SECRET_KEY=your_generated_secret_key_here
```

#### 3. Django Settings (REQUIRED for production)
```bash
DJANGO_ENV=production                           # or 'development'
DEBUG=False                                     # NEVER True in production!
ALLOWED_HOSTS=localhost,127.0.0.1,YOUR_SERVER_IP
```

#### 4. Stripe Integration (REQUIRED)
Get your keys from [Stripe Dashboard](https://dashboard.stripe.com/test/apikeys):
```bash
DOCKER_STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx
DOCKER_STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
```

> [!TIP]
> Use test keys (`pk_test_` and `sk_test_`) for development

#### 5. Email Configuration (REQUIRED)
For Gmail, create an [App Password](https://myaccount.google.com/apppasswords):
```bash
DOCKER_EMAIL_HOST_USER=your-email@gmail.com
DOCKER_EMAIL_HOST_PASSWORD=your_16_char_app_password
```

**Optional settings:**
- `DOCKER_DB_HOST`: Alternative database host (overrides POSTGRES_HOST)
- `DOCKER_DB_PORT`: Alternative database port (overrides POSTGRES_PORT)
- `DOCKER_DB_NAME`: Alternative database name (overrides POSTGRES_DB)
- `DOCKER_DB_USER`: Alternative database user (overrides POSTGRES_USER)
- `DOCKER_DB_PASSWORD`: Alternative database password (overrides POSTGRES_PASSWORD)

### Building and Running

#### Complete Deployment Process

**1. Stop and remove old containers (if they exist):**
```bash
docker stop truck-signs-api truck-signs-db
docker rm truck-signs-api truck-signs-db
```

**2. Build the Docker image:**
```bash
docker build -t truck-signs-api:latest .
```

**3. Create network (if not exists):**
```bash
docker network create truck-signs-network
```

**4. Start PostgreSQL:**
```bash
docker run -d \
    --name truck-signs-db \
    --network truck-signs-network \
    -e POSTGRES_DB=truck_signs_db \
    -e POSTGRES_USER=truck_signs_user \
    -e POSTGRES_PASSWORD=secure_password_123 \
    -v truck-signs-data:/var/lib/postgresql/data \
    postgres:15-alpine
```

**5. Wait for database (5 seconds):**
```bash
# Windows
timeout /t 5 /nobreak

# Linux/macOS
sleep 5
```

**6. Start Django API:**
```bash
docker run -d \
    --name truck-signs-api \
    --network truck-signs-network \
    -p 8000:8000 \
    --env-file .env \
    truck-signs-api:latest
```

**7. Verify containers are running:**
```bash
docker ps --filter "name=truck-signs"
```

#### Rebuild After Code Changes

```bash
# Stop containers
docker stop truck-signs-api
docker rm truck-signs-api

# Rebuild image
docker build -t truck-signs-api:latest .

# Restart API container
docker run -d \
    --name truck-signs-api \
    --network truck-signs-network \
    -p 8000:8000 \
    --env-file .env \
    truck-signs-api:latest
```

### Accessing the Application

Once containers are running, access the application at:

| Service | URL | Description |
|---------|-----|-------------|
| API Root | `http://localhost:8000` | Main API endpoint |
| Admin Panel | `http://localhost:8000/admin` | Django administration |
| API Docs | `http://localhost:8000/api/` | API documentation |
| Swagger UI | `http://localhost:8000/swagger/` | Interactive API docs (if enabled) |

**Create superuser for admin access:**
```bash
docker exec -it truck-signs-api python manage.py createsuperuser
```

Follow the prompts to create username, email, and password.

**Run Django management commands:**
```bash
# Make migrations
docker exec -it truck-signs-api python manage.py makemigrations

# Apply migrations
docker exec -it truck-signs-api python manage.py migrate

# Collect static files
docker exec -it truck-signs-api python manage.py collectstatic --noinput

# Create superuser
docker exec -it truck-signs-api python manage.py createsuperuser

# Open Django shell
docker exec -it truck-signs-api python manage.py shell
```

### Managing Containers

**View running containers:**
```bash
docker ps --filter "name=truck-signs"
```

**Stop containers:**
```bash
docker stop truck-signs-api truck-signs-db
```

**Start stopped containers:**
```bash
docker start truck-signs-db
docker start truck-signs-api
```

**Restart containers:**
```bash
docker restart truck-signs-api
docker restart truck-signs-db
```

**Remove containers (keeps data volumes):**
```bash
docker stop truck-signs-api truck-signs-db
docker rm truck-signs-api truck-signs-db
```

**Remove everything including data:**
> [!WARNING]
> This deletes all database data permanently!

```bash
# Stop and remove containers
docker stop truck-signs-api truck-signs-db
docker rm truck-signs-api truck-signs-db

# Remove network
docker network rm truck-signs-network

# Remove volume (DATABASE DATA WILL BE LOST!)
docker volume rm truck-signs-data

# Remove image
docker rmi truck-signs-api:latest
```

**View Docker resources:**
```bash
# Images
docker images | findstr truck-signs

# Volumes
docker volume ls | findstr truck-signs

# Networks
docker network ls | findstr truck-signs
```

### Working with Logs

**View API logs:**
```bash
docker logs truck-signs-api
```

**Follow API logs in real-time:**
```bash
docker logs -f truck-signs-api
```

**View last N lines:**
```bash
docker logs --tail 50 truck-signs-api
```

**View database logs:**
```bash
docker logs truck-signs-db
docker logs -f truck-signs-db
```

**Save logs to file:**
```bash
# Windows
docker logs truck-signs-api > api-logs.txt
docker logs truck-signs-db > db-logs.txt

# Linux/macOS
docker logs truck-signs-api > api-logs.txt
docker logs truck-signs-db > db-logs.txt
```

**View logs with timestamps:**
```bash
docker logs --timestamps truck-signs-api
```

**Filter logs by time:**
```bash
# Last 10 minutes
docker logs --since 10m truck-signs-api

# Since specific time
docker logs --since 2024-01-01T10:00:00 truck-signs-api
```

---

## Troubleshooting

### Container won't start

**Check if image exists:**
```bash
docker images | findstr truck-signs-api
```

**Check container status:**
```bash
docker ps -a --filter "name=truck-signs"
```

**View startup logs:**
```bash
docker logs truck-signs-api
```

### Database connection errors

**Verify database is running:**
```bash
docker ps --filter "name=truck-signs-db"
```

**Check database logs:**
```bash
docker logs truck-signs-db
```

**Verify network connectivity:**
```bash
docker network inspect truck-signs-network
```

**Test database connection from API container:**
```bash
docker exec -it truck-signs-api psql -h truck-signs-db -U truck_signs_user -d truck_signs_db
```

### Port already in use

**Check what's using port 8000:**
```bash
# Windows
netstat -ano | findstr :8000

# Linux/macOS
lsof -i :8000
```

**Use different port:**
```bash
docker run -d \
    --name truck-signs-api \
    --network truck-signs-network \
    -p 8080:8000 \
    --env-file .env \
    truck-signs-api:latest
```

### Static files not loading

**Collect static files manually:**
```bash
docker exec -it truck-signs-api python manage.py collectstatic --noinput
```

**Verify WhiteNoise is configured:**
```bash
docker exec -it truck-signs-api python manage.py check --deploy
```

### Email not sending

**Verify Gmail app password:**
1. Go to Google Account → Security → 2-Step Verification → App passwords
2. Generate new app password
3. Update `.env` with new password
4. Restart container

**Test email in Django shell:**
```bash
docker exec -it truck-signs-api python manage.py shell
```
```python
from django.core.mail import send_mail
send_mail(
    'Test Subject',
    'Test message.',
    'your-email@gmail.com',
    ['recipient@example.com'],
    fail_silently=False,
)
```

### Stripe payments failing

**Verify API keys:**
- Check keys in Stripe Dashboard
- Ensure test mode keys start with `pk_test_` and `sk_test_`
- Verify keys are correctly set in `.env`

**Test Stripe connection in shell:**
```bash
docker exec -it truck-signs-api python manage.py shell
```
```python
import stripe
from django.conf import settings
stripe.api_key = settings.STRIPE_SECRET_KEY
stripe.Customer.list(limit=1)
```

### Complete cleanup and fresh start

```bash
# Stop all containers
docker stop truck-signs-api truck-signs-db

# Remove containers
docker rm truck-signs-api truck-signs-db

# Remove network
docker network rm truck-signs-network

# Remove volume (WARNING: deletes data!)
docker volume rm truck-signs-data

# Remove image
docker rmi truck-signs-api:latest

# Start fresh deployment from step 4 in Quickstart
```

---

## Project Information

- **Technology Stack**: Django 2.2.8, PostgreSQL 15, Gunicorn, WhiteNoise
- **Container Runtime**: Docker 20.10+
- **Database**: PostgreSQL 15 Alpine
- **WSGI Server**: Gunicorn
- **Payment Integration**: Stripe API
- **Email Provider**: Gmail SMTP
- **Last Updated**: January 2026
- **Branch**: feature/api-containerization
- **Course**: DevSecOps
