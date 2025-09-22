import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/payment_provider.dart';
import 'screens/payment_screen.dart';
import 'screens/success_screen.dart';

void main() {
  runApp(const PowerBankApp());
}

class PowerBankApp extends StatelessWidget {
  const PowerBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp.router(
        title: 'Power Bank Rental',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'SF Pro Display', // iOS-like font
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final stationId = state.uri.queryParameters['stationId'];
        return PaymentScreen(stationId: stationId);
      },
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) {
        final stationId = state.uri.queryParameters['stationId'] ?? '';
        final powerBankId = state.uri.queryParameters['powerBankId'];
        return SuccessScreen(
          stationId: stationId,
          powerBankId: powerBankId,
        );
      },
    ),
  ],
);