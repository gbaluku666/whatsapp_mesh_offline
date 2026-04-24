class MessageService {
  // This function is the entry point for every "Send" action
  Future<void> sendMessage(String text) async {
    // 1. Create the message object
    final newMessage = Message(
      senderId: "my_device_id", 
      text: text,
      timestamp: DateTime.now(),
      status: 0, // Starts as local
    );

    // 2. Save to Local Database (Immediate feedback for user)
    await saveToLocalDb(newMessage);

    // 3. Try Online Path
    bool isOnline = await checkInternet();
    if (isOnline) {
      await sendToCloud(newMessage);
    } else {
      // 4. Try Offline Path (Mesh)
      await broadcastToMesh(newMessage);
    }
  }
}