import 'package:hive_flutter/hive_flutter.dart';

class DatabaseHelper {
  // Singleton pattern agar mudah dipanggil
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  final String _boxName = "kalkulatorBox";

  // Fungsi simpan data (Create)
  Future<void> insertNote(Map<String, dynamic> row) async {
    var box = Hive.box(_boxName);
    await box.add(row);
  }

  // Fungsi ambil semua data (Read)
  Future<List<Map<String, dynamic>>> queryAllNotes() async {
    var box = Hive.box(_boxName);
    // Mengambil data dan menambahkan 'id' otomatis dari key Hive
    return box.keys.map((key) {
      final item = box.get(key);
      return {
        'id': key, // Kita gunakan key Hive sebagai ID untuk hapus
        'title': item['title'],
        'expression': item['expression'],
        'result': item['result'],
      };
    }).toList().reversed.toList(); // Balik agar yang terbaru di atas
  }

  // Fungsi hapus (Delete)
  Future<void> deleteNote(int id) async {
    var box = Hive.box(_boxName);
    await box.delete(id);
  }

  // Fungsi hapus semua
  Future<void> clearAll() async {
    var box = Hive.box(_boxName);
    await box.clear();
  }
}