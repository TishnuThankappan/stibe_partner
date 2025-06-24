class Staff {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profileImage;
  final String role;
  final List<String>? serviceIds;
  final List<Availability>? availability;
  final bool isActive;
  final DateTime createdAt;

  Staff({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
    required this.role,
    this.serviceIds,
    this.availability,
    required this.isActive,
    required this.createdAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      role: json['role'],
      serviceIds: json['serviceIds'] != null
          ? List<String>.from(json['serviceIds'])
          : null,
      availability: json['availability'] != null
          ? (json['availability'] as List)
              .map((avail) => Availability.fromJson(avail))
              .toList()
          : null,
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'role': role,
      'serviceIds': serviceIds,
      'availability': availability?.map((avail) => avail.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Availability {
  final String day;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  Availability({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      day: json['day'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      isAvailable: json['isAvailable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }
}

class StaffPerformance {
  final String staffId;
  final String staffName;
  final int completedAppointments;
  final int cancelledAppointments;
  final double totalRevenue;
  final double averageRating;
  final Map<String, int> serviceBreakdown;

  StaffPerformance({
    required this.staffId,
    required this.staffName,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.totalRevenue,
    required this.averageRating,
    required this.serviceBreakdown,
  });

  factory StaffPerformance.fromJson(Map<String, dynamic> json) {
    return StaffPerformance(
      staffId: json['staffId'],
      staffName: json['staffName'],
      completedAppointments: json['completedAppointments'],
      cancelledAppointments: json['cancelledAppointments'],
      totalRevenue: json['totalRevenue'].toDouble(),
      averageRating: json['averageRating'].toDouble(),
      serviceBreakdown: Map<String, int>.from(json['serviceBreakdown']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'completedAppointments': completedAppointments,
      'cancelledAppointments': cancelledAppointments,
      'totalRevenue': totalRevenue,
      'averageRating': averageRating,
      'serviceBreakdown': serviceBreakdown,
    };
  }
}
