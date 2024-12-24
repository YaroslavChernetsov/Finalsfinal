import 'package:flutter/material.dart';
import 'sweet_model.dart';

class SweetProvider extends ChangeNotifier {
  final List<Sweet> _cart = [];
  final List<Sweet> _favorites = [];

  List<Sweet> get cart => _cart;
  List<Sweet> get favorites => _favorites;

  void addToCart(Sweet sweet) {
    if (!_cart.contains(sweet)) {
      _cart.add(sweet);
      notifyListeners();
    }
  }

  void removeFromCart(Sweet sweet) {
    _cart.remove(sweet);
    notifyListeners();
  }

  void addToFavorites(Sweet sweet) {
    if (!_favorites.contains(sweet)) {
      _favorites.add(sweet);
      notifyListeners();
    }
  }

  void removeFromFavorites(Sweet sweet) {
    _favorites.remove(sweet);
    notifyListeners();
  }
}
