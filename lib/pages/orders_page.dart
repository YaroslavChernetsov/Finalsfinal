import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_details_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Мои заказы')),
        body: const Center(child: Text('Пожалуйста, войдите в систему.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Мои заказы')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return Center(child: Text('Ошибка: ${userSnapshot.error}'));
          }

          final isAdmin = userSnapshot.data?.get('isAdmin') ?? false;

          return FutureBuilder<QuerySnapshot>(
            future: isAdmin
                ? FirebaseFirestore.instance.collection('orders').get()
                : FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: currentUser.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('У вас нет заказов.'));
              }

              final orders = snapshot.data!.docs;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final createdAt = (order['createdAt'] as Timestamp?)?.toDate();
                  final userName = order['userName'] ?? 'Неизвестный пользователь';

                  return ListTile(
                    title: Text('Заказ от $userName'),
                    subtitle: createdAt != null
                        ? Text('Дата оформления: ${createdAt.toLocal()}')
                        : const Text('Дата оформления: неизвестно'),
                    trailing: IconButton(
                      icon: const Icon(Icons.details),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsPage(orderId: order.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
