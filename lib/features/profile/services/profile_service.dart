import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/user_model.dart';

class ProfileService {

  final ApiService _api = ApiService();

  /*
  GET PROFILE
  */
  Future<User> getProfile() async {
    try {
      final response = await _api.get(ApiConstants.profile);
      return User.fromJson(response.data["data"]);
    } catch (e) {
      rethrow;
    }
  }

  /*
  UPDATE PROFILE
  */
  Future<User> updateProfile({
    String? username,
    String? city,
  }) async {
    try {
      final response = await _api.put(
        ApiConstants.profile,
        {
          if (username != null && username.isNotEmpty) "username": username,
          if (city != null) "city": city,
        },
      );
      return User.fromJson(response.data["data"]);
    } catch (e) {
      rethrow;
    }
  }

}