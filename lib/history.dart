import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  // Tambahkan key 'note' pada struktur Map
  final List<Map<String, String>> historyList;
  final VoidCallback onClearAll;
  final Function(int) onDeleteItem;
  final Function(int, String) onAddNote;

  const HistoryScreen({
    super.key,
    required this.historyList,
    required this.onClearAll,
    required this.onDeleteItem,
    required this.onAddNote,
  });

  // Fungsi untuk memunculkan Pop-up dialog tambah/edit catatan
  void _showNoteDialog(BuildContext context, int index, String currentNote) {
    final TextEditingController noteController = TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah / Ubah Catatan'),
          content: TextField(
            controller: noteController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama catatan...',
              border: OutlineInputBorder(),
            ),
            // Mendukung submit via tombol Enter di keyboard
            onSubmitted: (value) {
              onAddNote(index, value);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                onAddNote(index, noteController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6D00)),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header & Tombol Hapus Semua
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Perhitungan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              if (historyList.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6D00)),
                  onPressed: onClearAll,
                  tooltip: 'Hapus Semua Riwayat',
                ),
            ],
          ),
        ),

        // List Riwayat Perhitungan
        Expanded(
          child: historyList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada riwayat',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final item = historyList[index];
                    final String note = item['note'] ?? '';

                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        // Bagian Kiri: teks perhitungan dan catatan (jika ada)
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['expression']} = ${item['result']}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (note.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                note,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Bagian Kanan: Tombol Titik 3 (PopupMenuButton)
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'delete') {
                              onDeleteItem(index);
                            } else if (value == 'note') {
                              _showNoteDialog(context, index, note);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'note',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_note, size: 20, color: Colors.black54),
                                  SizedBox(width: 8),
                                  Text('Tambah Catatan'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}