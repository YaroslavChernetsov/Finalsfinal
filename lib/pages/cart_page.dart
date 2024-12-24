import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_favorite_provider.dart';
import 'order_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartItems = context.watch<CartFavoriteProvider>().cartItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text('Корзина пуста.'))
                : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final sweet = cartItems[index];
                int quantity = sweet.quantity ?? 1;

                return Dismissible(
                  key: ValueKey(sweet.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  onDismissed: (direction) {
                    context.read<CartFavoriteProvider>().removeFromCart(sweet);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${sweet.name} удалён из корзины')),
                    );
                  },
                  child: ListTile(
                    leading: Image.network(sweet.imageUrl, width: 50, height: 50),
                    title: Text(sweet.name),
                    subtitle: Text('Цена: ${sweet.price * quantity} руб.'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (quantity > 1) {
                              quantity--;
                              context.read<CartFavoriteProvider>().updateQuantity(sweet, quantity);
                            }
                          },
                        ),
                        Text(quantity.toString()),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            quantity++;
                            context.read<CartFavoriteProvider>().updateQuantity(sweet, quantity);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderPage(),
                    ),
                  );
                },
                child: const Text('Оформить заказ'),
              ),
            ),
        ],
      ),
    );
  }
}
