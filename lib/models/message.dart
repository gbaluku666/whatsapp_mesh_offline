import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'message.g.dart';

@collection
class Message {
  Id? isarId; // Internal ID for Isar

  @Index(unique: true)
  final String uuid; // Global Unique ID
  
  final String senderId;
  final String text;
  final DateTime timestamp;
  
  // Status helps us track the message lifecycle
  // 0: Local only, 1: Sent via Mesh, 2: Synced to Cloud
  @Index()
  int status; 

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.status = 0,
  }) : uuid = const Uuid().v4();
}