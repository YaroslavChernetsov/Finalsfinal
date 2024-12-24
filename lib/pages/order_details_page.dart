import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали заказа')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Нет данных для отображения.'));
          }

          final order = snapshot.data!;
          final createdAt = (order['createdAt'] as Timestamp).toDate();
          final deliveryDate = order['date'];
          final time = order['time'];
          final userPhone = order['userPhone'];
          final items = order['items'] as List;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Дата оформления: ${createdAt.toLocal()}'),
                Text('Желаемая дата доставки: $deliveryDate'),
                Text('Время доставки: $time'),
                const SizedBox(height: 20),
                const Text('Телефон для связи:'),
                Text(userPhone),
                const SizedBox(height: 20),
                const Text('Список товаров:'),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Image.network(item['imageUrl']),
                      title: Text(item['name']),
                      subtitle: Text('${item['quantity']} шт. по ${item['price']} ₽'),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
