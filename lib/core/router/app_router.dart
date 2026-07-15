import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/notifications/presentation/pages/notification_center_page.dart';
import '../../features/tickets/domain/entities/ticket.dart';
import '../../features/tickets/presentation/pages/create_ticket_page.dart';
import '../../features/tickets/presentation/pages/ticket_details_page.dart';
import '../../features/tickets/presentation/pages/tickets_list_page.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final router = GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final loggingIn = state.matchedLocation == '/login';

      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      final isLoggedIn = authState is Authenticated;

      if (!isLoggedIn) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
      GoRoute(
        path: '/tickets',
        builder: (context, state) => const TicketsListPage(),
      ),
      GoRoute(
        path: '/tickets/create',
        builder: (context, state) => const CreateTicketPage(),
      ),
      GoRoute(
        path: '/tickets/:id',
        builder: (context, state) {
          final ticketId = state.pathParameters['id']!;
          final extra = state.extra as TicketEntity?;
          return TicketDetailsPage(ticketId: ticketId, ticket: extra);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationCenterPage(),
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
