import 'package:flutter/material.dart';
import '../services/spend_service.dart';

class SpendScreen extends StatefulWidget {
  @override
  _SpendScreenState createState() => _SpendScreenState();
}

class _SpendScreenState extends State<SpendScreen> {

  final _spendService = SpendService();

  double _totalSpend = 0;
  bool _isLoading    = true;
  bool _isResetting  = false;

  @override
  void initState() {
    super.initState();
    _loadSpend();
  }

  Future<void> _loadSpend() async {
    try {
      final amount = await _spendService.getTotalSpend();
      setState(() {
        _totalSpend = amount;
        _isLoading  = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Reset Spend"),
        content: Text(
          "This will reset your total spend to ₹0. This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSpend();
            },
            child: Text(
              "Reset",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSpend() async {
    setState(() => _isResetting = true);

    try {
      await _spendService.resetSpend();
      setState(() {
        _totalSpend = 0;
        _isResetting = false;
      });
      _showSuccess("Spend reset to ₹0");
    } catch (e) {
      setState(() => _isResetting = false);
      _showError(e.toString());
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
        title: Text("Total Spend"),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadSpend,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(24),
          child: Column(
            children: [

              SizedBox(height: 40),

              // Spend card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [

                    Text(
                      "Total Spent",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade700,
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      "₹${_totalSpend.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),

                  ],
                ),
              ),

              SizedBox(height: 32),

              // Info text
              Text(
                "This is the total amount spent on all\npurchased items across your list.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 48),

              // Reset button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isResetting ? null : _showResetDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isResetting
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                      : Text("Reset Spend"),
                ),
              ),

            ],
          ),
        ),
      ),

    );
  }
}