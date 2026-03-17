import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/item_model.dart';

class ItemService {

  final ApiService _api = ApiService();

  /*
  GET ALL ITEMS
  */
  Future<Map<String, dynamic>> getItems({int page = 1, int limit = 10}) async {
    try {
      final response = await _api.get(
        "${ApiConstants.items}?page=$page&limit=$limit",
      );

      final data = response.data["data"];

      final List<Item> items = (data["items"] as List)
          .map((e) => Item.fromJson(e))
          .toList();

      return {
        "items": items,
        "total": data["total"],
        "pages": data["pages"],
        "page":  data["page"],
      };
    } catch (e) {
      rethrow;
    }
  }

  /*
  CREATE ITEM
  */
  Future<Item> createItem({
    required String name,
    required int quantity,
    required String unit,
    String? note,
    double price = 0,
  }) async {
    try {
      final response = await _api.authPost(    // <-- this was _api.post
        ApiConstants.items,
        {
          "name":     name,
          "quantity": quantity,
          "unit":     unit,
          if (note != null && note.isNotEmpty) "note": note,
          "price":    price,
        },
      );
      return Item.fromJson(response.data["data"]);
    } catch (e) {
      rethrow;
    }
  }

  /*
  UPDATE ITEM
  */
  Future<Item> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final response = await _api.put(ApiConstants.item(id), data);
      return Item.fromJson(response.data["data"]);
    } catch (e) {
      rethrow;
    }
  }

  /*
  DELETE ITEM
  */
  Future<void> deleteItem(String id) async {
    try {
      await _api.delete(ApiConstants.item(id));
    } catch (e) {
      rethrow;
    }
  }

  /*
  PURCHASE ITEM
  */
  Future<Item> purchaseItem(String id, {double? price}) async {
    try {
      final response = await _api.put(
        ApiConstants.purchaseItem(id),
        {
          if (price != null) "price": price,
        },
      );
      return Item.fromJson(response.data["data"]);
    } catch (e) {
      rethrow;
    }
  }
  /*
  CLEAR ITEMS
  deletes all provided item ids in parallel
  */
  Future<void> clearItems(List<String> ids) async {
    try {
      await Future.wait(
        ids.map((id) => _api.delete(ApiConstants.item(id))),
      );
    } catch (e) {
      rethrow;
    }
  }

}