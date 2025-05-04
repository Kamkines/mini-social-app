import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;
  String _errorMessage = '';

  Future<void> _signUp() async {
    // Future можно считать аналогом Promise, т.е. тут мы устанавливаем, что мы ждем ответа
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword( // функция используется для регистрации нового пользователя в Firebase с помощью email и пароля. Если почта есть уже в базе, то выйдет ошибка, если все хорошо, то создастся запись в Firebase
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print('User signed up');
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
      print('Error: $error');
    }
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword( // функция используется для входа пользователя в приложение с использованием его email и пароля
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print('User logged in');
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLoginMode ? 'Entrance' : 'Registration')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true, // hide password
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                });
              },
              child: Text(
                _isLoginMode
                    ? 'No account? Register'
                    : 'Do you already have an account? Enter',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (_isLoginMode) {
                  _login(); // тут позже будет firebase login
                } else {
                  _signUp(); // тут позже будет firebase signup
                }
              },
              child: Text(_isLoginMode ? 'Login' : 'Register'),
            ),
          ],
        ),
      ),
    );
  }
}
