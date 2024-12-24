import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/cart_favorite_provider.dart';

class AppProviders {
  static MultiProvider init({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartFavoriteProvider()),

      ],
      child: child,
    );
  }
}
