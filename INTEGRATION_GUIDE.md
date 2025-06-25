# Flutter + .NET API Integration Guide

## Overview
This project combines:
- **Flutter Frontend**: Salon booking partner app
- **.NET Backend API**: RESTful API with JWT authentication, MySQL database

## Project Structure
```
stibe_partner/
├── lib/                    # Flutter app source
│   ├── api/               # API service classes
│   ├── models/            # Data models
│   ├── screens/           # UI screens
│   └── services/          # Flutter services
├── stibe.api/             # .NET API backend
│   ├── Controllers/       # API controllers
│   ├── Models/            # Entity models & DTOs
│   ├── Services/          # Business logic
│   └── Data/              # Database context
```

## Current Configuration

### Flutter App (Client)
- **Base URL**: `http://localhost:5000/api` (Development)
- **Authentication**: JWT Bearer tokens
- **Storage**: Flutter Secure Storage for tokens
- **HTTP Client**: Dio with interceptors

### .NET API (Server)  
- **Port**: 5074
- **Database**: MySQL (stibe_db)
- **Authentication**: JWT with role-based authorization
- **Swagger**: Available at `/swagger` endpoint

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Token refresh

### Staff Management
- `GET /api/staff` - Get all staff
- `POST /api/staff` - Create staff member
- `GET /api/staff/{id}` - Get staff by ID
- `PUT /api/staff/{id}` - Update staff
- `DELETE /api/staff/{id}` - Delete staff

### Services
- `GET /api/service` - Get all services
- `POST /api/service` - Create service
- `GET /api/service/{id}` - Get service by ID

### Salons
- `GET /api/salon` - Get salon information
- `POST /api/salon` - Create/update salon

## Running the Application

### 1. Start the .NET API
```bash
cd stibe.api
dotnet run --project stibe.api.csproj
```
API will be available at: `http://192.168.43.126:5074`
Swagger documentation: `http://192.168.43.126:5074/swagger`

### 2. Start the Flutter App
```bash
flutter run
```

## Database Setup
1. Ensure MySQL is running on port 3306
2. Create database: `CREATE DATABASE stibe_db;`
3. API will auto-create tables on first run (Development mode)

## Model Mapping

### Staff Model Differences
**Flutter Model** → **.NET Model**
- `fullName` → `FirstName + LastName`
- `id` (String) → `Id` (Guid)
- `createdAt` → `CreatedAt`
- `isActive` → `IsActive`

### Authentication Flow
1. Flutter app sends login request to `/api/auth/login`
2. API validates credentials and returns JWT token
3. Flutter stores token in secure storage
4. Future API calls include `Authorization: Bearer {token}` header
5. API validates token and processes request

## Next Steps for Full Integration

1. **Update Flutter Models**: Align with .NET API response format
2. **Update API Services**: Implement all Flutter API service methods
3. **Add Error Handling**: Standardize error responses
4. **Test Integration**: End-to-end testing between Flutter and API
5. **Add Real Data**: Replace mock data with API calls

## Configuration Files

### Flutter Configuration
- `lib/constants/app_theme.dart` - Contains API base URL
- `lib/api/api_service.dart` - HTTP client configuration

### .NET Configuration
- `appsettings.json` - Production configuration
- `appsettings.Development.json` - Development configuration
- `Properties/launchSettings.json` - Launch profiles

## Stibe .NET API Integration

### New Services
The following services have been added to integrate with the .NET API:

1. `DotNetAuthService` (`lib/api/dotnet_auth_service.dart`)
   - Handles authentication with the .NET backend
   - Includes login, register, password reset, and token management

2. `DotNetSalonService` (`lib/api/dotnet_salon_service.dart`)
   - Manages salon operations
   - Create, read, update, delete salon entities

3. `DotNetStaffService` (`lib/api/dotnet_staff_service.dart`)
   - Manages staff operations
   - Add, remove, and update staff members
   - Manage staff schedules

4. `DotNetServiceManagementService` (`lib/api/dotnet_service_management_service.dart`)
   - Manages salon services
   - Add, remove, and update service offerings
   - Assign services to staff members

### Testing the Integration
You can test the API integration using the built-in API Test Screen:
1. Navigate to the Debug section in the app
2. Open the "API Test" screen
3. Click on "Test .NET API Connection" to verify connectivity
4. Click on "Test .NET Login" to verify authentication

### Running the API
To run the .NET API locally:
1. Open a terminal
2. Navigate to the `stibe.api` directory
3. Run `dotnet restore` to restore dependencies
4. Run `dotnet run` to start the API

Alternatively, use the `start_api.bat` file in the root directory.
