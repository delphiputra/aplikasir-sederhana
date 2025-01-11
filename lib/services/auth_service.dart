
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _baseUrl = 'http://192.168.18.45/barucoba/backend/user_crud.php';

  // Fungsi Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl?action=login'); // Tambahkan parameter 'action=login'
    try {
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          // Simpan role pengguna ke SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('role', data['data']['role']); // Simpan role pengguna
        }

        return {
          'success': data['success'],
          'message': data['message'],
          'data': data['data'], // Data pengguna (id, username, role)
        };
      } else {
        throw Exception('Gagal terhubung ke server. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Fungsi untuk mendapatkan role pengguna
  static Future<String?> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role'); // Ambil role dari SharedPreferences
  }

  // Fungsi Logout
  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('role'); // Hapus role dari SharedPreferences saat logout
  }

  // Fungsi Registrasi
  static Future<Map<String, dynamic>> register(String username, String password, String role) async {
    final url = Uri.parse('$_baseUrl?action=register'); // Tambahkan parameter 'action=register'
    try {
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'],
          'message': data['message'],
        };
      } else {
        throw Exception('Gagal melakukan registrasi. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
