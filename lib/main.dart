import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- Data Models ---
class UserData {
  final String name;
  final String lastname;
  final String id;

  // Constructor with default empty values for easier instantiation.
  UserData({this.name = '', this.lastname = '', this.id = ''});
}

class Note {
  final String title;
  final String content;
  final UserData author;

  Note({required this.title, required this.content, required this.author});
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tarea de Navegación en flutter',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // State is "lifted up" to be shared between the different screens.
  UserData _currentUser = UserData();
  final List<Note> _savedNotes = [];

  // Callback to update user data from the UsuarioScreen.
  void _updateUser(UserData user) {
    setState(() {
      _currentUser = user;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario guardado con éxito')),
    );
  }

  // Callback to add a new note from the NotasScreen.
  void _addNote(Note note) {
    setState(() {
      _savedNotes.add(note);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota archivada con éxito')),
    );
    FocusScope.of(context).unfocus(); // Hide keyboard after saving.
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This list is built inside the build method so that on each setState,
    // the screens are rebuilt with the latest state information.
    final List<Widget> widgetOptions = <Widget>[
      NotasScreen(currentUser: _currentUser, onAddNote: _addNote),
      GuardadosScreen(notes: _savedNotes),
      UsuarioScreen(currentUser: _currentUser, onSave: _updateUser),
    ];

    const List<String> titles = ['Notas', 'Guardados', 'Usuario'];

    return Scaffold(
      appBar: AppBar(
        // The AppBar title changes dynamically with the selected screen.
        title: Text(titles[_selectedIndex]),
      ),
      // Using IndexedStack preserves the state of each screen when switching tabs.
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            label: 'Notas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Guardados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Usuario',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

class NotasScreen extends StatefulWidget {
  final UserData? currentUser;
  final Function(Note) onAddNote;

  const NotasScreen({
    super.key,
    this.currentUser,
    required this.onAddNote,
  });

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleArchive() {
    // Validate that user data exists before creating a note.
    // Add a null check for currentUser.
    if (widget.currentUser == null ||
        widget.currentUser!.id.isEmpty || widget.currentUser!.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Por favor, guarde sus datos en la pestaña Usuario primero.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate that note fields are not empty.
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título y el contenido no pueden estar vacíos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newNote = Note(
      title: _titleController.text,
      content: _contentController.text,
      author: widget.currentUser!,
    );

    widget.onAddNote(newNote);

    // Clear fields after saving.
    _titleController.clear();
    _contentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Contenido',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleArchive,
            child: const Text('Archivar'),
          ),
        ],
      ),
    );
  }
}





class GuardadosScreen extends StatelessWidget {
  final List<Note>? notes;
  const GuardadosScreen({super.key, this.notes});

  @override
  Widget build(BuildContext context) {
    // Check for both null and empty.
    if (notes == null || notes!.isEmpty) {
      return const Center(
        child: Text('No hay notas guardadas.', style: TextStyle(fontSize: 18)),
      );
    }

    // A list of colors for the note borders.
    final List<Color> borderColors = [
      Colors.pinkAccent,
      Colors.lightBlueAccent,
      Colors.lightGreenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: notes!.length,
      itemBuilder: (context, index) {
        final note = notes![index];
        // Cycle through the colors for each note.
        final color = borderColors[index % borderColors.length];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(note.content, style: const TextStyle(fontSize: 16)),
              const Divider(height: 24),
              Text(
                'Autor: ${note.author.name} ${note.author.lastname} (Cédula: ${note.author.id})',
                style: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.grey[700]),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UsuarioScreen extends StatefulWidget {
  final UserData? currentUser;
  final Function(UserData) onSave;

  const UsuarioScreen(
      {super.key, this.currentUser, required this.onSave});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  late TextEditingController _nameController;
  late TextEditingController _lastnameController;
  late TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data, or with an empty string if null.
    _nameController = TextEditingController(text: widget.currentUser?.name ?? '');
    _lastnameController =
        TextEditingController(text: widget.currentUser?.lastname ?? '');
    _idController = TextEditingController(text: widget.currentUser?.id ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(UserData(
      name: _nameController.text,
      lastname: _lastnameController.text,
      id: _idController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _lastnameController,
            decoration: const InputDecoration(labelText: 'Apellido'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _idController,
            decoration: const InputDecoration(labelText: 'Cédula'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),
          Center(
              child:
                  ElevatedButton(onPressed: _handleSave, child: const Text('Guardar'))),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          const Text('Datos Guardados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // Display the saved user data.
          if (widget.currentUser != null && widget.currentUser!.id.isNotEmpty)
            Card(
              child: ListTile(
                title: Text(
                    '${widget.currentUser!.name} ${widget.currentUser!.lastname}'),
                subtitle: Text('Cédula: ${widget.currentUser!.id}'),
                leading: const Icon(Icons.person),
              ),
            )
          else
            const Text('Aún no se han guardado datos de usuario.'),
        ],
      ),
    );
  }
}
