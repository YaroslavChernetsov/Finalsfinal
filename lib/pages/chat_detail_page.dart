import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatDetailPage extends StatelessWidget {
  final String chatId;

  const ChatDetailPage({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _messageController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;

    void _sendMessage(String message) async {
      if (message.trim().isEmpty || currentUser == null) return;

      try {
        final timestamp = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance.collection('chats/$chatId/messages').add({
          'text': message.trim(),
          'senderId': currentUser.uid,
          'timestamp': timestamp,
        });

        await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
          'lastMessage': message.trim(),
          'timestamp': timestamp,
        });

        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка отправки сообщения: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Чат')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats/$chatId/messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Нет сообщений.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isCurrentUser = message['senderId'] == currentUser?.uid;

                    return Align(
                      alignment:
                      isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Card(
                        color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(message['text']),
                        ),
                      ),
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
                    decoration: const InputDecoration(hintText: 'Введите сообщение'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
