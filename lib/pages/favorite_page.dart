import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_favorite_provider.dart';
import '../models/sweet_model.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteItems = context.watch<CartFavoriteProvider>().favoriteItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: favoriteItems.isEmpty
          ? const Center(child: Text('Избранное пусто.'))
          : ListView.builder(
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
          final sweet = favoriteItems[index];
          final isInCart = context.watch<CartFavoriteProvider>().isInCart(sweet);

          return ListTile(
            leading: Image.network(sweet.imageUrl, width: 50, height: 50),
            title: Text(sweet.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Цена: ${sweet.price.toStringAsFixed(2)} ₽'),
                if (isInCart)
                  const Text(
                    'Уже в корзине',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {

                    context.read<CartFavoriteProvider>().removeFromFavorites(sweet);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                    color: isInCart ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {

                    if (isInCart) {
                      context.read<CartFavoriteProvider>().removeFromCart(sweet);
                    } else {
                      context.read<CartFavoriteProvider>().addToCart(sweet);
                    }
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
