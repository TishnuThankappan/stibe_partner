# API Integration Guide

## .NET Backend Integration

Your Flutter app is now configured to connect to your local .NET backend at `https://localhost:7090/api`.

### Configuration Changes Made:

1. **Updated Base URL**: Changed from `https://api.stibe.com/partner` to `https://localhost:7090/api`
2. **Added Environment Configuration**: Created `AppConfig` class for easy switching between development and production
3. **SSL Handling**: Added notes for localhost SSL certificate handling

### Environment Configuration

The app now uses an environment-based configuration:

```dart
enum Environment { development, production }

class AppConfig {
  static const Environment currentEnvironment = Environment.development;
  
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return 'https://localhost:7090/api';
      case Environment.production:
        return 'https://api.stibe.com/partner';
    }
  }
}
```

### API Endpoints Expected

Based on your Flutter services, your .NET API should provide these endpoints:

#### Authentication (`/api/auth` or `/api/`)
- `POST /register` - User registration
- `POST /login` - User login
- `POST /verify-email` - Email verification
- `POST /forgot-password` - Password reset request
- `POST /reset-password` - Password reset
- `POST /resend-verification` - Resend verification email
- `POST /logout` - User logout
- `GET /profile` - Get user profile
- `PUT /profile` - Update user profile

#### Appointments (`/api/appointments`)
- `GET /appointments` - Get all appointments (with optional query params: status, startDate, endDate)
- `GET /appointments/{id}` - Get appointment details
- `PUT /appointments/{id}/status` - Update appointment status
- `PUT /appointments/{id}/reschedule` - Reschedule appointment
- `DELETE /appointments/{id}` - Cancel appointment

#### Service Management (`/api/services` or similar)
- Based on your `service_management_service.dart` file

### Expected Response Format

Your .NET API should return responses in this format:

#### Authentication Response:
```json
{
  "token": "jwt-token-here",
  "user": {
    "id": "user-id",
    "email": "user@example.com",
    "fullName": "User Name",
    "phoneNumber": "+1234567890"
  }
}
```

#### Appointments Response:
```json
{
  "appointments": [
    {
      "id": "appointment-id",
      "customerId": "customer-id",
      "serviceId": "service-id",
      "staffId": "staff-id",
      "dateTime": "2025-06-24T10:00:00Z",
      "status": "confirmed",
      "duration": 60,
      "notes": "Appointment notes"
    }
  ]
}
```

### Testing the Connection

1. **Start your .NET API** at `https://localhost:7090`
2. **Test basic connectivity** by running your Flutter app
3. **Check API responses** match the expected format above

### SSL Certificate Issues

If you encounter SSL certificate issues when connecting to localhost:

1. **For Development**: The app includes a note about SSL handling
2. **Alternative**: Use HTTP instead of HTTPS for local development by changing the base URL to `http://localhost:7090/api`

### Switching to Production

To switch to production mode:
1. Change `Environment.development` to `Environment.production` in `AppConfig`
2. Or update the production URL in the `AppConfig.baseUrl` getter

### Error Handling

The API service includes comprehensive error handling for:
- Network timeouts
- Server errors (4xx, 5xx)
- Authentication errors (401)
- Connection issues

Make sure your .NET API returns appropriate HTTP status codes and error messages in this format:
```json
{
  "message": "Error description"
}
```
