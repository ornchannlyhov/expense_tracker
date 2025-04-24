import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/signup_screen.dart';
import 'package:frontend/screens/expense/add_edit_expense.dart';
import 'package:frontend/screens/expense/expense_detail.dart';
import 'package:frontend/screens/expense/expense_list_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/expense.dart';
import 'services/auth_service.dart';
import 'services/expense_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

import 'screens/auth/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/error_screen.dart';

// Add this class to handle theme switching
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setLightMode() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  void setSystemMode() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, ExpenseService>(
          create: (_) => ExpenseService(),
          update: (_, auth, previous) => previous ?? ExpenseService(),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Expense Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            home: Consumer<AuthService>(
              builder: (context, auth, _) {
                if (auth.isLoading &&
                    auth.token == null &&
                    !auth.isAuthenticated) {
                  return const SplashScreen();
                } else if (auth.isAuthenticated) {
                  return const HomeScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
            routes: {
              splashRoute: (_) => const SplashScreen(),
              loginRoute: (_) => const LoginScreen(),
              registerRoute: (_) => const RegisterScreen(),
              homeRoute: (_) => const HomeScreen(),
              expenseListRoute: (_) => const ExpenseListScreen(),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case addEditExpenseRoute:
                  final arg = settings.arguments as Expense?;
                  return MaterialPageRoute(
                    builder: (_) => AddEditExpenseScreen(expenseToEdit: arg),
                  );
                case expenseDetailRoute:
                  final arg = settings.arguments as Expense?;
                  return (arg != null)
                      ? MaterialPageRoute(
                          builder: (_) => ExpenseDetailScreen(expense: arg))
                      : MaterialPageRoute(
                          builder: (_) => const ErrorScreen(
                              message: 'Expense data missing.'));
                default:
                  return MaterialPageRoute(
                      builder: (_) =>
                          const ErrorScreen(message: 'Page not found.'));
              }
            },
          );
        },
      ),
    );
  }
}
