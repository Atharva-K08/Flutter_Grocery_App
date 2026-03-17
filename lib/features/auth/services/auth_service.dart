import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/api_constants.dart';

class AuthService {

  final ApiService _api = ApiService();

  Future<bool> register(
      String username,
      String email,
      String password, {
        String? city,
      }) async {
    try {
      final response = await _api.post(
        ApiConstants.register,
        {
          "username": username,
          "email":    email,
          "password": password,
          if (city != null && city.isNotEmpty) "city": city,
        },
      );
      return response.data["success"] == true;
    } catch (e) {
      rethrow;
    }
  }
  Future<bool> login(String email, String password) async {
    try {
      final response = await _api.post(
        ApiConstants.login,
        {
          "email":    email,
          "password": password,
        },
      );

      final String token = response.data["token"];

      print("TOKEN RECEIVED: $token");

      await StorageService.saveToken(token);

      final saved = await StorageService.getToken();
      print("TOKEN SAVED: $saved");

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await StorageService.clearToken();
  }

}