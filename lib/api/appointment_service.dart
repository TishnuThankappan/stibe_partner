import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/models/appointment_model.dart';

class AppointmentService {
  final ApiService _apiService = ApiService();

  // Get all appointments
  Future<List<Appointment>> getAllAppointments({
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiService.get('/appointments', queryParams: queryParams);
    
    return (response['appointments'] as List)
        .map((appointment) => Appointment.fromJson(appointment))
        .toList();
  }

  // Get appointment details
  Future<Appointment> getAppointmentDetails({required String id}) async {
    final response = await _apiService.get('/appointments/$id');
    return Appointment.fromJson(response['appointment']);
  }

  // Update appointment status
  Future<Appointment> updateAppointmentStatus({
    required String id,
    required AppointmentStatus status,
    String? notes,
  }) async {
    final data = {
      'status': status.toString().split('.').last,
    };
    
    if (notes != null) data['notes'] = notes;

    final response = await _apiService.put('/appointments/$id/status', data: data);
    return Appointment.fromJson(response['appointment']);
  }

  // Reschedule appointment
  Future<Appointment> rescheduleAppointment({
    required String id,
    required DateTime newDate,
    required String newStartTime,
    required String newEndTime,
    String? staffId,
    String? notes,
  }) async {
    final data = {
      'newDate': newDate.toIso8601String(),
      'newStartTime': newStartTime,
      'newEndTime': newEndTime,
    };
    
    if (staffId != null) data['staffId'] = staffId;
    if (notes != null) data['notes'] = notes;

    final response = await _apiService.put('/appointments/$id/reschedule', data: data);
    return Appointment.fromJson(response['appointment']);
  }

  // Send appointment reminder
  Future<bool> sendAppointmentReminder({required String id}) async {
    final response = await _apiService.post('/appointments/$id/reminder');
    return response['sent'] ?? false;
  }

  // Get calendar view data
  Future<Map<DateTime, List<Appointment>>> getCalendarData({
    required DateTime month,
  }) async {
    final response = await _apiService.get('/appointments/calendar', queryParams: {
      'month': month.toIso8601String(),
    });
    
    final Map<DateTime, List<Appointment>> result = {};
    
    (response['calendar'] as Map<String, dynamic>).forEach((key, value) {
      final date = DateTime.parse(key);
      final appointments = (value as List)
          .map((appointment) => Appointment.fromJson(appointment))
          .toList();
      result[date] = appointments;
    });
    
    return result;
  }

  // Get pending appointments
  Future<List<Appointment>> getPendingAppointments() async {
    final response = await _apiService.get('/appointments/pending');
    
    return (response['appointments'] as List)
        .map((appointment) => Appointment.fromJson(appointment))
        .toList();
  }

  // Get today's appointments
  Future<List<Appointment>> getTodayAppointments() async {
    final response = await _apiService.get('/appointments/today');
    
    return (response['appointments'] as List)
        .map((appointment) => Appointment.fromJson(appointment))
        .toList();
  }

  // Search appointments
  Future<List<Appointment>> searchAppointments({
    String? query,
    String? customerName,
    String? customerPhone,
    String? staffId,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (query != null) queryParams['query'] = query;
    if (customerName != null) queryParams['customerName'] = customerName;
    if (customerPhone != null) queryParams['customerPhone'] = customerPhone;
    if (staffId != null) queryParams['staffId'] = staffId;
    if (status != null) queryParams['status'] = status;

    final response = await _apiService.get('/appointments/search', queryParams: queryParams);
    
    return (response['appointments'] as List)
        .map((appointment) => Appointment.fromJson(appointment))
        .toList();
  }
}
