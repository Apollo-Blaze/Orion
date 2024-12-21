import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For decoding JWT

class AuthService {
  // Check if JWT token exists and is valid
  static Future<bool> isTokenValid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    print(token);
    print("here");

    if (token == null || token.isEmpty) {
      print("null");
      return false; // No token, invalid
    }

    // Optionally: Check token expiry (if you want more security)
    // Decoding the token and checking expiry
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print("no length");
        return false; // Invalid JWT
      }

      final payload = parts[1];
      final decoded = json.decode(_base64UrlDecode(payload));
      final expiryTime = decoded['exp'] *
          1000; // JWT expiration time is in seconds, multiply by 1000 for milliseconds

      // Convert UTC expiry time to IST
      final expiryTimeInIST =
          DateTime.fromMillisecondsSinceEpoch(expiryTime, isUtc: true).add(
              Duration(
                  hours: 5,
                  minutes: 30)); // Convert to IST by adding 5 hours 30 minutes

      print('Token expiry time in IST: $expiryTimeInIST');

      // Get the current time in IST
      final currentTimeInIST =
          DateTime.now().toUtc().add(Duration(hours: 5, minutes: 30));

      // If the token is expired, return false
      if (expiryTimeInIST.isBefore(currentTimeInIST)) {
        return false; // Token expired
      }

      return true; // Token is valid and not expired
    } catch (e) {
      print(e);
      return false; // If decoding fails, return false
    }
  }

  // Helper function to decode the base64Url part of the JWT
  static String _base64UrlDecode(String str) {
    // Add padding if necessary
    int padLength = 4 - (str.length % 4);
    if (padLength != 4) {
      str = str + '=' * padLength;
    }

    // Replace URL-safe characters
    String normalized = str.replaceAll('-', '+').replaceAll('_', '/');
    return utf8.decode(base64.decode(normalized));
  }

  // Function to store the token (e.g., after login)
  static Future<void> storeToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(token);
    prefs.setString('jwt_token', token);
  }

  // Function to remove the token (e.g., after logout)
  static Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('jwt_token');
  }
}
