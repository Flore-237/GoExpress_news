import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String id;
  String senderId;
  String senderName;
  String text;
  DateTime timestamp;
  String senderProfileUrl;

  Message({
    this.id = '',
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.senderProfileUrl = '',
  });

  // Convert from Firestore to Message
  factory Message.fromMap(Map<String, dynamic> data, String id) {
    return Message(
      id: id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      senderProfileUrl: data['senderProfileUrl'] ?? '',
    );
  }

  // Convert from Message to Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'senderProfileUrl': senderProfileUrl,
    };
  }
}