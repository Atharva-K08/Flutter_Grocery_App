import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/suggestion_model.dart';
import '../../suggestions/services/suggestion_service.dart';
import '../services/item_service.dart';

class AddItemSheet extends StatefulWidget {
  final VoidCallback onItemAdded;

  const AddItemSheet({required this.onItemAdded});

  @override
  _AddItemSheetState createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {

  final _nameController     = TextEditingController();
  final _quantityController = TextEditingController(text: "1");
  final _priceController    = TextEditingController(text: "0");
  final _noteController     = TextEditingController();

  final _itemService       = ItemService();
  final _suggestionService = SuggestionService();

  String _selectedUnit = "pcs";
  bool _isLoading      = false;

  List<Suggestion> _suggestions = [];
  bool _showSuggestions         = false;

  /*
  DEBOUNCE TIMER
  */
  Future<void> _onNameChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _suggestions     = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      final results = await _suggestionService.getSuggestions(search: value);
      setState(() {
        _suggestions     = results;
        _showSuggestions = results.isNotEmpty;
      });
    } catch (_) {}
  }

  /*
  FILL FORM FROM SUGGESTION
  */
  void _applySuggestion(Suggestion s) {
    _nameController.text     = s.name;
    _quantityController.text = s.quantity.toString();
    setState(() {
      _selectedUnit    = s.unit;
      _suggestions     = [];
      _showSuggestions = false;
    });
  }

  void _submit() async {
    final name     = _nameController.text.trim();
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final price    = double.tryParse(_priceController.text) ?? 0;
    final note     = _noteController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Item name is required")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _itemService.createItem(
        name:     name,
        quantity: quantity,
        unit:     _selectedUnit,
        note:     note,
        price:    price,
      );
      Navigator.pop(context);
      widget.onItemAdded();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              "Add Item",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            // Name field + suggestion dropdown
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Item name"),
              onChanged: _onNameChanged,
            ),

            if (_showSuggestions)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final s = _suggestions[index];
                    return ListTile(
                      dense: true,
                      title: Text(s.name),
                      subtitle: Text("${s.quantity} ${s.unit}"),
                      trailing: Text(
                        "used ${s.usageCount}x",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () => _applySuggestion(s),
                    );
                  },
                ),
              ),

            SizedBox(height: 12),

            // Quantity + Unit row
            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(labelText: "Quantity"),
                    keyboardType: TextInputType.number,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: InputDecoration(labelText: "Unit"),
                    items: AppConstants.units.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedUnit = val);
                    },
                  ),
                ),

              ],
            ),

            SizedBox(height: 12),

            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: "Price per unit (optional)",
                prefixText: "₹ ",
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),

            SizedBox(height: 12),

            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: "Note (optional)"),
            ),

            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text("Add Item"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}