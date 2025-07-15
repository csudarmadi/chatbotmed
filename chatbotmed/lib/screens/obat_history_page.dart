// lib/screens/obat_history_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';  // Add this line at the top of the file
import '../services/device_service.dart';
import '../models/obat.dart';
import 'package:intl/intl.dart';

class ObatHistoryPage extends StatefulWidget {
  const ObatHistoryPage({super.key});

  @override
  State<ObatHistoryPage> createState() => _ObatHistoryPageState();
}

class _ObatHistoryPageState extends State<ObatHistoryPage> {
  List<Obat> obatList = [];
  late String deviceID;
  late String obatKey;

  @override
  void initState() {
    super.initState();
    _loadObat();
  }

  Future<void> _loadObat() async {
    deviceID = await DeviceService.getDeviceId();
    obatKey = 'obatList_$deviceID';
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(obatKey) ?? [];
    setState(() {
      obatList = jsonList.map((json) => Obat.fromJson(jsonDecode(json))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Obat'),
      ),
      body: ListView.builder(
        itemCount: obatList.length,
        itemBuilder: (context, index) {
          final obat = obatList[index];
          return ExpansionTile(
            title: Text(obat.nama),
            subtitle: Text('Stok: ${obat.qty}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dosis: ${obat.jumlahPerDosis}x${obat.dosisPerHari}/hari'),
                    Text('Dibeli: ${DateFormat('dd/MM/yyyy').format(obat.purchaseDate)}'),
                    Text('Perlu beli lagi: ${DateFormat('dd/MM/yyyy').format(obat.nextPurchaseDate)}'),
                    SizedBox(height: 8),
                    Text('Riwayat Penggunaan:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...obat.takenDates.map((date) => 
                      ListTile(
                        title: Text(DateFormat('dd/MM/yyyy HH:mm').format(date)),
                      )
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}