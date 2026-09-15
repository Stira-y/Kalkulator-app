import 'dart:convert'; // Ditambahkan untuk mengonversi data ke JSON String
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Mengaktifkan local storage

import 'kalkulator.dart';
import 'history.dart';
import 'profile.dart';

void main() => runApp(KalkulatorApp());

class KalkulatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0: Kalkulator, 1: History, 2: Profile
  
  // State untuk menyimpan data riwayat perhitungan
  List<Map<String, String>> _historyList = [];

  @override
  void initState() {
    super.initState();
    _loadHistory(); // Memuat data yang tersimpan otomatis saat aplikasi dibuka
  }

  // FITUR 3: Mengambil data dari Shared Preferences (Lokal HP / Chrome Browser)
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('calculator_history');
    if (historyString != null) {
      final List<dynamic> decodedList = jsonDecode(historyString);
      setState(() {
        // Mengonversi kembali dari data dynamic ke List<Map<String, String>>
        _historyList = decodedList.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  // Fungsi Helper: Menyimpan kondisi list terbaru ke Shared Preferences
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_historyList);
    await prefs.setString('calculator_history', encodedData);
  }

  // Fungsi untuk menambah riwayat baru (akan dipanggil dari Kalkulator)
  void _addToHistory(String expression, String result) {
    setState(() {
      // .insert(0, ...) digunakan agar riwayat terbaru muncul paling atas
      // Menambahkan default field 'note': '' untuk menampung teks catatan nanti
      _historyList.insert(0, {
        'expression': expression, 
        'result': result,
        'note': '',
      });
    });
    _saveHistory(); // Simpan ke local storage tiap ada data baru
  }

  // Fungsi untuk menghapus semua riwayat
  void _clearHistory() {
    setState(() {
      _historyList.clear();
    });
    _saveHistory(); // Update local storage setelah dikosongkan
  }

  // FITUR 1: Fungsi untuk menghapus riwayat satu per satu berdasarkan index
  void _deleteSingleHistory(int index) {
    setState(() {
      _historyList.removeAt(index);
    });
    _saveHistory(); // Update local storage setelah dihapus
  }

  // FITUR 2: Fungsi untuk menambah atau memperbarui catatan pada item tertentu
  void _addNoteToHistory(int index, String noteText) {
    setState(() {
      _historyList[index]['note'] = noteText;
    });
    _saveHistory(); // Update local storage setelah catatan disimpan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // TOP NAVIGATION MENU
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavItem(0, 'Kalkulator'),
                  const SizedBox(width: 20),
                  _buildNavItem(1, 'History'),
                  const SizedBox(width: 20),
                  _buildNavItem(2, 'Profile'),
                ],
              ),
            ),
            
            // AREA KONTEN
            Expanded(
              child: _getScreen(),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi dinamis untuk memanggil layar berdasarkan index
  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return KalkulatorScreen(onCalculate: _addToHistory);
      case 1:
        // Di sini kita overide dengan parameter-parameter baru yang dibutuhkan history.dart kita yang baru
        return HistoryScreen(
          historyList: _historyList, 
          onClearAll: _clearHistory,
          onDeleteItem: _deleteSingleHistory,
          onAddNote: _addNoteToHistory,
        );
      case 2:
        return ProfileScreen();
      default:
        return KalkulatorScreen(onCalculate: _addToHistory);
    }
  }

  Widget _buildNavItem(int index, String title) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        color: Colors.transparent,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
    );
  }
}