# Personal Finance App 💰

A comprehensive personal finance management application built with **Flutter** and **FastAPI**, featuring real-time expense tracking, analytics, and financial insights.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────┐
│                Frontend                      │
│  ┌─────────────────────────────────────────┐ │
│  │            Flutter App                   │ │
│  │  • BLoC State Management               │ │
│  │  • Clean Architecture                  │ │
│  │  • Material 3 Design                   │ │
│  │  • Internationalization (i18n)         │ │
│  └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
                       │
                   HTTP/REST
                       │
┌─────────────────────────────────────────────┐
│                Backend                       │
│  ┌─────────────────────────────────────────┐ │
│  │           FastAPI Server                │ │
│  │  • JWT Authentication                  │ │
│  │  • SQLAlchemy ORM                      │ │
│  │  • PostgreSQL Database                 │ │
│  │  • Pydantic Validation                 │ │
│  └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## 🚀 Features

### 📱 Mobile App (Flutter)
- **Authentication**: Secure login/register with JWT tokens
- **Dashboard**: Real-time financial overview with balance tracking
- **Transactions**: Add, edit, delete income and expense transactions
- **Categories**: Organize transactions with custom categories
- **Analytics**: Visual charts and spending insights
- **Settings**: Profile management and app preferences
- **Multi-language**: Support for multiple languages (i18n)
- **Themes**: Light and dark theme support

### 🔧 Backend API (FastAPI)
- **RESTful API**: Complete CRUD operations for all entities
- **Authentication**: JWT-based secure authentication system
- **Database**: PostgreSQL with SQLAlchemy ORM
- **Analytics**: Financial summaries and trend analysis
- **Data Validation**: Comprehensive input validation with Pydantic
- **CORS**: Configured for frontend integration
- **Documentation**: Auto-generated OpenAPI/Swagger documentation

## 🛠️ Technology Stack

### Frontend
| Technology | Purpose |
|------------|---------|
| **Flutter 3.7+** | Cross-platform mobile development |
| **Dart 2.19+** | Programming language |
| **BLoC Pattern** | State management and business logic |
| **Go Router** | Navigation and routing |
| **Dio** | HTTP client for API communication |
| **Get It** | Dependency injection |
| **Flutter Intl** | Internationalization support |
| **JSON Serializable** | Model serialization |

### Backend
| Technology | Purpose |
|------------|---------|
| **FastAPI** | Modern Python web framework |
| **SQLAlchemy** | ORM and database abstraction |
| **PostgreSQL** | Primary database |
| **Pydantic** | Data validation and settings |
| **JWT** | Authentication tokens |
| **Alembic** | Database migrations |
| **Uvicorn** | ASGI server |

## 📋 Prerequisites

Before running the application, ensure you have:

- **Flutter SDK**: 3.7.0 or higher
- **Dart SDK**: 2.19.0 or higher
- **Python**: 3.8 or higher
- **PostgreSQL**: 12 or higher
- **Docker** (optional): For containerized deployment

## ⚙️ Environment Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd personal-finance-app
```

### 2. Backend Setup

#### Install Python Dependencies
```bash
cd backend
pip install -r requirements.txt
```

#### Database Setup
1. **Install PostgreSQL** (if not using Docker)
2. **Create Database**:
```sql
CREATE DATABASE finance_db;
CREATE USER finance_user WITH ENCRYPTED PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE finance_db TO finance_user;
```

3. **Environment Variables**:
Create `.env` file in backend directory:
```env
DATABASE_URL=postgresql://finance_user:your_password@localhost:5432/finance_db
SECRET_KEY=your-super-secret-jwt-key-here
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

#### Run Database Migrations
```bash
# Initialize Alembic (if not done)
alembic init alembic

# Generate migration
alembic revision --autogenerate -m "Initial migration"

# Run migration
alembic upgrade head
```

#### Start Backend Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at: `http://localhost:8000`
API Documentation: `http://localhost:8000/docs`

### 3. Frontend Setup

#### Install Flutter Dependencies
```bash
cd frontend
flutter pub get
```

#### Generate Model Files
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### Environment Configuration
The app supports multiple environments:
- **Development**: `.env.dev`
- **Staging**: `.env.staging`
- **Production**: `.env.prod`

