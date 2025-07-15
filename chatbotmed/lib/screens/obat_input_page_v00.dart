import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/obat.dart';
import '../services/obat_service.dart';

class ObatInputPage extends StatefulWidget {
  final Obat? obat;

  const ObatInputPage({super.key, this.obat});

  @override
  State<ObatInputPage> createState() => _ObatInputPageState();
}

class _ObatInputPageState extends State<ObatInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _qtyController = TextEditingController();
  final _dosisController = TextEditingController();
  final _jumlahDosisController = TextEditingController();
  final _usageController = TextEditingController();
  List<TimeOfDay> _selectedTimes = [];
  DateTime? _purchaseDate;

  @override
  void initState() {
    super.initState();
    if (widget.obat != null) {
      _initializeFormWithExistingData();
    }
  }

  void _initializeFormWithExistingData() {
    final obat = widget.obat!;
    _namaController.text = obat.nama;
    _qtyController.text = obat.qty.toString();
    _dosisController.text = obat.dosisPerHari.toString();
    _jumlahDosisController.text = obat.jumlahPerDosis.toString();
    _usageController.text = obat.usageNotes;
    _selectedTimes = List.from(obat.jadwal);
    _purchaseDate = obat.purchaseDate;
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null && mounted) {
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
    if (picked != null && mounted) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  Future<void> _saveObat() async {
    if (!_formKey.currentState!.validate()) return;

    final obat = Obat(
      nama: _namaController.text,
      qty: int.parse(_qtyController.text),
      dosisPerHari: int.parse(_dosisController.text),
      jumlahPerDosis: int.parse(_jumlahDosisController.text),
      jadwal: _selectedTimes,
      purchaseDate: _purchaseDate ?? DateTime.now(),
      usageNotes: _usageController.text,
    );

    try {
      if (widget.obat == null) {
        await ObatService.saveObat(obat);
      } else {
        await ObatService.updateObat(obat);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _removeTime(int index) {
    setState(() {
      _selectedTimes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.obat == null ? 'Tambah Obat Baru' : 'Edit Obat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveObat,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Obat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama obat harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Stok',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah stok harus diisi';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _dosisController,
                      decoration: const InputDecoration(
                        labelText: 'Dosis per Hari',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Dosis harus diisi';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahDosisController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah per Dosis',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah per dosis harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usageController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Penggunaan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _purchaseDate == null
                      ? 'Pilih Tanggal Pembelian'
                      : 'Tanggal Pembelian: ${DateFormat('dd/MM/yyyy').format(_purchaseDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              const Text(
                'Jadwal Minum:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_selectedTimes.isEmpty)
                const Text('Belum ada jadwal ditambahkan'),
              ..._selectedTimes.map((time) => ListTile(
                    title: Text(time.format(context)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeTime(_selectedTimes.indexOf(time)),
                    ),
                  )),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: const Text('Tambah Jadwal Minum'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveObat,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.obat == null ? 'Simpan Obat' : 'Update Obat',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _qtyController.dispose();
    _dosisController.dispose();
    _jumlahDosisController.dispose();
    _usageController.dispose();
    super.dispose();
  }
}