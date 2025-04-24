import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/signup_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = loginRoute;
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
        _usernameController.text.trim(), _passwordController.text.trim());
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } else if (mounted && authService.errorMessage != null)
      // ignore: curly_braces_in_flow_control_structures
      _showErrorSnackbar(authService.errorMessage!);
  }

  void _showErrorSnackbar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent));

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding * 1.5),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(Icons.track_changes,
                    size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: kDefaultPadding),
                Text('Welcome Back!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
                const SizedBox(height: kDefaultPadding * 0.5),
                Text('Login to track expenses',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: kDefaultPadding * 2),
                TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        labelText: 'username',
                        prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter your username'
                        : null),
                const SizedBox(height: kDefaultPadding),
                TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () =>
                                setState(() => _obscureText = !_obscureText))),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password min 6 chars'
                        : null),
                const SizedBox(height: kDefaultPadding * 1.5),
                authService.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit, child: const Text('Login')),
                const SizedBox(height: kDefaultPadding),
                TextButton(
                    onPressed: authService.isLoading
                        ? null
                        : () => Navigator.of(context)
                            .pushNamed(RegisterScreen.routeName),
                    child: Text('Don\'t have an account? Sign Up',
                        style: TextStyle(color: theme.colorScheme.secondary))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
