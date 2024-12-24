import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sweet_model.dart';
import '../api_service.dart';
import '../pages/product_detail.dart';
import '../pages/chat_page.dart';
import '../provider/cart_favorite_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _currentUser;
  List<Sweet> _allSweets = [];
  List<Sweet> _filteredSweets = [];
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }


  void _checkCurrentUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
    if (_currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get()
          .then((doc) {
        if (doc.exists && doc.data()?['isAdmin'] == true) {
          setState(() {
            _isAdmin = true;
          });
        }
      });
    }
  }


  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatPage(),
      ),
    );
  }


  void _filterSweets(String query) {
    setState(() {
      _filteredSweets = _allSweets
          .where((sweet) =>
      sweet.name.toLowerCase().contains(query.toLowerCase()) ||
          sweet.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }


  String _generateRandomId() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 90000 + 10000).toString();
  }


  void _showAddSweetDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController();
    final TextEditingController flavorController = TextEditingController();
    final TextEditingController brandController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить новый товар'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Описание'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Цена'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'Ссылка на изображение'),
                ),
                TextField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(labelText: 'Состав'),
                ),
                TextField(
                  controller: flavorController,
                  decoration: const InputDecoration(labelText: 'Вкус'),
                ),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: 'Бренд'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                final String description = descriptionController.text.trim();
                final double? price = double.tryParse(priceController.text.trim());
                final String imageUrl = imageUrlController.text.trim();
                final String ingredients = ingredientsController.text.trim();
                final String flavor = flavorController.text.trim();
                final String brand = brandController.text.trim();

                if (name.isEmpty || description.isEmpty || price == null || imageUrl.isEmpty || ingredients.isEmpty || flavor.isEmpty || brand.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пожалуйста, заполните все поля')),
                  );
                  return;
                }

                final String id = _generateRandomId();

                final sweet = Sweet(
                  id: id,
                  name: name,
                  description: description,
                  price: price,
                  imageUrl: imageUrl,
                  brand: brand,
                  flavor: flavor,
                  ingredients: ingredients,
                );

                try {
                  await ApiService().createSweet(sweet);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Товар успешно добавлен')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          title: _isSearching
              ? TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Поиск...'),
            onChanged: _filterSweets,
          )
              : const Text('Корейские cладости'),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: _currentUser == null
                  ? null
                  : _openChat,
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _filteredSweets = _allSweets;
                  }
                });
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_isSearching) {
            setState(() {
              _isSearching = false;
              _searchController.clear();
              _filteredSweets = _allSweets;
            });
          }
        },
        child: StreamBuilder<List<Sweet>>(
          stream: FirebaseFirestore.instance
              .collection('sweets')
              .snapshots()
              .map((snapshot) => snapshot.docs
              .map((doc) => Sweet.fromJson(doc.data() as Map<String, dynamic>))
              .toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Сладости не найдены.'));
            }

            _allSweets = snapshot.data!;
            if (_filteredSweets.isEmpty) {
              _filteredSweets = _allSweets;
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _filteredSweets = _allSweets;
                });
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: _filteredSweets.length,
                itemBuilder: (context, index) {
                  final sweet = _filteredSweets[index];
                  final isFavorite = context.watch<CartFavoriteProvider>().isFavorite(sweet);
                  final isInCart = context.watch<CartFavoriteProvider>().isInCart(sweet);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetail(sweet: sweet),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 120,
                            width: double.infinity,
                            child: Image.network(
                              sweet.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              sweet.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${sweet.price.toStringAsFixed(2)} ₽',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pinkAccent,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    if (isFavorite) {
                                      context.read<CartFavoriteProvider>().removeFromFavorites(sweet);
                                    } else {
                                      context.read<CartFavoriteProvider>().addToFavorites(sweet);
                                    }
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: _showAddSweetDialog,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
