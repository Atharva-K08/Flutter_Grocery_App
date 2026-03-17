import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class SpendService {

  final ApiService _api = ApiService();

  /*
  GET TOTAL SPEND
  */
  Future<double> getTotalSpend() async {
    try {
      final response = await _api.get(ApiConstants.spend);
      return (response.data["amount"] ?? 0).toDouble();
    } catch (e) {
      rethrow;
    }
  }

  /*
  RESET SPEND
  */
  Future<void> resetSpend() async {
    try {
      await _api.put(ApiConstants.resetSpend, {});
    } catch (e) {
      rethrow;
    }
  }

}