#### Run Flutter App
```bash
# For development
flutter run

# For specific platform
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run -d android         # Android
flutter run -d ios             # iOS
```

## 🐳 Docker Deployment

### Using Docker Compose
```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Rebuild and start
docker-compose up --build
```

Services will be available at:
- **Backend API**: `http://localhost:8000`
- **PostgreSQL**: `localhost:5432`
- **Frontend**: Build and deploy separately

## 📁 Project Structure

### Frontend Structure
```
frontend/lib/
├── config/                 # Environment configuration
├── core/                   # Core functionality
│   ├── constants/          # App constants (colors, sizes)
│   ├── di/                 # Dependency injection
│   ├── errors/             # Error handling
│   ├── navigation/         # App routing
│   ├── network/            # HTTP client setup
│   └── storage/            # Local & secure storage
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   │   ├── data/           # Data layer (API, models)
│   │   ├── domain/         # Business logic (entities, use cases)
│   │   └── presentation/   # UI layer (BLoC, pages, widgets)
│   ├── dashboard/          # Dashboard feature
│   ├── transactions/       # Transaction management
│   ├── analytics/          # Financial analytics
│   └── settings/           # App settings
├── l10n/                   # Internationalization files
└── shared/                 # Shared components
    ├── theme/              # App theming
    └── widgets/            # Reusable widgets
```

### Backend Structure
```
backend/
├── app/
│   ├── api/v1/            # API routes
│   ├── models/            # Database models
│   ├── schemas/           # Pydantic schemas
│   ├── services/          # Business logic
│   ├── utils/             # Utilities (auth, database)
│   └── main.py            # FastAPI app initialization
├── alembic/               # Database migrations
├── tests/                 # Test files
├── requirements.txt       # Python dependencies
└── docker-compose.yml     # Docker configuration
```

## 🔌 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | User registration |
| POST | `/api/v1/auth/login` | User login |
| POST | `/api/v1/auth/logout` | User logout |
| GET | `/api/v1/auth/me` | Get current user |

### Transactions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/transactions` | Get user transactions |
| POST | `/api/v1/transactions` | Create new transaction |
| GET | `/api/v1/transactions/{id}` | Get transaction by ID |
| PUT | `/api/v1/transactions/{id}` | Update transaction |
| DELETE | `/api/v1/transactions/{id}` | Delete transaction |

### Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/categories` | Get user categories |
| POST | `/api/v1/categories` | Create new category |
| PUT | `/api/v1/categories/{id}` | Update category |
| DELETE | `/api/v1/categories/{id}` | Delete category |

### Analytics
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/analytics/summary` | Financial summary |
| GET | `/api/v1/analytics/spending-by-category` | Category breakdown |
| GET | `/api/v1/analytics/monthly-trends` | Monthly trends |

## 🌍 Internationalization

The app supports multiple languages using Flutter's intl package:

### Supported Languages
- **English** (en)
- **Vietnamese** (vi)
- **Spanish** (es)
- **French** (fr)

### Adding New Languages
1. Add language code to `lib/l10n/app_en.arb`
2. Create corresponding `.arb` file (e.g., `app_vi.arb`)
3. Run code generation:
```bash
flutter gen-l10n
```

## 🧪 Testing

### Backend Tests
```bash
cd backend
pytest tests/
```

### Frontend Tests
```bash
cd frontend
flutter test
```

## 📈 Performance & Optimization

### Frontend Optimizations
- **Lazy Loading**: Routes and heavy widgets
- **State Management**: Efficient BLoC pattern implementation
- **Image Optimization**: Cached network images
- **Build Optimization**: Tree shaking and code splitting

### Backend Optimizations
- **Database Indexing**: Optimized queries
- **Caching**: Response caching where appropriate
- **Connection Pooling**: Efficient database connections
- **Async Operations**: Non-blocking I/O operations

## 🚀 Deployment

### Production Deployment

#### Backend
```bash
# Build Docker image
docker build -t finance-api .

# Run with production environment
docker run -d -p 8000:8000 --env-file .env.prod finance-api
```

#### Frontend
```bash
# Build for web
flutter build web

# Build for mobile
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- **Issues**: [GitHub Issues](https://github.com/your-repo/issues)
- **Email**: support@yourapp.com
- **Documentation**: [API Docs](http://localhost:8000/docs)

---

**Built with ❤️ using Flutter & FastAPI**