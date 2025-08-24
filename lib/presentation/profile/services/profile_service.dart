// Service class untuk handle API calls
import '../../auth/models/user_profile.dart';

class ProfileService {
  static Future<UserProfile?> getCurrentUser() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
  }

  static Future<void> updateProfile(UserProfile profile) async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 500));
  }

  static Future<void> signOut() async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 500));
  }
}
