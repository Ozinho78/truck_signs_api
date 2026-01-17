@echo off
echo ======================================
echo Starting Truck Signs API - COMPLETE
echo ======================================

REM Alte Container stoppen
echo.
echo [1/4] Stopping old containers...
docker stop truck-signs-api truck-signs-db 2>nul
docker rm truck-signs-api truck-signs-db 2>nul

REM Network
echo.
echo [2/4] Creating network...
docker network create truck-signs-network 2>nul
echo OK: Network ready

REM Database
echo.
echo [3/4] Starting PostgreSQL...
docker run -d ^
    --name truck-signs-db ^
    --network truck-signs-network ^
    -e POSTGRES_DB=truck_signs_db ^
    -e POSTGRES_USER=truck_signs_user ^
    -e POSTGRES_PASSWORD=secure_password_123 ^
    -v truck-signs-data:/var/lib/postgresql/data ^
    postgres:15-alpine

echo OK: Database started
echo Waiting 5 seconds...
timeout /t 5 /nobreak >nul

REM API - Mit ALLEN benoetigten Environment Variables aus test_docker.py
echo.
echo [4/4] Starting Django API...
docker run -d ^
    --name truck-signs-api ^
    --network truck-signs-network ^
    -p 8000:8000 ^
    -e DJANGO_ENV=development ^
    -e DOCKER_SECRET_KEY=dev-secret-key-change-in-production-12345 ^
    -e DEBUG=True ^
    -e ALLOWED_HOSTS=localhost,127.0.0.1 ^
    -e DOCKER_DB_HOST=truck-signs-db ^
    -e DOCKER_DB_PORT=5432 ^
    -e DOCKER_DB_NAME=truck_signs_db ^
    -e DOCKER_DB_USER=truck_signs_user ^
    -e DOCKER_DB_PASSWORD=secure_password_123 ^
    -e DOCKER_STRIPE_PUBLISHABLE_KEY=pk_test_51SqblyH43nfRF7y8bd0GOiyODiONmKmeV1SPBiq0PA3nwsBkDU2OlFGEoAVrSAtUeDTqKBjptp1vk2H5LjT5yDJX004tJ6gpds ^
    -e DOCKER_STRIPE_SECRET_KEY=sk_test_REDACTED ^
    -e DOCKER_EMAIL_HOST_USER=michael.fiebelkorn@gmail.com ^
    -e DOCKER_EMAIL_HOST_PASSWORD=zzokytbhnclswesr ^
    -e POSTGRES_HOST=truck-signs-db ^
    -e POSTGRES_PORT=5432 ^
    -e POSTGRES_DB=truck_signs_db ^
    -e POSTGRES_USER=truck_signs_user ^
    -e POSTGRES_PASSWORD=secure_password_123 ^
    truck-signs-api:latest

echo.
echo ======================================
echo OK: Started!
echo ======================================
echo.
echo HINWEIS: Dummy-Werte werden verwendet fuer:
echo   - Stripe Keys (Payment funktioniert NICHT)
echo   - Email (Email-Versand funktioniert NICHT)
echo.
echo Fuer echte Credentials siehe: ENV_PRODUCTION.md
echo.
echo Application: http://localhost:8000
echo Admin: http://localhost:8000/admin
echo Login: admin / admin
echo.
echo Logs: docker logs -f truck-signs-api
echo ======================================
echo.

pause
