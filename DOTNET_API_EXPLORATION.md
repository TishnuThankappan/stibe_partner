# .NET API Exploration Report - Stibe Booking API

## 🏗️ **API Structure Overview**

**Base URL**: `https://localhost:7090/api` (or `http://localhost:5074/api`)  
**Database**: MySQL on localhost:3306 (Database: `stibe_booking`)  
**Authentication**: JWT Bearer Token  
**Documentation**: Swagger UI available at `/swagger`

## 📁 **Project Structure**

```
E:\stibe.api\stibe.api\
├── Controllers/           # API Controllers
├── Data/                 # Database Context
├── Models/               # DTOs and Entities
├── Services/             # Business Logic Services
├── Configuration/        # Configuration classes
├── Migrations/           # EF Core Migrations
├── Properties/           # Launch settings
├── Program.cs           # Application startup
└── appsettings.json     # Configuration
```

## 🔌 **Available API Endpoints**

### **Authentication Controller** (`/api/auth`)
- `POST /api/auth/register` - User registration (Customer/SalonOwner)
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user profile
- `POST /api/auth/change-password` - Change password
- `POST /api/auth/forgot-password` - Request password reset
- `GET /api/auth/verify-email` - Verify email address

### **Salon Controller** (`/api/salon`)
- `POST /api/salon` - Create new salon (SalonOwner only)
- `GET /api/salon/{id}` - Get salon details
- `GET /api/salon/my-salons` - Get current user's salons

### **Service Controller** (`/api/service`)
- `POST /api/service` - Create new service
- `GET /api/service` - Get all services
- `GET /api/service/{serviceId}` - Get specific service
- `PUT /api/service/{serviceId}` - Update service
- `DELETE /api/service/{serviceId}` - Delete service

### **Staff Controller** (`/api/staff`)
- `POST /api/staff/register` - Register new staff member
- `POST /api/staff/login` - Staff login
- `GET /api/staff/dashboard` - Staff dashboard data
- `GET /api/staff/profile` - Get staff profile
- `PUT /api/staff/profile` - Update staff profile
- `POST /api/staff/specializations` - Add staff specializations
- `GET /api/staff/salon/{salonId}` - Get staff by salon
- `GET /api/staff/{id}` - Get specific staff member

### **Staff Work Controller** (`/api/staffwork`)
- `POST /api/staffwork/clock-in` - Clock in to work
- `POST /api/staffwork/clock-out` - Clock out from work
- `GET /api/staffwork/status` - Get current work status
- `GET /api/staffwork/today-session` - Get today's work session
- `GET /api/staffwork/history` - Get work history
- `POST /api/staffwork/start-break` - Start break
- `POST /api/staffwork/end-break` - End break

### **Test Controller** (`/api/test`)
- `GET /api/test/health` - Health check
- `GET /api/test/protected` - Test protected endpoint
- `GET /api/test/admin-only` - Admin only test
- `GET /api/test/salon-owner` - Salon owner test
- `GET /api/test/customer` - Customer test
- `GET /api/test/debug-claims` - Debug JWT claims

## 🔐 **Authentication & Authorization**

### **JWT Configuration**
- **Secret Key**: Configured in appsettings.json
- **Issuer**: "StibeAPI"
- **Audience**: "StibeUsers"
- **Expiry**: 60 minutes

### **User Roles**
- `Customer` - Regular customers
- `SalonOwner` - Salon owners
- `Staff` - Salon staff members (inferred from StaffController)

### **Authentication Flow**
1. Register with `/api/auth/register`
2. Login with `/api/auth/login` to get JWT token
3. Include token in Authorization header: `Bearer {token}`

## 📝 **Key Data Models**

### **Registration Request**
```json
{
  "firstName": "string",
  "lastName": "string", 
  "email": "string",
  "phoneNumber": "string",
  "password": "string",
  "confirmPassword": "string",
  "role": "Customer" | "SalonOwner"
}
```

### **Login Request**
```json
{
  "email": "string",
  "password": "string"
}
```

### **Login Response**
```json
{
  "token": "jwt-token",
  "refreshToken": "refresh-token",
  "expiresAt": "datetime",
  "user": {
    "id": 1,
    "firstName": "string",
    "lastName": "string",
    "email": "string",
    "phoneNumber": "string",
    "role": "string",
    "isEmailVerified": false,
    "createdAt": "datetime"
  }
}
```

