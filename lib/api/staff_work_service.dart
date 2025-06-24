import 'package:stibe_partner/api/api_service.dart';

class StaffWorkSessionDto {
  final int id;
  final int staffId;
  final DateTime clockInTime;
  final DateTime? clockOutTime;
  final int? totalMinutesWorked;
  final double? totalEarnings;
  final bool isActive;
  final List<BreakSessionDto> breaks;
  final DateTime createdAt;

  StaffWorkSessionDto({
    required this.id,
    required this.staffId,
    required this.clockInTime,
    this.clockOutTime,
    this.totalMinutesWorked,
    this.totalEarnings,
    required this.isActive,
    required this.breaks,
    required this.createdAt,
  });

  factory StaffWorkSessionDto.fromJson(Map<String, dynamic> json) {
    return StaffWorkSessionDto(
      id: json['id'],
      staffId: json['staffId'],
      clockInTime: DateTime.parse(json['clockInTime']),
      clockOutTime: json['clockOutTime'] != null ? DateTime.parse(json['clockOutTime']) : null,
      totalMinutesWorked: json['totalMinutesWorked'],
      totalEarnings: json['totalEarnings']?.toDouble(),
      isActive: json['isActive'] ?? false,
      breaks: (json['breaks'] as List?)?.map((b) => BreakSessionDto.fromJson(b)).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Duration? get workDuration {
    if (clockOutTime != null) {
      return clockOutTime!.difference(clockInTime);
    } else if (isActive) {
      return DateTime.now().difference(clockInTime);
    }
    return null;
  }
}

class BreakSessionDto {
  final int id;
  final int workSessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;

  BreakSessionDto({
    required this.id,
    required this.workSessionId,
    required this.startTime,
    this.endTime,
    required this.isActive,
  });

  factory BreakSessionDto.fromJson(Map<String, dynamic> json) {
    return BreakSessionDto(
      id: json['id'],
      workSessionId: json['workSessionId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isActive: json['isActive'] ?? false,
    );
  }

  Duration? get breakDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    } else if (isActive) {
      return DateTime.now().difference(startTime);
    }
    return null;
  }
}

class WorkStatusDto {
  final bool isClockedIn;
  final bool isOnBreak;
  final StaffWorkSessionDto? currentSession;
  final BreakSessionDto? currentBreak;

  WorkStatusDto({
    required this.isClockedIn,
    required this.isOnBreak,
    this.currentSession,
    this.currentBreak,
  });

  factory WorkStatusDto.fromJson(Map<String, dynamic> json) {
    return WorkStatusDto(
      isClockedIn: json['isClockedIn'] ?? false,
      isOnBreak: json['isOnBreak'] ?? false,
      currentSession: json['currentSession'] != null 
          ? StaffWorkSessionDto.fromJson(json['currentSession']) 
          : null,
      currentBreak: json['currentBreak'] != null 
          ? BreakSessionDto.fromJson(json['currentBreak']) 
          : null,
    );
  }
}

class StaffWorkService {
  final ApiService _apiService = ApiService();

  // Clock in to work
  Future<StaffWorkSessionDto> clockIn() async {
    final response = await _apiService.post('/staffwork/clock-in');
    
    if (response['data'] != null) {
      return StaffWorkSessionDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to clock in');
  }

  // Clock out from work
  Future<StaffWorkSessionDto> clockOut() async {
    final response = await _apiService.post('/staffwork/clock-out');
    
    if (response['data'] != null) {
      return StaffWorkSessionDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to clock out');
  }

  // Get current work status
  Future<WorkStatusDto> getWorkStatus() async {
    final response = await _apiService.get('/staffwork/status');
    
    if (response['data'] != null) {
      return WorkStatusDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to get work status');
  }

  // Get today's work session
  Future<StaffWorkSessionDto?> getTodaySession() async {
    try {
      final response = await _apiService.get('/staffwork/today-session');
      
      if (response['data'] != null) {
        return StaffWorkSessionDto.fromJson(response['data']);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get work history
  Future<List<StaffWorkSessionDto>> getWorkHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final response = await _apiService.get('/staffwork/history', queryParams: queryParams);
    
    if (response['data'] != null) {
      return (response['data'] as List)
          .map((session) => StaffWorkSessionDto.fromJson(session))
          .toList();
    }
    
    return [];
  }

  // Start break
  Future<BreakSessionDto> startBreak() async {
    final response = await _apiService.post('/staffwork/start-break');
    
    if (response['data'] != null) {
      return BreakSessionDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to start break');
  }

  // End break
  Future<BreakSessionDto> endBreak() async {
    final response = await _apiService.post('/staffwork/end-break');
    
    if (response['data'] != null) {
      return BreakSessionDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to end break');
  }
}
