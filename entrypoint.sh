#!/bin/bash
set -e

until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
    echo "⏳ PostgreSQL is unavailable - waiting..."
    sleep 2
done
echo "✅ PostgreSQL is ready"

python manage.py migrate --noinput || {
    echo "❌ Migration failed!"
    exit 1
}
echo "✅ Migrations completed"

python manage.py collectstatic --noinput --clear || {
    echo "❌ Static files collection failed!"
    exit 1
}
echo "✅ Static files collected"

if [ "$DJANGO_ENV" = "development" ]; then
    python manage.py shell <<EOF
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin')
    print('✅ Superuser created: admin/admin')
EOF

exec gunicorn truck_signs_designs.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 4 \
    --timeout 60 \
    --access-logfile - \
    --error-logfile - \
    --log-level info
