import 'package:flutter/material.dart';
import '../../../models/item_model.dart';
import '../services/item_service.dart';
import '../widgets/add_item_sheet.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final _itemService      = ItemService();
  List<Item> _items       = [];
  bool _isLoading         = true;
  int _currentPage        = 1;
  int _totalPages         = 1;
  bool _loadingMore       = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _currentPage < _totalPages) {
      _loadMore();
    }
  }

  Future<void> _loadItems({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _items       = [];
      });
    }

    if (!refresh) {
      setState(() => _isLoading = true);
    }

    try {
      final result = await _itemService.getItems(page: _currentPage);
      setState(() {
        _items      = List<Item>.from(result["items"]);
        _totalPages = result["pages"];
        _isLoading  = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final result = await _itemService.getItems(page: _currentPage + 1);
      setState(() {
        _currentPage++;
        _items.addAll(result["items"]);
        _loadingMore = false;
      });
    } catch (e) {
      setState(() => _loadingMore = false);
    }
  }

  /*
  PURCHASE DIALOG
  */
  void _showPurchaseDialog(Item item) {
    final _priceController = TextEditingController(
      text: item.price > 0 ? item.price.toStringAsFixed(0) : "",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Mark as Purchased"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              item.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            SizedBox(height: 4),

            Text(
              "${item.quantity} ${item.unit}",
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 20),

            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: "Price per unit",
                prefixText: "₹ ",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),

            SizedBox(height: 8),

            ValueListenableBuilder(
              valueListenable: _priceController,
              builder: (context, value, _) {
                final price = double.tryParse(_priceController.text) ?? 0;
                final total = price * item.quantity;
                return Text(
                  "Total: ₹${total.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                );
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
              final price = double.tryParse(_priceController.text) ?? 0;
              Navigator.pop(context);
              _purchaseItem(item, price: price);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  /*
  PURCHASE ITEM
  */
  Future<void> _purchaseItem(Item item, {double? price}) async {
    try {
      final updated = await _itemService.purchaseItem(
        item.id,
        price: price,
      );
      setState(() {
        final index = _items.indexWhere((i) => i.id == updated.id);
        if (index != -1) _items[index] = updated;
      });
      _showSuccess("${item.name} marked as purchased");
    } catch (e) {
      _showError(e.toString());
    }
  }

  /*
  DELETE ITEM
  */
  Future<void> _deleteItem(Item item) async {
    final index = _items.indexWhere((i) => i.id == item.id);

    setState(() => _items.removeWhere((i) => i.id == item.id));

    try {
      await _itemService.deleteItem(item.id);
      _showSuccess("${item.name} removed");
    } catch (e) {
      setState(() => _items.insert(index, item));
      _showError(e.toString());
    }
  }

  /*
  CLEAR LIST DIALOG
  */
  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Clear List"),
        content: Text("What would you like to remove?"),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearItems(onlyUnpurchased: true);
            },
            child: Text(
              "Unpurchased only",
              style: TextStyle(color: Colors.orange),
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearItems(onlyUnpurchased: false);
            },
            child: Text(
              "Clear all",
              style: TextStyle(color: Colors.red),
            ),
          ),

        ],
      ),
    );
  }

  /*
  CLEAR ITEMS
  */
  Future<void> _clearItems({required bool onlyUnpurchased}) async {
    final toDelete = onlyUnpurchased
        ? _items.where((i) => !i.isPurchased).toList()
        : List<Item>.from(_items);

    if (toDelete.isEmpty) {
      _showError(
        onlyUnpurchased
            ? "No unpurchased items to clear"
            : "List is already empty",
      );
      return;
    }

    setState(() {
      if (onlyUnpurchased) {
        _items.removeWhere((i) => !i.isPurchased);
      } else {
        _items.clear();
      }
    });

    try {
      await _itemService.clearItems(toDelete.map((i) => i.id).toList());
      _showSuccess(
        "${toDelete.length} item${toDelete.length > 1 ? 's' : ''} removed",
      );
    } catch (e) {
      setState(() => _items.addAll(toDelete));
      _showError("Failed to clear list. Please try again.");
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

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddItemSheet(
        onItemAdded: () => _loadItems(refresh: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("My Grocery List"),
        actions: [

          IconButton(
            icon: Icon(Icons.delete_sweep_outlined),
            onPressed: _items.isEmpty ? null : _showClearDialog,
            tooltip: "Clear list",
          ),

          IconButton(
            icon: Icon(Icons.lightbulb_outline),
            onPressed: () async {
              await Navigator.pushNamed(context, "/suggestions");
              _loadItems(refresh: true);
            },
            tooltip: "Quick Add",
          ),

          IconButton(
            icon: Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.pushNamed(context, "/profile"),
          ),

          IconButton(
            icon: Icon(Icons.bar_chart_outlined),
            onPressed: () => Navigator.pushNamed(context, "/spend"),
          ),

        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        child: Icon(Icons.add),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
        onRefresh: () => _loadItems(refresh: true),
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(12),
          itemCount: _items.length + (_loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _items.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _buildSwipeableCard(_items[index]);
          },
        ),
      ),
    );
  }

  Widget _buildSwipeableCard(Item item) {
    if (item.isPurchased) {
      return _buildItemCard(item);
    }

    return Dismissible(
      key: Key(item.id),

      background: Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              "Purchased",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      secondaryBackground: Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
          ],
        ),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await Future.delayed(Duration(milliseconds: 150));
          _showPurchaseDialog(item);
          return false;
        } else {
          return await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Delete Item"),
              content: Text("Remove \"${item.name}\" from your list?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ) ?? false;
        }
      },

      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteItem(item);
        }
      },

      child: _buildItemCard(item),
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        leading: Icon(
          item.isPurchased
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: item.isPurchased ? Colors.green : Colors.grey,
          size: 28,
        ),

        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: item.isPurchased
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: item.isPurchased ? Colors.grey : null,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 4),

            Text("${item.quantity} ${item.unit}"),

            if (item.note != null && item.note!.isNotEmpty)
              Text(
                item.note!,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

            if (item.isPurchased && item.purchasedAt != null)
              Text(
                "Bought on ${_formatDate(item.purchasedAt!)}",
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),

          ],
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            if (item.totalPrice > 0)
              Text(
                "₹${item.totalPrice.toStringAsFixed(0)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: item.isPurchased ? Colors.green : Colors.black87,
                ),
              ),

            if (!item.isPurchased)
              Text(
                "swipe to act",
                style: TextStyle(fontSize: 10, color: Colors.grey),
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
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No items yet",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            "Tap + to add your first item",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}