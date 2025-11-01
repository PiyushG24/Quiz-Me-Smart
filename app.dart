import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';
import 'pages/quiz_page.dart';
import 'pages/results_page.dart';
import 'pages/profile_page.dart';
import 'providers/auth_provider.dart';

class QuizzyApp extends StatelessWidget {
  const QuizzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final router = GoRouter(
      initialLocation: '/',
      refreshListenable: auth,
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomePage()),
        GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
        GoRoute(path: '/quiz', builder: (_, __) => const QuizPage()),
        GoRoute(path: '/results', builder: (_, state) {
          final params = state.extra as Map<String, dynamic>?;
          return ResultsPage(
            score: params?['score'] ?? 0,
            total: params?['total'] ?? 0,
            category: params?['category'] ?? '',
          );
        }),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
      redirect: (context, state) {
        final loggedIn = auth.session != null;
        final loggingIn = state.matchedLocation == '/auth';
        
        // Handle Supabase email confirmation redirects (with or without errors)
        final uri = state.uri;
        if (uri.queryParameters.containsKey('error') || 
            uri.queryParameters.containsKey('error_code') ||
            uri.fragment.contains('error=')) {
          // Redirect to auth page with error - let auth page handle the error display
          return '/auth';
        }
        
        if (!loggedIn && !loggingIn && state.matchedLocation != '/') return '/auth';
        if (loggedIn && loggingIn) return '/';
        return null;
      },
    );

    return MaterialApp.router(
      title: 'Quiz Me Smart',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      routerConfig: router,
    );
  }
}
