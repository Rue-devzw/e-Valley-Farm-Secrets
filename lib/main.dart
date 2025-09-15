import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'providers/cart_provider.dart';
import 'screens/store_screen.dart';

void main() {
  runApp(const ValleyFarmApp());
}

class ValleyFarmApp extends StatelessWidget {
  const ValleyFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme baseScheme = ColorScheme.fromSeed(seedColor: primaryGreen).copyWith(
      secondary: accentGold,
    );

    return ChangeNotifierProvider<CartProvider>(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'Valley Farm Secrets Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: baseScheme,
          scaffoldBackgroundColor: const Color(0xFFF7F5EF),
          appBarTheme: AppBarTheme(
            backgroundColor: baseScheme.surface,
            foregroundColor: baseScheme.onSurface,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            color: baseScheme.surface,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: baseScheme.primary,
            contentTextStyle: const TextStyle(color: Colors.white),
          ),
        ),
        home: const StoreScreen(),
      ),
    );
  }
}
