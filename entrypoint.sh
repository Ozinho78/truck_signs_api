#!/bin/bash
set -e

echo "======================================"
echo "Django Entrypoint Script"
echo "======================================"

# ============================================================================
# Database Connection Check
# ============================================================================
echo "[1/5] Checking database connection..."
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
    echo "⏳ PostgreSQL is unavailable - waiting..."
    sleep 2
done
echo "✅ PostgreSQL is ready"

# ============================================================================
# Database Migrations
# ============================================================================
echo "[2/5] Running database migrations..."
python manage.py migrate --noinput || {
    echo "❌ Migration failed!"
    exit 1
}
echo "✅ Migrations completed"

# ============================================================================
# Static Files Collection
# ============================================================================
echo "[3/5] Collecting static files..."
python manage.py collectstatic --noinput --clear || {
    echo "❌ Static files collection failed!"
    exit 1
}
echo "✅ Static files collected"

# ============================================================================
# Superuser Creation (nur Development)
# ============================================================================
if [ "$DJANGO_ENV" = "development" ]; then
    echo "[4/5] Creating superuser (development mode)..."
    python manage.py shell <<EOF
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin')
    print('✅ Superuser created: admin/admin')
else:
    print('ℹ️  Superuser already exists')
EOF
else
    echo "[4/5] Skipping superuser creation (production mode)"
fi

# ============================================================================
# Start Gunicorn
# ============================================================================
echo "[5/5] Starting Gunicorn..."
echo "======================================"
echo "Environment: ${DJANGO_ENV:-production}"
echo "Database: $POSTGRES_HOST:5432/$POSTGRES_DB"
echo "Binding: 0.0.0.0:8000"
echo "======================================"

# Gunicorn direkt starten - kein exec "$@" mehr!
exec gunicorn truck_signs_designs.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 4 \
    --timeout 60 \
    --access-logfile - \
    --error-logfile - \
    --log-level info
