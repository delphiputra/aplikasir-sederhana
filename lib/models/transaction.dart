class Transaction {
  final int id;
  final String menuName;
  final int quantity;
  final double totalPrice;

  Transaction({
    required this.id,
    required this.menuName,
    required this.quantity,
    required this.totalPrice,
  });

  /// Konversi objek `Transaction` ke format JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_name': menuName,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }

  /// Konversi dari JSON ke objek `Transaction`
  factory Transaction.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id') ||
        !json.containsKey('menu_name') ||
        !json.containsKey('quantity') ||
        !json.containsKey('total_price')) {
      throw Exception("Invalid JSON structure for Transaction.");
    }

    return Transaction(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      menuName: json['menu_name'] ?? '',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 0,
      totalPrice: json['total_price'] is double
          ? json['total_price']
          : double.tryParse(json['total_price'].toString()) ?? 0.0,
    );
  }
}
