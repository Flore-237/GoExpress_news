import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import '../models/message.dart';
import '../services/message_service.dart';

class SupportClientScreen extends StatefulWidget {
  static const routeName = '/support-client';

  @override
  _SupportClientScreenState createState() => _SupportClientScreenState();
}

class _SupportClientScreenState extends State<SupportClientScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Client'),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageService.getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('Aucun message disponible'),
                  );
                }

                List<Message> messages = snapshot.data!;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message,
                      isMe: message.senderId == 'admin',
                      onDelete: () => _messageService.deleteMessage(message.id),
                      onEdit: (newText) {
                        _messageService.updateMessage(message.id, newText);
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Entrez votre message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _messageService.sendMessage(Message(
                        senderId: 'admin', // Remplace avec l'ID réel de l'utilisateur
                        senderName: 'Admin', // Remplace avec le nom réel de l'utilisateur
                        senderProfileUrl: 'assets/admin.png', // Remplace par l'URL réelle
                        text: _messageController.text,
                        timestamp: DateTime.now(),
                      ));
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final VoidCallback onDelete;
  final Function(String) onEdit;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(message.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[700] : Colors.green[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(message.senderProfileUrl),
                  radius: 16,
                ),
                SizedBox(width: 8),
                Text(
                  message.senderName,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Modifier') {
                      TextEditingController editController = TextEditingController(text: message.text);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Modifier le message'),
                          content: TextField(
                            controller: editController,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                onEdit(editController.text);
                                Navigator.of(ctx).pop();
                              },
                              child: Text('Enregistrer'),
                            ),
                          ],
                        ),
                      );
                    } else if (value == 'Supprimer') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'Modifier',
                      child: Text('Modifier'),
                    ),
                    PopupMenuItem(
                      value: 'Supprimer',
                      child: Text('Supprimer'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}