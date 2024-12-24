import 'package:flutter/material.dart';
import 'package:pr03/models/sweet_model.dart';

class Item extends StatelessWidget {
  final Sweet sweet;

  const Item({Key? key, required this.sweet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            sweet.imageUrl,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              sweet.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '\$${sweet.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
