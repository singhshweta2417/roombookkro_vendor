import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/google_services/firebase_notifications.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/navigator_key_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) async* {
  await for (final results in Connectivity().onConnectivityChanged) {
    if (results.isNotEmpty) {
      yield results.first;
    } else {
      yield ConnectivityResult.none;
    }
  }
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);
  return NotificationService(navigatorKey: navigatorKey);
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create provider container to access global providers
  final container = ProviderContainer();

  // Get navigator key from provider
  final navigatorKey = container.read(navigatorKeyProvider);

  // Initialize NotificationService with navigator key
  final notificationService = NotificationService(navigatorKey: navigatorKey);

  // Request notification permission and set up FCM
  await notificationService.requestedNotificationPermission();
  notificationService.firebaseInit();
  notificationService.setupInteractMassage();

  // Load theme before app start
  final themeRepo = container.read(themeRepositoryProvider);
  await themeRepo.loadTheme();

  // Run app
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  void _handleConnectionChange(
      BuildContext context,
      GlobalKey<NavigatorState> navigatorKey,
      ConnectivityResult result,
      ) {
    final online = result != ConnectivityResult.none;
    final currentContext = navigatorKey.currentContext;
    final currentRoute = ModalRoute.of(currentContext ?? context)?.settings.name;

    if (!online && currentRoute != AppRoutes.noInternetConnection) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.noInternetConnection,
            (route) => false,
      );
    } else if (online && currentRoute != AppRoutes.splash) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.splash,
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.watch(navigatorKeyProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isLight = themeMode == AppThemeMode.light;
    ref.listen<AsyncValue<ConnectivityResult>>(
      connectivityProvider,
          (previous, next) {
        next.whenData((result) {
          _handleConnectionChange(context, navigatorKey, result);
        });
      },
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isLight ? Colors.white : Colors.black,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
        isLight ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          onGenerateRoute: generateRoute,
          initialRoute: AppRoutes.splash,
          title: 'RoomBookKaro',
          theme: toThemeData(lightTheme),
          darkTheme: toThemeData(darkTheme),
          themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
        ),
      ),
    );
  }
}
