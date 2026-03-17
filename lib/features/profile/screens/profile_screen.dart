import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final _profileService = ProfileService();
  final _authService    = AuthService();

  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving  = false;

  final _usernameController = TextEditingController();
  final _cityController     = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _profileService.getProfile();
      setState(() {
        _user                  = user;
        _usernameController.text = user.username;
        _cityController.text     = user.city ?? "";
        _isLoading             = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final updated = await _profileService.updateProfile(
        username: _usernameController.text.trim(),
        city:     _cityController.text.trim(),
      );
      setState(() {
        _user      = updated;
        _isEditing = false;
        _isSaving  = false;
      });
      _showSuccess("Profile updated");
    } catch (e) {
      setState(() => _isSaving = false);
      _showError(e.toString());
    }
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, "/login");
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
        title: Text("Profile"),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing               = false;
                  _usernameController.text = _user?.username ?? "";
                  _cityController.text     = _user?.city ?? "";
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.green.shade100,
              child: Text(
                _user?.username.substring(0, 1).toUpperCase() ?? "?",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),

            SizedBox(height: 24),

            // Username field
            TextField(
              controller: _usernameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: "Username",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),

            SizedBox(height: 12),

            // Email (read only always)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: _user?.email ?? "",
                prefixIcon: Icon(Icons.email_outlined),
              ),
              controller: TextEditingController(
                text: _user?.email ?? "",
              ),
            ),

            SizedBox(height: 12),

            // City field
            TextField(
              controller: _cityController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: "City",
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),

            SizedBox(height: 8),

            // Member since
            if (_user != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Member since ${_user!.createdAt.year}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),

            SizedBox(height: 24),

            // Save button (only in edit mode)
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text("Save Changes"),
                ),
              ),

          ],
        ),
      ),
    );
  }
}