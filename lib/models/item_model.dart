class Item {

  final String id;
  final String userId;
  final String name;
  final String? note;
  final int quantity;
  final String unit;
  final double price;
  final double totalPrice;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.userId,
    required this.name,
    this.note,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.totalPrice,
    required this.isPurchased,
    this.purchasedAt,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id:          json["_id"],
      userId:      json["userId"],
      name:        json["name"],
      note:        json["note"],
      quantity:    json["quantity"],
      unit:        json["unit"],
      price:       (json["price"] ?? 0).toDouble(),
      totalPrice:  (json["totalPrice"] ?? 0).toDouble(),
      isPurchased: json["isPurchased"] ?? false,
      purchasedAt: json["purchasedAt"] != null
          ? DateTime.parse(json["purchasedAt"])
          : null,
      createdAt:   DateTime.parse(json["createdAt"]),
    );
  }

  // Useful for update calls
  Map<String, dynamic> toJson() {
    return {
      "name":     name,
      "note":     note,
      "quantity": quantity,
      "unit":     unit,
      "price":    price,
    };
  }

}