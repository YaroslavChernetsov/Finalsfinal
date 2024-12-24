import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool? isAdmin;
  String? userId;
  String? currentChatId;
  List<Map<String, dynamic>> chats = [];

  @override
  void initState() {
    super.initState();
    _initializeChatPage();
  }

  Future<void> _initializeChatPage() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        print('[DEBUG] Пользователь не авторизован.');
        return;
      }

      userId = user.uid;
      print('[DEBUG] Текущий пользователь: $userId');

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('[DEBUG] Документ пользователя не найден.');
        return;
      }

      isAdmin = userDoc.data()?['isAdmin'] ?? false;
      print('[DEBUG] Пользователь администратор: $isAdmin');

      if (isAdmin!) {
        print('[DEBUG] Загружаем список чатов для администратора...');
        await _loadAdminChats();
      } else {
        print('[DEBUG] Загружаем чат с администратором...');
        await _loadUserChat();
      }
    } catch (e) {
      print('[ERROR] Ошибка инициализации страницы чата: $e');
    }
  }

  Future<void> _loadAdminChats() async {
    try {
      print('[DEBUG] Попытка загрузить все чаты для администратора...');

      final chatsQuery = await _firestore.collection('chats').get();
      if (chatsQuery.docs.isEmpty) {
        print('[DEBUG] У администратора нет доступных чатов.');
        return;
      }

      chats = chatsQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      print('[DEBUG] Чаты администратора успешно загружены: ${chats.length}');
      setState(() {});
    } catch (e) {
      print('[ERROR] Ошибка загрузки чатов администратора: $e');
    }
  }

  Future<void> _loadUserChat() async {
    try {
      final userChatQuery = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();

      if (userChatQuery.docs.isEmpty) {
        print('[DEBUG] У пользователя нет чатов. Создаем новый...');
        final newChat = {
          'participants': [userId, 'adminUserId'],
          'createdAt': FieldValue.serverTimestamp(),
        };

        final newChatRef = await _firestore.collection('chats').add(newChat);
        currentChatId = newChatRef.id;
        print('[DEBUG] Новый чат создан с ID: $currentChatId');
      } else {
        final chat = userChatQuery.docs.first;
        currentChatId = chat.id;
        print('[DEBUG] Найден существующий чат с ID: $currentChatId');
      }

      setState(() {});
    } catch (e) {
      print('[ERROR] Ошибка загрузки чата пользователя: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isAdmin == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isAdmin!) {
      return Scaffold(
        appBar: AppBar(title: const Text('Чаты с покупателями')),
        body: chats.isEmpty
            ? const Center(child: Text('Нет доступных чатов.'))
            : ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final lastMessage = chat['lastMessage'] ?? 'Нет сообщений';
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('Чат с покупателем ${chat['participants']}'),
              subtitle: Text(lastMessage),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailPage(
                      chatId: chat['id'],
                      currentUserId: userId!,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    } else {
      if (currentChatId == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return ChatDetailPage(chatId: currentChatId!, currentUserId: userId!);
    }
  }
}

class ChatDetailPage extends StatelessWidget {
  final String chatId;
  final String currentUserId;

  const ChatDetailPage({Key? key, required this.chatId, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _messageController = TextEditingController();

    void _sendMessage(String message) async {
      if (message.trim().isEmpty) return;

      try {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
          'text': message.trim(),
          'senderId': FirebaseAuth.instance.currentUser!.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .update({
          'lastMessage': message.trim(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        _messageController.clear();
        print('[DEBUG] Сообщение отправлено успешно: $message');
      } catch (e) {
        print('[ERROR] Ошибка отправки сообщения: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Чат с продавцом')),
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
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Сообщений нет.'));
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isCurrentUser = message['senderId'] == currentUserId;

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    decoration: const InputDecoration(hintText: 'Введите сообщение...'),
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
