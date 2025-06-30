import 'dart:convert';
import 'package:stibe_partner/api/salon_service.dart';

class DebugHelper {
  static Future<void> testSalonData() async {
    print('🐛 DEBUG: Testing salon data...');
    
    try {
      final salonService = SalonService();
      final salons = await salonService.getMySalons();
      
      print('🐛 DEBUG: Found ${salons.length} salons');
      
      for (int i = 0; i < salons.length; i++) {
        final salon = salons[i];
        print('🐛 DEBUG: Salon $i:');
        print('  📝 Name: ${salon.name}');
        print('  📞 Phone: ${salon.phoneNumber}');
        print('  📧 Email: ${salon.email}');
        print('  📍 Address: ${salon.address}');
        print('  🏙️ City: ${salon.city}');
        print('  🏛️ State: ${salon.state}');
        print('  📮 Zip: ${salon.zipCode}');
        print('  🔄 Active: ${salon.isActive}');
        print('  🖼️ Profile Picture: ${salon.profilePictureUrl}');
        print('  📸 Images: ${salon.imageUrls}');
        print('  ⏰ Hours: ${salon.openingTime} - ${salon.closingTime}');
        print('  🆔 ID: ${salon.id}');
        print('  👤 Owner ID: ${salon.ownerId}');
        print('  📅 Created: ${salon.createdAt}');
        print('  📝 Description: ${salon.description}');
        print('');
      }
      
      if (salons.isEmpty) {
        print('🐛 DEBUG: No salons found - this explains why you might see placeholder data');
        print('🐛 DEBUG: Try creating a new salon first');
      }
      
    } catch (e, stackTrace) {
      print('🐛 DEBUG: Error fetching salon data: $e');
      print('🐛 DEBUG: Stack trace: $stackTrace');
    }
  }
  
  static void logSalonJson(Map<String, dynamic> json) {
    print('🐛 DEBUG: Raw salon JSON:');
    print(JsonEncoder.withIndent('  ').convert(json));
  }
}
