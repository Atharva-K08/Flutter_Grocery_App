import 'package:flutter/material.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/items/screens/home_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/spend/screens/spend_screen.dart';
import '../features/suggestions/screens/suggestion_screen.dart';
class AppRoutes {

  static Map<String, WidgetBuilder> routes = {
    "/":         (context) => SplashScreen(),
    "/login":    (context) => LoginScreen(),
    "/register": (context) => RegisterScreen(),
    "/home":     (context) => HomeScreen(),
    "/profile":  (context) => ProfileScreen(),
    "/spend":    (context) => SpendScreen(),
    "/suggestions": (context) => SuggestionScreen(),
  };
}