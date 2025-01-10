import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class TransactionService {
  static const String _baseUrl = 'http://192.168.18.45/barucoba/backend/transaction_crud.php';

  /// Fetch Transactions
  static Future<List<Transaction>> fetchTransactions() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?action=fetch'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          return (data['transactions'] as List)
              .map((transaction) => Transaction.fromJson(transaction))
              .toList();
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to fetch transactions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  /// Add Transaction
  static Future<void> addTransaction(int menuId, int quantity, double totalPrice) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=add'),
        body: {
          'menu_id': menuId.toString(),
          'quantity': quantity.toString(),
          'total_price': totalPrice.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data['success']) {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to add transaction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  /// Delete Transaction
  static Future<void> deleteTransaction(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=delete'),
        body: {
          'id': id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data['success']) {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to delete transaction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  /// Clear All Transactions
  static Future<void> clearTransactions() async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl?action=clear'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data['success']) {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to clear transactions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error clearing transactions: $e');
    }
  }
}
