import 'package:flutter/foundation.dart';
import 'package:stibe_partner/api/appointment_service.dart';
import 'package:stibe_partner/models/appointment_model.dart';

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
      _appointments = await _appointmentService.getAllAppointments(
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Load pending appointments
  Future<void> loadPendingAppointments() async {
    _setLoading(true);
    _clearError();
    
    try {
      _pendingAppointments = await _appointmentService.getPendingAppointments();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Load today's appointments
  Future<void> loadTodayAppointments() async {
    _setLoading(true);
    _clearError();
    
    try {
      _todayAppointments = await _appointmentService.getTodayAppointments();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Load calendar data
  Future<void> loadCalendarData({required DateTime month}) async {
    _setLoading(true);
    _clearError();
    
    try {
      _calendarData = await _appointmentService.getCalendarData(month: month);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Get appointment details
  Future<void> getAppointmentDetails({required String id}) async {
    _setLoading(true);
    _clearError();
    
    try {
      _selectedAppointment = await _appointmentService.getAppointmentDetails(id: id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
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
      final updatedAppointment = await _appointmentService.updateAppointmentStatus(
        id: id,
        status: status,
        notes: notes,
      );
      
      // Update in lists
      _updateAppointmentInLists(updatedAppointment);
      
      if (_selectedAppointment?.id == id) {
        _selectedAppointment = updatedAppointment;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
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
      final updatedAppointment = await _appointmentService.rescheduleAppointment(
        id: id,
        newDate: newDate,
        newStartTime: newStartTime,
        newEndTime: newEndTime,
        staffId: staffId,
        notes: notes,
      );
      
      // Update in lists
      _updateAppointmentInLists(updatedAppointment);
      
      if (_selectedAppointment?.id == id) {
        _selectedAppointment = updatedAppointment;
      }
      
      // Reload calendar data
      await loadCalendarData(month: newDate);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
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
      return await _appointmentService.sendAppointmentReminder(id: id);
    } catch (e) {
      _setError(e.toString());
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
      _appointments = await _appointmentService.searchAppointments(
        query: query,
        customerName: customerName,
        customerPhone: customerPhone,
        staffId: staffId,
        status: status,
      );
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
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
