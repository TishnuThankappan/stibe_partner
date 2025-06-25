# Stibe API Integration

## Overview
This Flutter application integrates with the Stibe.API backend service, which is a .NET Core API for salon management.

## Setup Instructions

### 1. Database Setup
- Install MySQL if not already installed
- Make sure MySQL is running on port 3306
- Database configuration (from DATABASE_SETUP.md):
  - Database: stibe_db
  - User: root
  - Password: 2232 (or update in appsettings.json)

### 2. Starting the API
- Run the `start_api.bat` file to start the API locally
- API will be available at http://localhost:5000

### 3. API Endpoints
The API provides the following controllers:
- AuthController - User authentication and registration
- SalonController - Salon management
- ServiceController - Service management
- StaffController - Staff management

### 4. Testing the API
- Use the included `stibe.api.http` file with REST Client extension in VS Code
- Or test with Postman using the endpoints documented in the controllers

### 5. Environment Configuration
- The Flutter app is configured to use http://localhost:5000 in development mode
- Update the production URL in app_theme.dart when deploying

## Troubleshooting
- If you encounter connection issues, ensure the API is running
- Check the database connection in appsettings.json
- Check for any CORS issues in the browser console
