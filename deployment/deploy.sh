#!/bin/bash

# Personal Finance App - Production Deployment Script
set -e

echo "🚀 Starting deployment of Personal Finance App Backend..."

# Configuration
REPO_URL="git@github.com-duyh2111:Duyh2111/personal-finance-app.git"
DEPLOY_DIR="/opt/personal-finance-app"
BACKUP_DIR="/opt/backups/finance-app"
ENV_FILE=".env.production"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root for security reasons"
   exit 1
fi

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    command -v docker >/dev/null 2>&1 || { log_error "Docker is required but not installed. Aborting."; exit 1; }
    command -v docker-compose >/dev/null 2>&1 || { log_error "Docker Compose is required but not installed. Aborting."; exit 1; }
    command -v git >/dev/null 2>&1 || { log_error "Git is required but not installed. Aborting."; exit 1; }

    log_info "Prerequisites check passed ✅"
}

# Create backup
create_backup() {
    if [ -d "$DEPLOY_DIR" ]; then
        log_info "Creating backup..."
        mkdir -p "$BACKUP_DIR"

        # Backup database
        docker-compose -f "$DEPLOY_DIR/deployment/docker-compose.prod.yml" exec -T db pg_dump -U \${POSTGRES_USER} \${POSTGRES_DB} > "$BACKUP_DIR/db_backup_$(date +%Y%m%d_%H%M%S).sql"

        # Backup app directory
        tar -czf "$BACKUP_DIR/app_backup_$(date +%Y%m%d_%H%M%S).tar.gz" -C "$DEPLOY_DIR" .

        log_info "Backup created ✅"
    fi
}

# Deploy application
deploy() {
    log_info "Deploying application..."

    # Clone or pull latest code
    if [ ! -d "$DEPLOY_DIR" ]; then
        log_info "Cloning repository..."
        git clone "$REPO_URL" "$DEPLOY_DIR"
    else
        log_info "Pulling latest changes..."
        cd "$DEPLOY_DIR"
        git pull origin main
    fi

    cd "$DEPLOY_DIR/deployment"

    # Check if environment file exists
    if [ ! -f "$ENV_FILE" ]; then
        log_error "Environment file $ENV_FILE not found!"
        log_info "Please copy .env.production.example to $ENV_FILE and configure it"
        exit 1
    fi

    # Build and start services
    log_info "Building and starting services..."
    docker-compose -f docker-compose.prod.yml --env-file "$ENV_FILE" down
    docker-compose -f docker-compose.prod.yml --env-file "$ENV_FILE" build --no-cache
    docker-compose -f docker-compose.prod.yml --env-file "$ENV_FILE" up -d

    # Wait for services to be ready
    log_info "Waiting for services to be ready..."
    sleep 30

    # Run database migrations
    log_info "Running database migrations..."
    docker-compose -f docker-compose.prod.yml --env-file "$ENV_FILE" exec backend alembic upgrade head

    # Health check
    log_info "Performing health check..."
    if curl -f http://localhost:8000/health; then
        log_info "Health check passed ✅"
        log_info "Deployment completed successfully! 🎉"
    else
        log_error "Health check failed! Check the logs."
        exit 1
    fi
}

# Rollback function
rollback() {
    log_warn "Rolling back to previous version..."

    # Find latest backup
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/app_backup_*.tar.gz 2>/dev/null | head -n1)

    if [ -z "$LATEST_BACKUP" ]; then
        log_error "No backup found for rollback"
        exit 1
    fi

    # Stop current services
    cd "$DEPLOY_DIR/deployment"
    docker-compose -f docker-compose.prod.yml down

    # Restore from backup
    cd "$DEPLOY_DIR"
    tar -xzf "$LATEST_BACKUP"

    # Start services
    cd deployment
    docker-compose -f docker-compose.prod.yml up -d

    log_info "Rollback completed"
}

# Main execution
case "${1:-deploy}" in
    "deploy")
        check_prerequisites
        create_backup
        deploy
        ;;
    "rollback")
        rollback
        ;;
    "backup")
        create_backup
        ;;
    *)
        echo "Usage: $0 {deploy|rollback|backup}"
        exit 1
        ;;
esac