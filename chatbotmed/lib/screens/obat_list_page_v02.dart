// lib/screens/obat_list_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';  // Add this line at the top of the file
import '../services/device_service.dart';
import '../models/obat.dart';
import 'package:intl/intl.dart';

class ObatListPage extends StatefulWidget {
  const ObatListPage({super.key});

  @override
  State<ObatListPage> createState() => _ObatListPageState();
}

class _ObatListPageState extends State<ObatListPage> {
  List<Obat> obatList = [];
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _dosisController = TextEditingController();
  final TextEditingController _jumlahDosisController = TextEditingController();
  final TextEditingController _usageController = TextEditingController();
  List<TimeOfDay> _selectedTimes = [];
  DateTime? _purchaseDate;
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

  Future<void> _saveObat() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = obatList.map((obat) => jsonEncode(obat.toJson())).toList();
    await prefs.setStringList(obatKey, jsonList);
  }

  Future<void> _addObat() async {
    if (_namaController.text.isEmpty || 
        _qtyController.text.isEmpty ||
        _dosisController.text.isEmpty ||
        _jumlahDosisController.text.isEmpty ||
        _selectedTimes.isEmpty ||
        _purchaseDate == null ||
        _usageController.text.isEmpty) {
      return;
    }

    final newObat = Obat(
      nama: _namaController.text,
      qty: int.parse(_qtyController.text),
      dosisPerHari: int.parse(_dosisController.text),
      jumlahPerDosis: int.parse(_jumlahDosisController.text),
      jadwal: _selectedTimes,
      purchaseDate: _purchaseDate!,
      usageNotes: _usageController.text,
    );

    setState(() {
      obatList.add(newObat);
      _resetForm();
    });

    await _saveObat();
  }

  Future<void> _confirmTaken(int index) async {
    setState(() {
      obatList[index].confirmTaken();
    });
    await _saveObat();
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTimes.add(time);
        _selectedTimes.sort((a, b) => a.hour.compareTo(b.hour));
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  void _resetForm() {
    _namaController.clear();
    _qtyController.clear();
    _dosisController.clear();
    _jumlahDosisController.clear();
    _usageController.clear();
    _selectedTimes = [];
    _purchaseDate = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Obat'),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () => Navigator.pushNamed(context, '/chatbot'),
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/obat-history'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: obatList.length,
                itemBuilder: (context, index) {
                  final obat = obatList[index];
                  return Card(
                    child: ListTile(
                      title: Text(obat.nama),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Stok: ${obat.qty}'),
                          Text('Dosis: ${obat.jumlahPerDosis}x${obat.dosisPerHari}/hari'),
                          Text('Jadwal: ${obat.jadwal.map((t) => t.format(context)).join(', ')}'),
                          if (obat.perluBeliObat())
                            Text('Perlu beli obat!', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () => _confirmTaken(index),
                      ),
                      onTap: () => _showObatDetails(context, obat),
                    ),
                  );
                },
              ),
            ),
            // Add obat form
            Column(
              children: [
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(labelText: 'Nama Obat'),
                ),
                TextField(
                  controller: _qtyController,
                  decoration: InputDecoration(labelText: 'Jumlah Stok'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _dosisController,
                  decoration: InputDecoration(labelText: 'Dosis per Hari'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _jumlahDosisController,
                  decoration: InputDecoration(labelText: 'Jumlah per Dosis'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _usageController,
                  decoration: InputDecoration(labelText: 'Catatan Penggunaan'),
                ),
                ListTile(
                  title: Text(_purchaseDate == null
                      ? 'Pilih Tanggal Pembelian'
                      : 'Dibeli: ${DateFormat('dd/MM/yyyy').format(_purchaseDate!)}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                ListTile(
                  title: Text(_selectedTimes.isEmpty
                      ? 'Tambah Jadwal Minum'
                      : 'Jadwal: ${_selectedTimes.map((t) => t.format(context)).join(', ')}'),
                  trailing: Icon(Icons.access_time),
                  onTap: () => _selectTime(context),
                ),
                ElevatedButton(
                  onPressed: _addObat,
                  child: Text('Tambah Obat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showObatDetails(BuildContext context, Obat obat) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(obat.nama, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Stok: ${obat.qty}'),
              Text('Dosis: ${obat.jumlahPerDosis}x${obat.dosisPerHari}/hari'),
              Text('Kebutuhan per Hari: ${obat.kebutuhanPerHari}'),
              Text('Dibeli: ${DateFormat('dd/MM/yyyy').format(obat.purchaseDate)}'),
              Text('Perlu beli lagi: ${DateFormat('dd/MM/yyyy').format(obat.nextPurchaseDate)}'),
              Text('Catatan: ${obat.usageNotes}'),
              SizedBox(height: 16),
              Text('Riwayat Penggunaan:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: obat.takenDates.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(DateFormat('dd/MM/yyyy HH:mm').format(obat.takenDates[index])),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}