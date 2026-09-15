import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  final List<Map<String, String>> notesList;
  final Function(String) onEdit;
  final Function(int) onDelete;

  NotesScreen({
    required this.notesList, 
    required this.onEdit, 
    required this.onDelete
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Text("Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        ),
        Expanded(
          child: notesList.isEmpty
              ? Center(child: Text("Belum ada catatan", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    final note = notesList[index];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5))),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: InkWell(
                              onTap: () => onEdit(note['title']!),
                              child: Text(
                                note['title'] ?? 'Tanpa Nama',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Text(" | ", style: TextStyle(fontSize: 20, color: Colors.grey)),
                          Expanded(
                            flex: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_note, color: Colors.blue),
                                  onPressed: () => onEdit(note['title']!),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.orange),
                                  onPressed: () {
                                    if (note['id'] != null) {
                                      onDelete(int.parse(note['id']!));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}