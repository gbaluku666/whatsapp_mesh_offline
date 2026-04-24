import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/message.dart'; // Ensure this matches your filename
import 'services/mesh_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  
  // Open Isar. If message.g.dart didn't generate yet, 
  // MessageSchema will show an error.
  final isar = await Isar.open(
    [MessageSchema], 
    directory: dir.path,
  );

  runApp(MaterialApp(home: ChatScreen(isar: isar)));
}

class ChatScreen extends StatefulWidget {
  final Isar isar;
  ChatScreen({required this.isar});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MeshService _meshService = MeshService();
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    
    // Start the mesh and tell it what to do when a message arrives
    _meshService.startMesh("User_A", (incomingText) async {
      final incomingMsg = Message()
        ..senderId = "Neighbor"
        ..text = incomingText
        ..timestamp = DateTime.now()
        ..status = 1; // Mark as received via mesh

      await widget.isar.writeTxn(() async {
        await widget.isar.messages.put(incomingMsg);
      });
    });
  }

  void _send() async {
    if (_controller.text.isEmpty) return;

    final textToSend = _controller.text;

    final msg = Message()
      ..senderId = "Me"
      ..text = textToSend
      ..timestamp = DateTime.now()
      ..status = 0;

    // 1. Save to Local DB (So you see it on your screen)
    await widget.isar.writeTxn(() async {
      await widget.isar.messages.put(msg);
    });

    // 2. Blast it to anyone nearby
    _meshService.broadcastMessage(textToSend);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mesh Chat (Offline)")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(_messages[i].text),
                subtitle: Text(_messages[i].timestamp.toString()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller)),
                IconButton(icon: Icon(Icons.send), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}