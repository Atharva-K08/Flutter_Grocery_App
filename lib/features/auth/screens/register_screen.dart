import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _usernameController = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController     = TextEditingController();
  final _authService        = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _register() async {
    final username = _usernameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final city     = _cityController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showError("Username, email and password are required");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(username, email, password, city: city);
      _showSuccess("Account created! Please login.");
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Register"),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),

            SizedBox(height: 12),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            SizedBox(height: 12),

            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: "City (optional)",
              ),
            ),

            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text("Register"),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
              child: Text("Already have an account? Login"),
            ),

          ],
        ),
      ),

    );
  }
}