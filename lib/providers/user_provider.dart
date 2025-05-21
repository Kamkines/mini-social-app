import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  //расширяем класс ChangeNotifier классом UserProvider
  User? _user; // храним текущего пользователя
  late final Stream<User?>
  _authStateChanges; // Stream позволяет хранить изменениям в авторизации пользователя
  late final StreamSubscription<User?>
  _subscription; // подписка на поток (то, что говорит нам об изменениях и следит за ними)

  UserProvider() { // это конструктор
    _authStateChanges =
        FirebaseAuth.instance.authStateChanges(); // получаем поток авторизации
    _subscription = _authStateChanges.listen((User? user) {
      // подписываемся на поток авторизации (команда listen)
      setUser(user);
    });
  }

  void setUser(User? user) { 
    _user = user; // устанавливаем значения по пользователю
    notifyListeners();  // уведомляем всех слушателей об изменение данных по пользователю
  }

  User? get user => _user; // геттер для получения данных пользователя

  bool get isLoggedIn =>
      _user != null; // геттер для получения залогинился ли пользователь или нет

  @override
  void dispose() {
    // метод из класса  ChangeNotifier, который уничтожает установленные объекты при закрытие апки
    _subscription.cancel(); // отписка от стрима, чтобы избежать утечку памяти
    super.dispose(); //нужен для вызова очистки у родительского класса
  }
}

/*
ChangeNotifier - внутренний класс во Flutter, который умеет хранить состояние (данные) и помогает слушать изменения этого состояния виджетам апки(вызывает метод notifyListeners(), чтобы уведомить об изменениях)
late final - будут инициализированы позже (в конструкторе), но один раз и навсегда (late - позже, final - один раз)

Все переменные _, т.к. мы устанавливаем неизменяемость user переменной и др. переменных в других частях приложениях, но читать и получать данные из этих переменных можем
*/
