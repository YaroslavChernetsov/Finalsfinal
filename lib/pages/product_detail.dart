import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sweet_model.dart';

class ProductDetail extends StatelessWidget {
  final Sweet sweet;

  const ProductDetail({Key? key, required this.sweet}) : super(key: key);


  void _showEditSweetDialog(BuildContext context, Sweet sweet) {
    final TextEditingController nameController = TextEditingController(text: sweet.name);
    final TextEditingController descriptionController = TextEditingController(text: sweet.description);
    final TextEditingController priceController = TextEditingController(text: sweet.price.toString());
    final TextEditingController imageUrlController = TextEditingController(text: sweet.imageUrl);
    final TextEditingController ingredientsController = TextEditingController(text: sweet.ingredients);
    final TextEditingController flavorController = TextEditingController(text: sweet.flavor);
    final TextEditingController brandController = TextEditingController(text: sweet.brand);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать товар'),
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

                final updatedSweet = Sweet(
                  id: sweet.id,
                  name: name,
                  description: description,
                  price: price,
                  imageUrl: imageUrl,
                  brand: brand,
                  flavor: flavor,
                  ingredients: ingredients,
                );

                try {

                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                      .collection('sweets')
                      .where('id', isEqualTo: sweet.id)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {

                    await FirebaseFirestore.instance
                        .collection('sweets')
                        .doc(querySnapshot.docs.first.id)
                        .update(updatedSweet.toJson());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Товар успешно обновлен')),
                    );
                  } else {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Документ не найден')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sweet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditSweetDialog(context, sweet); // Открыть диалог редактирования
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото товара
            Image.network(
              sweet.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                sweet.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Цена товара с символом рубля
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${sweet.price.toStringAsFixed(2)} ₽',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Описание товара
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                sweet.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            // Вкус
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Text(
                    'Вкус: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    sweet.flavor,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Бренд
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Text(
                    'Бренд: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    sweet.brand,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Состав
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Состав:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    sweet.ingredients,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
