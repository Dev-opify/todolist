import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;

  String _email = '';
  String _password = '';

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      } else {
        await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('An unknown error occurred.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Log in to continue' : 'Sign up to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  key: const ValueKey('email'),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Please enter a valid email.';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('password'),
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                if (!_isLogin) const SizedBox(height: 12),
                if (!_isLogin)
                  TextFormField(
                    key: const ValueKey('confirm_password'),
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    validator: (value) {
                      if (value != _password) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 24),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
                if (!_isLoading)
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(_isLogin ? 'Login' : 'Sign Up'),
                  ),
                const SizedBox(height: 12),
                if (!_isLoading)
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Login',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}