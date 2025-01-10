import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  static const String _baseUrl = 'http://192.168.18.45/barucoba/backend/user_crud.php';

  /// Fungsi untuk registrasi pengguna baru
  static Future<Map<String, dynamic>> register(String username, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=register'),
        body: {
          'username': username,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Unknown error occurred',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to connect to server. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  /// Fungsi untuk mengambil daftar pengguna
  static Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?action=fetch'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['users'] as List).map((user) => User.fromJson(user)).toList();
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to connect to server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching users: $e');
    }
  }

  /// Fungsi untuk memperbarui data pengguna
  static Future<Map<String, dynamic>> updateUser(
    int id,
    String username,
    String role, {
    String? password, // Password bersifat opsional
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=update'),
        body: {
          'id': id.toString(),
          'username': username,
          'role': role,
          if (password != null) 'password': password, // Kirim password jika ada
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Unknown error occurred',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to connect to server. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  /// Fungsi untuk menghapus pengguna
  static Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=delete'),
        body: {
          'id': id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Unknown error occurred',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to connect to server. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }
}
