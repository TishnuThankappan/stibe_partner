// NOTE: Appointment endpoints are not available in the current .NET API
// This service is temporarily disabled until AppointmentController is implemented
// in the .NET backend at E:\stibe.api\stibe.api

/*
// Original appointment service - disabled until backend is ready
import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/models/appointment_model.dart';

class AppointmentService {
  final ApiService _apiService = ApiService();
  
  // TODO: Implement these methods once AppointmentController is added to .NET API
  
  Future<List<Appointment>> getAllAppointments() async {
    throw UnimplementedError('Appointment endpoints not available in .NET API yet');
  }
  
  Future<Appointment> getAppointmentDetails({required String id}) async {
    throw UnimplementedError('Appointment endpoints not available in .NET API yet');
  }
  
  // ... other appointment methods
}
*/

// Placeholder service until backend is ready
class AppointmentService {
  Future<List<dynamic>> getAllAppointments({
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    // Return empty list until backend AppointmentController is implemented
    return [];
  }
  
  Future<dynamic> getAppointmentDetails({required String id}) async {
    throw Exception('Appointment endpoints not available in .NET API yet. Please implement AppointmentController first.');
  }
}
