import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu.dart';

class MenuService {
  static const String _baseUrl = 'http://192.168.18.45/barucoba/backend/menu_crud.php';

  /// Fetch Menus
  static Future<List<Menu>> fetchMenus() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?action=fetch'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          return (data['menus'] as List)
              .map((menu) => Menu.fromJson(menu))
              .toList();
        } else {
          throw Exception('Fetch failed: ${data['message']}');
        }
      } else {
        throw Exception('Failed to fetch menus. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching menus: $e');
    }
  }

  /// Add Menu
  static Future<void> addMenu(String name, double price) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=add'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'name': name,
          'price': price.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data['success']) {
          throw Exception('Add failed: ${data['message']}');
        }
      } else {
        throw Exception('Failed to add menu. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding menu: $e');
    }
  }

  /// Delete Menu
  static Future<void> deleteMenu(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=delete'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data['success']) {
          throw Exception('Delete failed: ${data['message']}');
        }
      } else {
        throw Exception('Failed to delete menu. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting menu: $e');
    }
  }

  /// Update Menu
  static Future<void> updateMenu(int id, String name, double price) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=update'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': id.toString(),
          'name': name,
          'price': price.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data['success']) {
          throw Exception('Update failed: ${data['message']}');
        }
      } else {
        throw Exception('Failed to update menu. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating menu: $e');
    }
  }
}
