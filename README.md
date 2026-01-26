# Truck Signs API - Deployment

This repository contains the **containerized deployment** for the Truck Signs API, a Django-based REST API for truck signage management. The setup uses Docker to orchestrate a production-ready environment with PostgreSQL database, Stripe payment integration, and email functionality.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quickstart](#quickstart)
3. [Usage](#usage)
   - [Project Structure](#project-structure)
   - [Environment Configuration](#environment-configuration)
   - [Managing Containers](#managing-containers)
4. [Troubleshooting](#troubleshooting)
   - [Container won't start](#container-won't-start)
   - [Database connection errors](#database-connection-errors)
   - [Port already in use](#port-already-in-use)
   - [Complete cleanup and fresh start](#complete-cleanup-and-fresh-start)

---

## Prerequisites

- **Docker**: Version 20.10 or higher
- **Python**: Version 3.10 or higher
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

### 3. Build Docker image
```bash
docker build -t truck-signs-api:latest .
```

### 4. Create Docker network
```bash
docker network create truck-signs-network
```

### 5. Start PostgreSQL database
```bash
docker run -d \
    --name truck-signs-db \
    --network truck-signs-network \
    --env-file .env \
    -v truck-signs-data:/var/lib/postgresql/data \
    postgres:15-alpine
```

### 6. Start Django API
```bash
docker run -d \
    --name truck-signs-api \
    --network truck-signs-network \
    --env-file .env \
    -p 8020:8000 \
    truck-signs-api:latest
```

### 7. Verify containers status
```bash
docker ps --filter "name=truck-signs"
```

Expected output:
```
CONTAINER ID   IMAGE                    STATUS         PORTS                    NAMES
abc123def456   truck-signs-api:latest   Up 10 seconds  0.0.0.0:8020->8000/tcp  truck-signs-api
def456ghi789   postgres:15-alpine       Up 15 seconds  5432/tcp                truck-signs-db
```

### 9. Access application
- **API**: `http://<YOUR_SERVER_IP>:8020`
- **Admin Panel**: `http://<YOUR_SERVER_IP>:8020/admin`

---

## Usage

### Project Structure

```bash
truck-signs-api/
├── .gitignore                  # Excludes .env, logs, IDE configs, OS files
├── Dockerfile                  # Container build instructions
├── checklist.md                # DevSecOps checklist that has to be fulfilled for the project
├── entrypoint.sh               # Container startup script, DB migrations and Gunicorn launch
├── .env.template               # Template for .env, contains environment variables
├── .env                        # Runtime environment variables (NOT in Git!), created by YOU
├── README.md                   # This document, project documentation with ToC, quickstart, usage
├── requirements.txt            # Python dependencies that have to be installed for running the project
```

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
POSTGRES_HOST=truck-signs-db            # Container name
POSTGRES_PORT=5432                      # Default PostgreSQL port
POSTGRES_DB=truck_signs_db              # Database name
POSTGRES_USER=truck_signs_user          # Database user
POSTGRES_PASSWORD=use_strong_password   # CHANGE THIS!
```

> [!WARNING]
> Never use default passwords in production!

#### 2. Django Secret Key
Generate using Python (Python and Django required):
```bash
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

Then set in `.env`:
```bash
DOCKER_SECRET_KEY=your_generated_secret_key_here
```

#### 3. Django Settings (REQUIRED for production)
```bash
DJANGO_ENV=production                               # or 'development'
DEBUG=False                                         # NEVER True in production!
ALLOWED_HOSTS=localhost,127.0.0.1,<YOUR_SERVER_IP>  # Add the ip address of your server here
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
DOCKER_EMAIL_HOST_USER=<your-email>@gmail.com
DOCKER_EMAIL_HOST_PASSWORD=your_16_char_app_password
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


**View database logs:**
```bash
docker logs truck-signs-db
docker logs -f truck-signs-db
```

**Save logs to file:**
```bash
docker logs truck-signs-api > api-logs.txt
docker logs truck-signs-db > db-logs.txt
```

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

**Check what's using port 8020:**
```bash
# Windows
netstat -ano | findstr :8020

# Linux/macOS
lsof -i :8020
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

- **Course**: DevSecOps
- **Branch**: feature/api-containerization
- **Last Updated**: January 2026
