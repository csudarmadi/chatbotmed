import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/obat_service.dart';

class ObatHistoryPage extends StatefulWidget {
  const ObatHistoryPage({super.key});

  @override
  State<ObatHistoryPage> createState() => _ObatHistoryPageState();
}

class _ObatHistoryPageState extends State<ObatHistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyFuture;
  final DateFormat _dateFormat = DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'id_ID');
  bool _showMissedDoses = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = _showMissedDoses 
          ? ObatService.getMissedDoses()
          : ObatService.getConsumptionHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Obat'),
        actions: [
          IconButton(
            icon: Icon(_showMissedDoses ? Icons.medical_services : Icons.warning),
            onPressed: () {
              setState(() {
                _showMissedDoses = !_showMissedDoses;
                _loadHistory();
              });
            },
            tooltip: _showMissedDoses ? 'Lihat Riwayat' : 'Lihat Yang Terlewat',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return Center(
              child: Text(_showMissedDoses
                  ? 'Tidak ada obat yang terlewat'
                  : 'Belum ada riwayat konsumsi'),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    _showMissedDoses ? Icons.warning : Icons.medical_services,
                    color: _showMissedDoses ? Colors.orange : Colors.green,
                  ),
                  title: Text(entry['medicine']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_dateFormat.format(entry[_showMissedDoses 
                          ? 'scheduledTime' 
                          : 'date'])),
                      if (!_showMissedDoses && entry['notes']?.isNotEmpty == true)
                        Text('Catatan: ${entry['notes']}'),
                    ],
                  ),
                  trailing: Text('${entry['dose']} dosis'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}