# Stibe Partner - Flutter & .NET Full Stack Application

A comprehensive salon management application built with Flutter (mobile frontend) and .NET 8 Web API (backend).

## 🏗️ Architecture Overview

- **Frontend**: Flutter (Cross-platform mobile app)
- **Backend**: .NET 8 Web API with Entity Framework Core
- **Database**: MySQL
- **Authentication**: JWT with email verification
- **Network**: Configured for local network access (`192.168.41.23:5074`)

## 📋 Prerequisites

### System Requirements
- **Windows 10/11** (Primary development environment)
- **Flutter SDK** (3.0+)
- **Dart SDK** (3.0+)
- **.NET 8 SDK**
- **MySQL Server** (8.0+)
- **Visual Studio Code** or **Visual Studio 2022**
- **Android Studio** (for Android development)

### Development Tools
```bash
# Verify installations
flutter --version
dotnet --version
mysql --version
```

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd stibe_partner-1
```

### 2. Backend Setup (.NET API)

#### Database Configuration
1. **Update Connection String** in `stibe.api/appsettings.Development.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=stibe_db;User=root;Password=your_password;"
  },
  "Urls": "http://192.168.41.23:5074"
}
```

#### Essential .NET Commands

```powershell
# Navigate to API directory
cd "E:\stibe_partner-1\stibe.api"

# Stop any running dotnet processes
taskkill /IM dotnet.exe /F

# Alternative: Kill specific process by PID
taskkill /PID <process_id> /F

# Restore dependencies
dotnet restore

# Build the project
dotnet build

# Create initial migration
dotnet ef migrations add init

# Update database with migrations
dotnet ef database update

# Run the API (development)
dotnet run

# Run with specific URL
dotnet run --urls "http://192.168.41.23:5074"

# Watch mode for development
dotnet watch run

# Clean build artifacts
dotnet clean

# List Entity Framework tools
dotnet ef

# Remove last migration
dotnet ef migrations remove

# Generate SQL script from migrations
dotnet ef migrations script
```

#### API Endpoints Overview
- **Base URL**: `http://192.168.41.23:5074/api`
- **Authentication**: `/auth/register`, `/auth/login`, `/auth/verify-email`
- **Salon Management**: `/salon` (CRUD operations)
- **Profile**: `/auth/me`, `/auth/change-password`

### 3. Frontend Setup (Flutter)

#### Environment Configuration
Update `lib/constants/app_theme.dart`:
```dart
class AppConfig {
  static String get baseUrl {
    return 'http://192.168.41.23:5074/api';  // Your network IP
  }
}
```

#### Essential Flutter Commands

```powershell
# Navigate to Flutter project root
cd "E:\stibe_partner-1"

# Get Flutter dependencies
flutter pub get

# Clean Flutter cache
flutter clean

# Check Flutter setup
flutter doctor

# List available devices
flutter devices

# Run on Windows
flutter run -d windows

# Run on Android (device/emulator)
flutter run -d android

# Run on Chrome (web)
flutter run -d chrome

# Build for production
flutter build apk --release
flutter build windows --release

# Generate code (if using build_runner)
flutter packages pub run build_runner build

# Analyze code
flutter analyze

# Run tests
flutter test

# Install specific package
flutter pub add package_name

# Remove package
flutter pub remove package_name

# Upgrade dependencies
flutter pub upgrade

# Show dependency tree
flutter pub deps
```

## 🛠️ Development Workflow

### Starting Development Session

1. **Start Backend**:
```powershell
cd "E:\stibe_partner-1\stibe.api"
dotnet run --urls "http://192.168.41.23:5074"
```

2. **Start Frontend**:
```powershell
cd "E:\stibe_partner-1"
flutter run -d windows
```

### Common Development Tasks

#### Backend Development
```powershell
# Stop running API
taskkill /IM dotnet.exe /F

# Make changes to code...

# Rebuild and restart
cd "E:\stibe_partner-1\stibe.api"
dotnet build
dotnet run --urls "http://192.168.41.23:5074"

# For database schema changes
dotnet ef migrations add MigrationName
dotnet ef database update
```

#### Frontend Development
```powershell
# Hot reload is automatic, but for clean restart:
# Stop the app (Ctrl+C)
flutter clean
flutter pub get
flutter run -d windows
```

### Database Management

```powershell
cd "E:\stibe_partner-1\stibe.api"

# View migration history
dotnet ef migrations list

# Create new migration
dotnet ef migrations add AddNewFeature

# Apply migrations
dotnet ef database update

# Rollback to specific migration
dotnet ef database update PreviousMigrationName

# Generate SQL script
dotnet ef migrations script > migration.sql

# Drop database (be careful!)
dotnet ef database drop
```

