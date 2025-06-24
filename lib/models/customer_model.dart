class Customer {
  final String id;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final String? profileImage;
  final List<CustomerNote>? notes;
  final DateTime? lastVisit;
  final int totalVisits;
  final double totalSpent;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    this.profileImage,
    this.notes,
    this.lastVisit,
    required this.totalVisits,
    required this.totalSpent,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      notes: json['notes'] != null
          ? (json['notes'] as List)
              .map((note) => CustomerNote.fromJson(note))
              .toList()
          : null,
      lastVisit:
          json['lastVisit'] != null ? DateTime.parse(json['lastVisit']) : null,
      totalVisits: json['totalVisits'],
      totalSpent: json['totalSpent'].toDouble(),
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
      'notes': notes?.map((note) => note.toJson()).toList(),
      'lastVisit': lastVisit?.toIso8601String(),
      'totalVisits': totalVisits,
      'totalSpent': totalSpent,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CustomerNote {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  CustomerNote({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  factory CustomerNote.fromJson(Map<String, dynamic> json) {
    return CustomerNote(
      id: json['id'],
      content: json['content'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
