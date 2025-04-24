import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = registerRoute;
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.register(_usernameController.text.trim(),
        _emailController.text.trim(), _passwordController.text.trim());
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registration successful!'),
        backgroundColor: Colors.green,
      ));
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        }
      });
    } else if (mounted && authService.errorMessage != null) {
      _showErrorSnackbar(authService.errorMessage!);
    }
  }
  void _showErrorSnackbar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent));

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Create Account'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.primary),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding * 1.5),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Join Us!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
                const SizedBox(height: kDefaultPadding * 0.5),
                Text('Create an account to start tracking',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: kDefaultPadding * 2),
                TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter a username'
                        : null),
                const SizedBox(height: kDefaultPadding),
                TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null),
                const SizedBox(height: kDefaultPadding),
                TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword))),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password min 6 chars'
                        : null),
                const SizedBox(height: kDefaultPadding),
                TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword))),
                    validator: (v) => (v != _passwordController.text)
                        ? 'Passwords do not match'
                        : null),
                const SizedBox(height: kDefaultPadding * 1.5),
                authService.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit, child: const Text('Register')),
                const SizedBox(height: kDefaultPadding),
                TextButton(
                    onPressed: authService.isLoading
                        ? null
                        : () {
                            if (Navigator.canPop(context)) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context)
                                  .pushReplacementNamed(LoginScreen.routeName);
                            }
                          },
                    child: Text('Already have an account? Log In',
                        style: TextStyle(color: theme.colorScheme.secondary))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
