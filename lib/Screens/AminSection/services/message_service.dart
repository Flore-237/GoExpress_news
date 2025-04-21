import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch messages from Firestore
  Stream<List<Message>> getMessages() {
    return _firestore.collection('messages').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Send a new message to Firestore
  Future<void> sendMessage(Message message) async {
    await _firestore.collection('messages').add(message.toMap());
  }

  // Update an existing message
  Future<void> updateMessage(String messageId, String newText) async {
    await _firestore.collection('messages').doc(messageId).update({
      'text': newText,
      'timestamp': Timestamp.now(),
    });
  }

  // Delete a message from Firestore
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
}