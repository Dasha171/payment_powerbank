import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/payment_screen.dart';
import 'screens/success_screen.dart';

final GoRouter router = GoRouter(
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
      builder: (context, state) => const SuccessScreen(),
    ),
  ],
);
