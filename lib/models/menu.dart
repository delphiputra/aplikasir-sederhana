class Menu {
  final int id;
  final String name;
  final double price;

  Menu({
    required this.id,
    required this.name,
    required this.price,
  });

  /// Membuat objek `Menu` dari JSON
  factory Menu.fromJson(Map<String, dynamic> json) {
    try {
      return Menu(
        id: int.parse(json['id'].toString()), // Parsing ID ke integer
        name: json['name'] ?? 'Unknown', // Default nilai jika name null
        price: double.parse(json['price'].toString()), // Parsing price ke double
      );
    } catch (e) {
      throw Exception('Error parsing menu JSON: $e');
    }
  }

  /// Mengonversi objek `Menu` menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}
