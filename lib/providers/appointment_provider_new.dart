import 'package:flutter/foundation.dart';
import 'package:stibe_partner/api/appointment_service.dart';

// Temporary appointment models until backend is ready
class Appointment {
  final String id;
  final String customerId;
  final String customerName;
  final String serviceId;
  final String serviceName;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final AppointmentStatus status;
  final String? notes;

  Appointment({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.serviceId,
    required this.serviceName,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
  });
}

enum AppointmentStatus { pending, confirmed, completed, cancelled }

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  
  List<Appointment> _appointments = [];
  List<Appointment> _pendingAppointments = [];
  List<Appointment> _todayAppointments = [];
  Map<DateTime, List<Appointment>> _calendarData = {};
  Appointment? _selectedAppointment;
  bool _isLoading = false;
  String? _error;
  
  List<Appointment> get appointments => _appointments;
  List<Appointment> get pendingAppointments => _pendingAppointments;
  List<Appointment> get todayAppointments => _todayAppointments;
  Map<DateTime, List<Appointment>> get calendarData => _calendarData;
  Appointment? get selectedAppointment => _selectedAppointment;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load all appointments
  Future<void> loadAllAppointments({
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Handle the fact that appointment service returns empty list
      await _appointmentService.getAllAppointments(
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      _appointments = <Appointment>[]; // Empty for now
      
      notifyListeners();
    } catch (e) {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load pending appointments
  Future<void> loadPendingAppointments() async {
    _setLoading(true);
    _clearError();
    
    try {
      _pendingAppointments = <Appointment>[]; // Empty for now
      notifyListeners();
    } catch (e) {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load today's appointments
  Future<void> loadTodayAppointments() async {
    _setLoading(true);
    _clearError();
    
    try {
      _todayAppointments = <Appointment>[]; // Empty for now
      notifyListeners();
    } catch (e) {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load calendar data
  Future<void> loadCalendarData({required DateTime month}) async {
    _setLoading(true);
    _clearError();
    
    try {
      _calendarData = <DateTime, List<Appointment>>{}; // Empty for now
      notifyListeners();
    } catch (e) {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
    } finally {
      _setLoading(false);
    }
  }
  
  // Get appointment details
  Future<void> getAppointmentDetails({required String id}) async {
    _setLoading(true);
    _clearError();
    
    try {
      // This will throw an exception since the method doesn't exist
      await _appointmentService.getAppointmentDetails(id: id);
    } catch (e) {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
    } finally {
      _setLoading(false);
    }
  }
  
  // Update appointment status
  Future<bool> updateAppointmentStatus({
    required String id,
    required AppointmentStatus status,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
      return false;
    } catch (e) {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Reschedule appointment
  Future<bool> rescheduleAppointment({
    required String id,
    required DateTime newDate,
    required String newStartTime,
    required String newEndTime,
    String? staffId,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
      return false;
    } catch (e) {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Send appointment reminder
  Future<bool> sendAppointmentReminder({required String id}) async {
    _setLoading(true);
    _clearError();
    
    try {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
      return false;
    } catch (e) {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Search appointments
  Future<void> searchAppointments({
    String? query,
    String? customerName,
    String? customerPhone,
    String? staffId,
    String? status,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _appointments = <Appointment>[]; // Empty for now
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
      notifyListeners();
    } catch (e) {
      _setError('Appointment management not available yet. Backend AppointmentController needed.');
    } finally {
      _setLoading(false);
    }
  }
  
  // Set selected appointment
  void setSelectedAppointment(Appointment? appointment) {
    _selectedAppointment = appointment;
    notifyListeners();
  }
  
  // Clear selected appointment
  void clearSelectedAppointment() {
    _selectedAppointment = null;
    notifyListeners();
  }
  
  // Helper methods
  void _updateAppointmentInLists(Appointment updatedAppointment) {
    // This method is kept for future use when appointments are implemented
    // Update in all appointments list
    final allIndex = _appointments.indexWhere((a) => a.id == updatedAppointment.id);
    if (allIndex != -1) {
      _appointments[allIndex] = updatedAppointment;
    }
    
    // Update in pending appointments list
    final pendingIndex = _pendingAppointments.indexWhere((a) => a.id == updatedAppointment.id);
    if (pendingIndex != -1) {
      if (updatedAppointment.status == AppointmentStatus.pending) {
        _pendingAppointments[pendingIndex] = updatedAppointment;
      } else {
        _pendingAppointments.removeAt(pendingIndex);
      }
    }
    
    // Update in today's appointments list
    final todayIndex = _todayAppointments.indexWhere((a) => a.id == updatedAppointment.id);
    if (todayIndex != -1) {
      _todayAppointments[todayIndex] = updatedAppointment;
    }
    
    // Update in calendar data
    _calendarData.forEach((date, appointments) {
      final calendarIndex = appointments.indexWhere((a) => a.id == updatedAppointment.id);
      if (calendarIndex != -1) {
        if (date == updatedAppointment.appointmentDate) {
          appointments[calendarIndex] = updatedAppointment;
        } else {
          appointments.removeAt(calendarIndex);
          
          // Add to new date if it exists in calendar
          if (_calendarData.containsKey(updatedAppointment.appointmentDate)) {
            _calendarData[updatedAppointment.appointmentDate]!.add(updatedAppointment);
          }
        }
      }
    });
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
