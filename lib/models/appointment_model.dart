
enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class Appointment {
  final String id;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerPhoto;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final List<ServiceItem> services;
  final String? staffId;
  final String? staffName;
  final double totalAmount;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final bool isPaid;
  final PaymentInfo? paymentInfo;

  Appointment({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerPhoto,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.services,
    this.staffId,
    this.staffName,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.isPaid,
    this.paymentInfo,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerPhoto: json['customerPhoto'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      services: (json['services'] as List)
          .map((service) => ServiceItem.fromJson(service))
          .toList(),
      staffId: json['staffId'],
      staffName: json['staffName'],
      totalAmount: json['totalAmount'].toDouble(),
      status: AppointmentStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      isPaid: json['isPaid'],
      paymentInfo: json['paymentInfo'] != null
          ? PaymentInfo.fromJson(json['paymentInfo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerPhoto': customerPhoto,
      'appointmentDate': appointmentDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'services': services.map((service) => service.toJson()).toList(),
      'staffId': staffId,
      'staffName': staffName,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'isPaid': isPaid,
      'paymentInfo': paymentInfo?.toJson(),
    };
  }
}

class ServiceItem {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;

  ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      durationMinutes: json['durationMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
    };
  }
}

class PaymentInfo {
  final String id;
  final String paymentMethod;
  final String transactionId;
  final DateTime paymentDate;
  final double amount;
  final String status;

  PaymentInfo({
    required this.id,
    required this.paymentMethod,
    required this.transactionId,
    required this.paymentDate,
    required this.amount,
    required this.status,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      paymentDate: DateTime.parse(json['paymentDate']),
      amount: json['amount'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'paymentDate': paymentDate.toIso8601String(),
      'amount': amount,
      'status': status,
    };
  }
}
