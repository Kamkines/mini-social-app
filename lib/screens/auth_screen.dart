import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import '../providers/user_provider.dart';

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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        // функция используется для регистрации нового пользователя в Firebase с помощью email и пароля. Если почта есть уже в базе, то выйдет ошибка, если все хорошо, то создастся запись в Firebase
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = FirebaseAuth.instance.currentUser;
      context.read<UserProvider>().setUser(user); 
      /*
      context — это текущий "контекст" виджета
      read<UserProvider>() - получаем объект
      .setUser(user) — устанавливаем значение вручную (по функции из UserProvider)

      Вручную устанавливаем т.к. лучше для UI пользователя, чтобы была мгновенная реакция
      Если же реакция не нужна, то вручную устанавливать значение не надо и дополнять данные функции (авторизации/регистрации) не надо
      т.к. UserProvider уже работает с Firebase, а если в нем что-то меняется, то у меня будет authStateChanges ловить изменения и тянуть уже моему пользователю
      */

      final userData = {
        'displayName': 'Default name',
        'email': _emailController.text.trim(),
        'photoUrl': '',
        'createdAt': DateTime.now(),
      };

      if (user == null) {
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // устанавливаем значение для DocumentId
          .set(userData); // сохраняем данные в записи коллекции

      print('User signed up');

      _navigateHome();
    } catch (error) {
      String errorMessage = error.toString();
      errorMessage = errorMessage.replaceAll(RegExp(r'\[.*?\]'), '').trim();

      setState(() {
        _errorMessage = errorMessage;
      });

      _clearErrorAfterDelay();
    }
  }

  Future<void> _login() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        // функция используется для входа пользователя в приложение с использованием его email и пароля
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      context.read<UserProvider>().setUser(user);

      _navigateHome();
    } catch (error) {
      String errorMessage = error.toString();
      errorMessage = errorMessage.replaceAll(RegExp(r'\[.*?\]'), '').trim();

      setState(() {
        _errorMessage = errorMessage;
      });

      _clearErrorAfterDelay();
    }
  }

  _navigateHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _clearErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      // функция, которая работает как setTimeout
      if (mounted) {
        // переменная булевого типа, которая говорит, активен ли виджет(т.е. виджет в дереве или нет)
        setState(() {
          _errorMessage = '';
        });
      }
    });
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
