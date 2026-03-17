import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  void _checkToken() async {
    await Future.delayed(Duration(seconds: 1));

    final token = await StorageService.getToken();

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.green,
            ),

            SizedBox(height: 16),

            Text(
              "Grocery App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 32),

            CircularProgressIndicator(),

          ],
        ),
      ),
    );
  }
}