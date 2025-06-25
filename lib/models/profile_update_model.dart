import 'package:stibe_partner/models/user_model.dart';

class ProfileUpdateModel {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? profileImage;

  ProfileUpdateModel({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.profileImage,
  });

  // Create from User model
  factory ProfileUpdateModel.fromUser(User user) {
    return ProfileUpdateModel(
      firstName: user.firstName,
      lastName: user.lastName,
      phoneNumber: user.phoneNumber,
      profileImage: user.profileImage,
    );
  }

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
    };
  }

  // Create a copy with modified fields
  ProfileUpdateModel copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImage,
  }) {
    return ProfileUpdateModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
