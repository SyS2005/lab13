import 'package:flutter/material.dart';
import 'helpers/database_helper.dart'; // Підключаємо клас для роботи з БД

void main() {
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotesPage(), // Встановлюємо основний екран
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await DatabaseHelper().getNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addNote() async {
    if (_formKey.currentState!.validate()) {
      final content = _controller.text.trim();
      final date = DateTime.now().toIso8601String();

      await DatabaseHelper().addNote(content, date);
      _controller.clear();
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Enter note',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Note cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addNote,
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    child: ListTile(
                      title: Text(note['content']),
                      subtitle: Text(note['date']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}