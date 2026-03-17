import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/suggestion_model.dart';

class SuggestionService {

  final ApiService _api = ApiService();

  /*
  GET SUGGESTIONS (with optional search)
  */
  Future<List<Suggestion>> getSuggestions({String search = ""}) async {
    try {
      final response = await _api.get(
        "${ApiConstants.suggestions}?search=$search",
      );
      return (response.data["data"] as List)
          .map((e) => Suggestion.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /*
  DELETE SUGGESTION
  */
  Future<void> deleteSuggestion(String id) async {
    try {
      await _api.delete(ApiConstants.suggestion(id));
    } catch (e) {
      rethrow;
    }
  }

}