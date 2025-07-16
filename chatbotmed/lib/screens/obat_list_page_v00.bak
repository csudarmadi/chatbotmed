// lib/screens/obat_list_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/device_service.dart';

class ObatListPage extends StatefulWidget {
  const ObatListPage({super.key});

  @override
  State<ObatListPage> createState() => _ObatListPageState();
}

class _ObatListPageState extends State<ObatListPage> {
  List<String> obatList = [];
  final TextEditingController _obatController = TextEditingController();
  late String deviceID;
  late String obatKey;
  late String nama;

  @override
  void initState() {
    super.initState();
    _loadObat();
  }

  Future<void> _loadObat() async {
    deviceID = await DeviceService.getDeviceId();
    obatKey = 'obatList__$deviceID';
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nama = prefs.getString('nama') ?? 'Pasien';
      obatList = prefs.getStringList(obatKey) ?? [];
    });
  }

  Future<void> _addObat(String namaObat) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      obatList.add(namaObat);
      prefs.setStringList(obatKey, obatList);
      _obatController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: 
        AppBar(
          title: Text('Halo, $nama'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('username');
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Daftar Obat yang Anda Konsumsi:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: obatList.length,
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(Icons.medication),
                  title: Text(obatList[i]),
                ),
              ),
            ),
            const Divider(),
            TextField(
              controller: _obatController,
              decoration: const InputDecoration(
                labelText: 'Tambah Obat',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_obatController.text.trim().isNotEmpty) {
                  _addObat(_obatController.text.trim());
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }
}
