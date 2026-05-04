import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import 'app/routes/app_routes.dart';
import 'core/supabase/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri?>? _uriSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        await _handleUri(initialUri);
      }
    } catch (_) {
      // Ignora enlaces iniciales inválidos.
    }

    _uriSubscription = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleUri(uri);
        }
      },
      onError: (_) {
        // Ignora errores del stream de enlaces.
      },
    );

    if (Uri.base.fragment.contains('reset-password')) {
      await _handleUri(Uri.base);
    }
  }

  Future<void> _handleUri(Uri uri) async {
    try {
      final params = Map<String, String>.from(uri.queryParameters);

      final fragment = uri.fragment;
      if (fragment.isNotEmpty && fragment.contains('access_token')) {
        final fragmentParams = Uri(query: fragment).queryParameters;
        params.addAll(fragmentParams);
      }

      final accessToken = params['access_token'];
      final refreshToken = params['refresh_token'];

      if (accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        await SupabaseConfig.client.auth.setSession(
          refreshToken,
          accessToken: accessToken,
        );
      }

      if (uri.host == 'reset-password' ||
          uri.path.contains('reset-password') ||
          uri.fragment.contains('reset-password') ||
          (accessToken != null && refreshToken != null)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigatorKey.currentState?.pushNamed(AppRoutes.resetPassword);
        });
      }
    } catch (e) {
      // Error al procesar el enlace
    }
  }

  @override
  void dispose() {
    _uriSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
