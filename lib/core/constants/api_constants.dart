class ApiConstants {

  // Change to 10.0.2.2 for Android emulator
  // Change to your local IP for real device e.g. http://192.168.1.5:5000/api
  // static const String baseUrl = "http://127.0.0.1:5000/api";
  static const String baseUrl = "https://flutter-grocery-app-backend.onrender.com/api";

  // Auth
  static const String register = "/users/register";
  static const String login    = "/users/login";
  static const String profile  = "/users/profile";

  // Items
  static const String items = "/items";
  static String item(String id)     => "/items/$id";
  static String purchaseItem(String id) => "/items/$id/purchase";

  // Suggestions
  static const String suggestions = "/suggestions";
  static String suggestion(String id) => "/suggestions/$id";

  // Spend
  static const String spend      = "/spend";
  static const String resetSpend = "/spend/reset";

}