## ⚙️ **Configuration**

### **Database Connection**
- **Server**: localhost
- **Database**: stibe_booking
- **User**: root
- **Password**: 2232
- **Port**: 3306

### **Feature Flags**
- `UseRealEmailService`: false (using mock)
- `UseRealSmsService`: false (using mock)
- `UseRealPaymentService`: false (using mock)
- `UseRealLocationService`: false (using mock)

## 🚀 **Running the API**

1. **Development with HTTPS**: `https://localhost:7090`
2. **Development with HTTP**: `http://localhost:5074`
3. **Swagger Documentation**: `/swagger`

## 🔄 **Integration with Flutter App - UPDATED**

### **✅ Services Updated to Match .NET API:**

1. **AuthService** - ✅ Updated
   - `/auth/register` - User registration with firstName/lastName
   - `/auth/login` - User login with JWT token
   - `/auth/me` - Get current user profile
   - `/auth/change-password` - Change password
   - `/auth/forgot-password` - Password reset
   - `/auth/verify-email` - Email verification

2. **SalonService** - ✅ Created New
   - `/salon` - Create new salon
   - `/salon/{id}` - Get salon details
   - `/salon/my-salons` - Get user's salons

3. **StaffService** - ✅ Created New
   - `/staff/register` - Register staff member
   - `/staff/login` - Staff login
   - `/staff/dashboard` - Staff dashboard data
   - `/staff/profile` - Staff profile management
   - `/staff/salon/{salonId}` - Get staff by salon

4. **StaffWorkService** - ✅ Created New
   - `/staffwork/clock-in` - Clock in to work
   - `/staffwork/clock-out` - Clock out from work
   - `/staffwork/status` - Get work status
   - `/staffwork/history` - Get work history
   - `/staffwork/start-break` - Start break
   - `/staffwork/end-break` - End break

5. **ServiceManagementService** - ✅ Updated
   - `/service` - Service CRUD operations
   - Updated endpoints to match .NET API structure

6. **TestService** - ✅ Created New
   - `/test/health` - Health check
   - `/test/protected` - Test authentication
   - `/test/salon-owner` - Test role-based access

### **⚠️ Services Disabled/Pending:**

1. **AppointmentService** - ❌ Disabled
   - **Reason**: No AppointmentController in .NET API
   - **Action Required**: Create AppointmentController.cs in .NET API
   - **Current Status**: Returns empty data with error messages

### **🔧 Model Updates:**

1. **User Model** - ✅ Updated
   - Changed `id` from String to int
   - Separated `fullName` into `firstName` and `lastName`
   - Added `isEmailVerified` field
   - Updated to match .NET API UserDto structure

### **📋 Updated Response Format Handling:**

All services now expect .NET API response format:
```json
{
  "data": { /* actual data */ },
  "success": true,
  "message": "Success message"
}
```

## 📋 **Next Steps - UPDATED**

### **✅ Completed:**
1. ✅ Updated Flutter services to match .NET API endpoints
2. ✅ Updated User model to match .NET API UserDto
3. ✅ Created new services for Salon, Staff, and StaffWork management
4. ✅ Updated authentication flow to handle .NET API response format
5. ✅ Created test service for API connectivity verification

### **🚀 Ready to Test:**
1. **Start your .NET API** at `https://localhost:7090`
2. **Run Flutter app** to test the connection
3. **Use TestService** to verify API connectivity
4. **Test authentication flow** with register/login

### **⚠️ Still Required:**
1. **Create AppointmentController.cs** in .NET API for booking management
2. **Test all endpoints** with actual data
3. **Handle SSL certificate** issues if using HTTPS (see notes below)

### **🔧 Testing Commands:**

```dart
// Test API connectivity
final testService = TestService();
final results = await testService.runApiTests();
print(results);

// Test authentication
final authService = AuthService();
final user = await authService.register(
  email: "test@example.com",
  password: "password123",
  firstName: "Test",
  lastName: "User",
  phoneNumber: "+1234567890",
);
```

## 🐛 **Development Notes**

- API uses mock services for email, SMS, payments, and location
- Database is automatically created in development mode
- CORS is configured to allow all origins for development
- Swagger UI includes JWT authentication support
