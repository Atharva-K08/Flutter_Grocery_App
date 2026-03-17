class Spend {

  final String id;
  final String userId;
  final double amount;
  final DateTime lastUpdated;

  Spend({
    required this.id,
    required this.userId,
    required this.amount,
    required this.lastUpdated,
  });

  factory Spend.fromJson(Map<String, dynamic> json) {
    return Spend(
      id:          json["_id"],
      userId:      json["userId"],
      amount:      (json["amount"] ?? 0).toDouble(),
      lastUpdated: DateTime.parse(json["lastUpdated"]),
    );
  }

}