## 🔧 Troubleshooting

### Common Issues & Solutions

#### .NET API Issues
```powershell
# Process already running
taskkill /IM dotnet.exe /F

# Port already in use
netstat -ano | findstr :5074
taskkill /PID <process_id> /F

# Build errors
dotnet clean
dotnet restore
dotnet build

# Database connection issues
# Check MySQL service is running
# Verify connection string
# Check firewall settings
```

#### Flutter Issues
```powershell
# Dependency issues
flutter clean
flutter pub get

# Build issues
flutter clean
flutter pub cache repair

# Network connectivity
# Check API URL in app_theme.dart
# Verify API is accessible: http://192.168.41.23:5074/api

# Android build issues
flutter doctor --android-licenses
flutter doctor
```

#### Network Access Issues
```powershell
# Check Windows Firewall
# Allow port 5074 for inbound connections
netsh advfirewall firewall add rule name="Stibe API" dir=in action=allow protocol=TCP localport=5074

# Test API accessibility
curl http://192.168.41.23:5074/api
```

## 📁 Project Structure

```
stibe_partner-1/
├── lib/                          # Flutter source code
│   ├── api/                      # API service layers
│   ├── constants/                # App constants & themes
│   ├── models/                   # Data models
│   ├── providers/                # State management
│   ├── screens/                  # UI screens
│   ├── widgets/                  # Reusable widgets
│   └── main.dart                 # App entry point
├── stibe.api/                    # .NET Web API
│   ├── Controllers/              # API controllers
│   ├── Data/                     # Database context
│   ├── Models/                   # Entity models & DTOs
│   ├── Services/                 # Business logic
│   ├── Migrations/               # EF Core migrations
│   └── Program.cs                # API entry point
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
├── windows/                      # Windows-specific files
└── test/                         # Test files
```

## 🔐 Authentication Flow

1. **User Registration** → Email verification required
2. **Email Verification** → Click link in email
3. **Login** → Returns JWT token
4. **Business Profile Setup** → Create salon profile
5. **Main App Access** → Full functionality available

## 🌐 Network Configuration

### For Cross-Device Development
- **API Host**: `192.168.41.23:5074`
- **Flutter Config**: Update `AppConfig.baseUrl` in `app_theme.dart`
- **Firewall**: Ensure port 5074 is open for inbound connections

### Testing from Mobile Device
1. Connect mobile device to same WiFi network
2. Ensure API is running on `192.168.41.23:5074`
3. Install APK or use `flutter run` with device connected

## 📊 Database Schema

### Key Entities
- **Users**: Authentication & user profiles
- **Salons**: Business information
- **Services**: Salon services offered
- **Staff**: Salon employees
- **Appointments**: Booking system (planned)

## 🔄 API Response Format

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* response data */ },
  "errors": []
}
```

## 🧪 Testing

### Backend Testing
```powershell
cd "E:\stibe_partner-1\stibe.api"
dotnet test
```

### Frontend Testing
```powershell
cd "E:\stibe_partner-1"
flutter test
```

### Manual API Testing
Use tools like Postman or curl:
```bash
# Test login
curl -X POST http://192.168.41.23:5074/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'
```

## 📝 Environment Variables

### .NET API (appsettings.Development.json)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=stibe_db;User=root;Password=your_password;"
  },
  "Jwt": {
    "SecretKey": "your-secret-key",
    "Issuer": "StibeAPI",
    "Audience": "StibeClients",
    "ExpiryMinutes": 60
  },
  "Email": {
    "SmtpServer": "smtp.gmail.com",
    "SmtpPort": 587,
    "SenderEmail": "your-email@gmail.com",
    "SenderPassword": "your-app-password"
  }
}
```

### Flutter (lib/constants/app_theme.dart)
```dart
class AppConfig {
  static const Environment currentEnvironment = Environment.development;
  
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return 'http://192.168.41.23:5074/api';
      case Environment.production:
        return 'https://your-production-url.com/api';
    }
  }
}
```

## 🚀 Deployment

### Development Deployment
1. **Backend**: Already configured for network access
2. **Frontend**: Build and install APK on devices

### Production Deployment
1. **Backend**: Deploy to cloud provider (Azure, AWS, etc.)
2. **Frontend**: Publish to Google Play Store / Apple App Store
3. **Database**: Use cloud database service

## 📞 Support & Contribution

### Getting Help
1. Check this README first
2. Review troubleshooting section
3. Check Flutter/Dart documentation
4. Check .NET documentation

### Development Guidelines
1. Follow Flutter/Dart conventions
2. Follow C# coding standards
3. Write meaningful commit messages
4. Test your changes before committing
5. Update documentation as needed

---

**Happy Coding! 🎉**

*Last Updated: June 25, 2025*
