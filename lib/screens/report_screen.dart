import 'package:flutter/material.dart';
import '../services/report_service.dart'; // Pastikan file ini diimpor dengan benar

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  /// Fungsi untuk mengambil laporan dari server dan menggabungkan data dengan menu yang sama
  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await ReportService.fetchReports();

      // Gabungkan laporan dengan menu yang sama
      final mergedReports = <String, Map<String, dynamic>>{};
      for (var report in reports) {
        final menuName = report['menu_name'];
        if (mergedReports.containsKey(menuName)) {
          mergedReports[menuName]!['quantity'] += report['quantity'];
          mergedReports[menuName]!['total_price'] += report['total_price'];
        } else {
          mergedReports[menuName] = {
            'menu_name': menuName,
            'quantity': report['quantity'],
            'total_price': report['total_price'],
            'created_at': report['created_at'], // Ambil tanggal pertama
            'id': report['id'], // Simpan ID untuk penghapusan
          };
        }
      }

      setState(() {
        _reports = mergedReports.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error fetching reports: $e');
    }
  }

  /// Fungsi untuk menghapus laporan berdasarkan ID
  Future<void> _deleteReport(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Laporan'),
          content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await ReportService.deleteReport(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchReports(); // Refresh daftar laporan
      } catch (e) {
        _showError('Error deleting report: $e');
      }
    }
  }

  /// Fungsi untuk menampilkan pesan kesalahan
  void _showError(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Laporan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada laporan.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Menu: ${report['menu_name']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jumlah: ${report['quantity']}'),
                            Text('Total Harga: Rp ${report['total_price']}'),
                            Text('Tanggal: ${report['created_at']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteReport(report['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
