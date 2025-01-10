import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class ReportService {
  static const String _baseUrl = 'http://192.168.18.45/barucoba/backend/report_crud.php';

  /// Fungsi untuk mengambil laporan dari server
  static Future<List<dynamic>> fetchReports() async {
    final url = '$_baseUrl?action=fetch';
    print('Fetching reports from: $url'); // Debug URL

    try {
      final response = await http.get(Uri.parse(url));
      print('Response status code: ${response.statusCode}'); // Debug status code
      print('Response body: ${response.body}'); // Debug response body

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['reports'];
        } else {
          throw Exception('Server error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to fetch reports. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred during fetchReports: $e'); // Debug error
      throw Exception('An error occurred during fetchReports: $e');
    }
  }

  /// Fungsi untuk menyimpan transaksi ke laporan
  static Future<void> saveTransactionsToReport(List<Transaction> transactions) async {
    final url = '$_baseUrl?action=save';
    print('Saving transactions to report at: $url'); // Debug URL

    try {
      final requestBody = {'transactions': transactions.map((t) => t.toJson()).toList()};
      print('Request body: ${jsonEncode(requestBody)}'); // Debug request body

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status code: ${response.statusCode}'); // Debug status code
      print('Response body: ${response.body}'); // Debug response body

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!data['success']) {
          throw Exception('Server error: ${data['message']}');
        }
        print('Transactions successfully saved to report');
      } else {
        throw Exception('Failed to save transactions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while saving transactions: $e'); // Debug error
      throw Exception('An error occurred while saving transactions: $e');
    }
  }

  /// Fungsi untuk menghapus laporan
  static Future<void> deleteReport(int id) async {
    final url = '$_baseUrl?action=delete';
    print('Deleting report with ID: $id at: $url'); // Debug URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      print('Response status code: ${response.statusCode}'); // Debug status code
      print('Response body: ${response.body}'); // Debug response body

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!data['success']) {
          throw Exception('Server error: ${data['message']}');
        }
        print('Report with ID: $id successfully deleted');
      } else {
        throw Exception('Failed to delete report. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while deleting report: $e'); // Debug error
      throw Exception('An error occurred while deleting report: $e');
    }
  }
}
