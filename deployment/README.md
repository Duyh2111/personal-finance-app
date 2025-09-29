# Personal Finance App - Deployment Guide

This guide covers multiple deployment options for the Personal Finance App backend.

## 🚀 Quick Deploy Options

### Option 1: VPS/Cloud Server (Recommended)
**Best for: Production use, full control**

**Requirements:**
- Ubuntu 20.04+ or similar Linux distribution
- Docker & Docker Compose installed
- Domain name (optional for SSL)
- 2GB+ RAM, 20GB+ storage

**Steps:**
1. Clone repository on server:
   ```bash
   git clone git@github.com:Duyh2111/personal-finance-app.git
   cd personal-finance-app/deployment
   ```

2. Configure environment:
   ```bash
   cp .env.production .env.production.local
   nano .env.production.local  # Edit with your values
   ```

3. Deploy:
   ```bash
   ./deploy.sh
   ```

**Cost:** $5-20/month (DigitalOcean, Linode, AWS EC2)

### Option 2: Railway (Easiest)
**Best for: Quick deployment, minimal configuration**

1. Connect GitHub repository to Railway
2. Add PostgreSQL database
3. Set environment variables in Railway dashboard
4. Deploy automatically

**Cost:** Free tier available, ~$5-10/month

### Option 3: Render
**Best for: Free hosting, automatic deployments**

1. Connect GitHub repository
2. Use `deployment/render.yaml` configuration
3. Add PostgreSQL database
4. Deploy automatically

**Cost:** Free tier available

### Option 4: Heroku
**Best for: Simple deployment**

```bash
# Install Heroku CLI, then:
heroku create your-finance-app
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main
```

## 🔧 Configuration

### Environment Variables

#### Required Variables:
```env
# Database
POSTGRES_DB=finance_production
POSTGRES_USER=finance_user
POSTGRES_PASSWORD=your_secure_password

# Security
SECRET_KEY=your_32_char_secret_key_here
JWT_SECRET_KEY=your_jwt_secret_key_here

# CORS (Frontend domains)
CORS_ORIGINS=https://yourdomain.com
```

#### Optional Variables:
```env
# External Database (managed services)
DATABASE_URL=postgresql://user:pass@host:port/db

# SSL (for custom domains)
SSL_EMAIL=your-email@domain.com
DOMAIN=yourdomain.com

# Debugging (development only)
DEBUG=false
ENVIRONMENT=production
```

## 🔐 Security Configuration

### 1. Generate Secure Keys
```bash
# Generate SECRET_KEY
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Generate JWT_SECRET_KEY
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 2. Database Security
- Use strong passwords (16+ characters)
- Enable SSL connections
- Restrict database access by IP
- Regular backups

### 3. Network Security
- Use HTTPS only (SSL certificates)
- Configure firewall (ports 80, 443, 22 only)
- Regular security updates

## 📊 Monitoring & Maintenance

### Health Checks
The API includes a health check endpoint: `/health`

### Logs
```bash
# View application logs
docker-compose -f docker-compose.prod.yml logs backend

# View database logs
docker-compose -f docker-compose.prod.yml logs db
```

### Backups
```bash
# Manual backup
./deploy.sh backup

# Automated backups (add to crontab)
0 2 * * * /opt/personal-finance-app/deployment/deploy.sh backup
```

### Updates
```bash
# Deploy latest version
./deploy.sh deploy

# Rollback if needed
./deploy.sh rollback
```

## 🌐 Domain & SSL Setup

### Option 1: Let's Encrypt (Free SSL)
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Option 2: Cloudflare (Easy setup)
1. Add domain to Cloudflare
2. Point A record to server IP
3. Enable SSL/TLS encryption
4. Configure origin certificates

## 🔍 Troubleshooting

### Common Issues:

1. **Database Connection Failed**
   - Check DATABASE_URL format
   - Verify database is running
   - Check network connectivity

2. **CORS Errors**
   - Update CORS_ORIGINS with correct frontend domain
   - Include both www and non-www versions

3. **SSL Certificate Issues**
   - Verify domain DNS points to server
   - Check firewall allows ports 80, 443
   - Restart nginx after cert installation

4. **Memory Issues**
   - Increase server RAM
   - Reduce Gunicorn workers
   - Enable swap space

### Debug Commands:
```bash
# Check service status
docker-compose -f docker-compose.prod.yml ps

# Check logs
docker-compose -f docker-compose.prod.yml logs -f backend

# Test database connection
docker-compose -f docker-compose.prod.yml exec db psql -U $POSTGRES_USER -d $POSTGRES_DB

# Test API directly
curl -f http://localhost:8000/health
```

## 📈 Performance Optimization

### 1. Database Optimization
- Add database indexes
- Enable connection pooling
- Regular VACUUM and ANALYZE

### 2. Application Optimization
- Increase Gunicorn workers based on CPU cores
- Enable gzip compression in nginx
- Add Redis for caching (optional)

### 3. Infrastructure Optimization
- Use CDN for static assets
- Enable nginx caching
- Monitor resource usage

## 💰 Cost Estimates

| Platform | Free Tier | Paid Plans | Best For |
|----------|-----------|------------|----------|
| Railway | 500 hours/month | $5-20/month | Quick deployment |
| Render | 750 hours/month | $7-25/month | Free hosting |
| DigitalOcean | No | $5-20/month | Full control |
| AWS EC2 | 12 months free | $5-50/month | Scalability |
| Heroku | No | $7-25/month | Simplicity |

## 📞 Support

For deployment issues:
1. Check the troubleshooting section
2. Review application logs
3. Check GitHub issues
4. Contact support at: hoangduy17156@gmail.com