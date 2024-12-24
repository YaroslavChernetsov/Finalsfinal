import 'package:flutter/material.dart';
import '../models/sweet_model.dart';

class CartFavoriteProvider extends ChangeNotifier {
  final List<Sweet> _cartItems = [];
  final List<Sweet> _favoriteItems = [];

  List<Sweet> get cartItems => _cartItems;
  List<Sweet> get favoriteItems => _favoriteItems;

  void addToCart(Sweet sweet) {
    final index = _cartItems.indexWhere((item) => item.id == sweet.id);
    if (index == -1) {
      _cartItems.add(sweet.copyWith(quantity: 1));
    } else {
      final updatedItem = _cartItems[index].copyWith(
        quantity: _cartItems[index].quantity! + 1,
      );
      _cartItems[index] = updatedItem;
    }
    notifyListeners();
  }

  void removeFromCart(Sweet sweet) {
    _cartItems.removeWhere((item) => item.id == sweet.id);
    notifyListeners();
  }

  void updateQuantity(Sweet sweet, int quantity) {
    final index = _cartItems.indexWhere((item) => item.id == sweet.id);
    if (index != -1) {
      if (quantity <= 0) {
        removeFromCart(sweet);
      } else {
        _cartItems[index] = sweet.copyWith(quantity: quantity);
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void addToFavorites(Sweet sweet) {
    if (!_favoriteItems.contains(sweet)) {
      _favoriteItems.add(sweet);
      notifyListeners();
    }
  }

  void removeFromFavorites(Sweet sweet) {
    _favoriteItems.remove(sweet);
    notifyListeners();
  }

  bool isFavorite(Sweet sweet) {
    return _favoriteItems.contains(sweet);
  }

  bool isInCart(Sweet sweet) {
    return _cartItems.any((item) => item.id == sweet.id);
  }
}
