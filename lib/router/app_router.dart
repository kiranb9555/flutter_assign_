import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/login_screen.dart';
import '../screens/car_list_screen.dart';
import '../screens/car_details_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/booking_conformation_screen.dart';
import '../models/booking_model.dart';
import '../providers/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => Scaffold(
          body: child,
        ),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const CarListScreen(),
            routes: [
              GoRoute(
                path: 'car/:id',
                name: 'car-detail',
                builder: (context, state) {
                  final carId = state.pathParameters['id']!;
                  return CarDetailScreen(carId: carId);
                },
              ),
              GoRoute(
                path: 'book/:carId',
                name: 'booking-form',
                builder: (context, state) {
                  final carId = state.pathParameters['carId']!;
                  return BookingFormScreen(carId: carId);
                },
              ),
              GoRoute(
                path: 'confirmation',
                name: 'booking-confirmation',
                builder: (context, state) {
                  final booking = state.extra is Booking ? state.extra as Booking : null;
                  return BookingConfirmationScreen(booking: booking);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
