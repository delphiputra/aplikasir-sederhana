import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/menu.dart';
import '../services/transaction_service.dart';
import '../services/report_service.dart';
import '../services/menu_service.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Transaction> _transactions = [];
  List<Menu> _menus = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _fetchMenus();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await TransactionService.fetchTransactions();
      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      _showErrorSnackbar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMenus() async {
    try {
      final menus = await MenuService.fetchMenus();
      setState(() {
        _menus = menus;
      });
    } catch (e) {
      _showErrorSnackbar('Error: $e');
    }
  }

  double _calculateTotal() {
    return _transactions.fold(0, (sum, transaction) => sum + transaction.totalPrice);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _finishOrder() async {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada transaksi untuk diselesaikan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ReportService.saveTransactionsToReport(_transactions);
      await TransactionService.clearTransactions();
      await _fetchTransactions();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan selesai. Transaksi dipindahkan ke laporan.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTransaction() async {
    String? selectedMenuId;
    int quantity = 1;
    double totalPrice = 0.0;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Transaksi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMenuId,
                items: _menus.map((menu) {
                  return DropdownMenuItem(
                    value: menu.id.toString(),
                    child: Text(menu.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMenuId = value;
                    if (value != null) {
                      final selectedMenu = _menus.firstWhere((menu) => menu.id.toString() == value);
                      totalPrice = selectedMenu.price * quantity;
                    }
                  });
                },
                decoration: const InputDecoration(labelText: 'Pilih Menu'),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Jumlah Pesanan'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    quantity = int.tryParse(value) ?? 1;
                    if (selectedMenuId != null) {
                      final selectedMenu = _menus.firstWhere((menu) => menu.id.toString() == selectedMenuId);
                      totalPrice = selectedMenu.price * quantity;
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              Text('Total Harga: Rp ${totalPrice.toStringAsFixed(0)}'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  if (selectedMenuId == null || quantity <= 0) {
                    _showErrorSnackbar('Mohon lengkapi data');
                    return;
                  }

                  try {
                    await TransactionService.addTransaction(
                      int.parse(selectedMenuId!),
                      quantity,
                      totalPrice,
                    );
                    Navigator.pop(context);
                    await _fetchTransactions();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaksi berhasil ditambahkan'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    _showErrorSnackbar('Error: $e');
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await TransactionService.deleteTransaction(id);
      await _fetchTransactions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Transaksi'),
        backgroundColor: Colors.teal.shade200,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: _transactions.isEmpty
                            ? const Center(child: Text('Tidak ada transaksi'))
                            : ListView.builder(
                                itemCount: _transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = _transactions[index];
                                  return Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.teal.shade100,
                                        child: const Icon(Icons.fastfood, color: Colors.teal),
                                      ),
                                      title: Text(
                                        transaction.menuName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                          'Jumlah: ${transaction.quantity}, Total: Rp ${transaction.totalPrice.toStringAsFixed(0)}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          await _deleteTransaction(transaction.id);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        child: ElevatedButton.icon(
                          onPressed: _addTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Tambah Transaksi',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Semua: Rp ${_calculateTotal().toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _finishOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Pesanan Selesai',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
