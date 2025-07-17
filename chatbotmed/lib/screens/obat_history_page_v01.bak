// lib/screens/obat_history_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/history.dart';
import '../services/history_service.dart';

class ObatHistoryPage extends StatefulWidget {
  const ObatHistoryPage({super.key});

  @override
  State<ObatHistoryPage> createState() => _ObatHistoryPageState();
}

class _ObatHistoryPageState extends State<ObatHistoryPage> {
  late Future<List<MedicationHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = HistoryService.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Minum Obat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await HistoryService.clearHistory();
              _refreshHistory();
            },
            tooltip: 'Hapus Riwayat',
          ),
        ],
      ),
      body: FutureBuilder<List<MedicationHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final historyList = snapshot.data ?? [];
          
          if (historyList.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat minum obat'),
            );
          }

          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    history.wasTaken ? Icons.check : Icons.close,
                    color: history.wasTaken ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    history.medicineName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dosis: ${history.dosage}'),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'id_ID')
                            .format(history.takenTime),
                      ),
                    ],
                  ),
                  trailing: Text(
                    history.wasTaken ? 'Dikonsumsi' : 'Terlewat',
                    style: TextStyle(
                      color: history.wasTaken ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}