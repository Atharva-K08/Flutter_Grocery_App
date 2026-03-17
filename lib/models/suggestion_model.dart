class Suggestion {

  final String id;
  final String userId;
  final String name;
  final int quantity;
  final String unit;
  final int usageCount;
  final DateTime lastUsed;

  Suggestion({
    required this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.usageCount,
    required this.lastUsed,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id:         json["_id"],
      userId:     json["userId"],
      name:       json["name"],
      quantity:   json["quantity"] ?? 1,
      unit:       json["unit"] ?? "NA",
      usageCount: json["usageCount"] ?? 1,
      lastUsed:   DateTime.parse(json["lastUsed"]),
    );
  }

}