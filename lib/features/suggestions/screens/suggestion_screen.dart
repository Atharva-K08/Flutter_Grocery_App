import 'package:flutter/material.dart';
import '../../../models/suggestion_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../suggestions/services/suggestion_service.dart';
import '../../items/services/item_service.dart';

class SuggestionScreen extends StatefulWidget {
  @override
  _SuggestionScreenState createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {

  final _suggestionService = SuggestionService();
  final _itemService       = ItemService();
  final _searchController  = TextEditingController();

  List<Suggestion> _suggestions    = [];
  List<Suggestion> _allSuggestions = [];
  bool _isLoading                  = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    try {
      final results = await _suggestionService.getSuggestions();
      setState(() {
        _allSuggestions = results;
        _suggestions    = results;
        _isLoading      = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  /*
  LOCAL SEARCH FILTER
  */
  void _onSearch(String value) {
    final query = value.toLowerCase().trim();
    setState(() {
      _suggestions = _allSuggestions
          .where((s) => s.name.toLowerCase().contains(query))
          .toList();
    });
  }

  /*
  QUANTITY + UNIT DIALOG
  */
  void _showQuantityDialog(Suggestion suggestion) {
    final _quantityController = TextEditingController(
      text: suggestion.quantity.toString(),
    );

    String _selectedUnit = suggestion.unit;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(

          title: Text("Add to List"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Item name
              Text(
                suggestion.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              SizedBox(height: 6),

              Text(
                "Used ${suggestion.usageCount}x",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              SizedBox(height: 20),

              // Quantity row with +/- buttons
              Row(
                children: [

                  IconButton(
                    onPressed: () {
                      final current =
                          int.tryParse(_quantityController.text) ?? 1;
                      if (current > 1) {
                        _quantityController.text = (current - 1).toString();
                      }
                    },
                    icon: Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                  ),

                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Quantity",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      final current =
                          int.tryParse(_quantityController.text) ?? 1;
                      _quantityController.text = (current + 1).toString();
                    },
                    icon: Icon(Icons.add_circle_outline),
                    color: Colors.green,
                  ),

                ],
              ),

              SizedBox(height: 16),

              // Unit dropdown
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: InputDecoration(
                  labelText: "Unit",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                items: AppConstants.units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => _selectedUnit = val);
                  }
                },
              ),

            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity =
                    int.tryParse(_quantityController.text) ?? 1;
                Navigator.pop(context);
                _addItemFromSuggestion(suggestion, quantity, _selectedUnit);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text("Add to List"),
            ),
          ],

        ),
      ),
    );
  }

  /*
  ADD ITEM FROM SUGGESTION
  */
  Future<void> _addItemFromSuggestion(
      Suggestion suggestion,
      int quantity,
      String unit,
      ) async {
    try {
      await _itemService.createItem(
        name:     suggestion.name,
        quantity: quantity,
        unit:     unit,
      );
      _showSuccess("\"${suggestion.name}\" added to your list");
      _loadSuggestions();
    } catch (e) {
      _showError(e.toString());
    }
  }

  /*
  DELETE SUGGESTION
  */
  void _showDeleteDialog(Suggestion suggestion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Remove Suggestion"),
        content: Text(
          "Remove \"${suggestion.name}\" from your suggestions?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSuggestion(suggestion);
            },
            child: Text(
              "Remove",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSuggestion(Suggestion suggestion) async {
    try {
      await _suggestionService.deleteSuggestion(suggestion.id);
      setState(() {
        _allSuggestions.removeWhere((s) => s.id == suggestion.id);
        _suggestions.removeWhere((s) => s.id == suggestion.id);
      });
      _showSuccess("\"${suggestion.name}\" removed from suggestions");
    } catch (e) {
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
        title: Text("Quick Add"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: "Search suggestions...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _suggestions.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
        onRefresh: _loadSuggestions,
        child: ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            return _buildSuggestionCard(_suggestions[index]);
          },
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(Suggestion suggestion) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        onTap: () => _showQuantityDialog(suggestion),

        leading: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          child: Text(
            suggestion.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(
          suggestion.name,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(
          "${suggestion.quantity} ${suggestion.unit}  ·  used ${suggestion.usageCount}x",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: () => _showQuantityDialog(suggestion),
              tooltip: "Add to list",
            ),

            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
              onPressed: () => _showDeleteDialog(suggestion),
              tooltip: "Remove suggestion",
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            Icons.lightbulb_outline,
            size: 64,
            color: Colors.grey,
          ),

          SizedBox(height: 16),

          Text(
            _searchController.text.isNotEmpty
                ? "No suggestions match your search"
                : "No suggestions yet",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),

          SizedBox(height: 8),

          Text(
            "Items you add will appear here automatically",
            style: TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),

        ],
      ),
    );
  }

}