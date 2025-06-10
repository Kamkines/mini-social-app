import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/post.dart';

class UserProvider extends ChangeNotifier {
  //расширяем класс ChangeNotifier классом UserProvider
  User? _user; // храним текущего пользователя
  late final Stream<User?>
  _authStateChanges; // Stream позволяет хранить изменениям в авторизации пользователя
  late final StreamSubscription<User?>
  _subscription; // подписка на поток (то, что говорит нам об изменениях и следит за ними)

  UserProvider() {
    // это конструктор
    _authStateChanges =
        FirebaseAuth.instance.authStateChanges(); // получаем поток авторизации
    _subscription = _authStateChanges.listen((User? user) {
      // подписываемся на поток авторизации (команда listen)
      setUser(user);
    });
  }

  void setUser(User? user) {
    _user = user; // устанавливаем значения по пользователю
    notifyListeners(); // уведомляем всех слушателей об изменение данных по пользователю
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

class CommentsProvider extends ChangeNotifier {
  final Map<String, List<CommentWithUser>> _cache =
      {}; // делаем переменную _cache с типом Map (словарь) в которую кладем объект string ключ и List это сам объект
  final Map<String, StreamSubscription<QuerySnapshot>> _subscriptions = {};

  void listenToComments(String postId) { // функция, которая "слушает" новые комментарии в Firestore и обновляет в кэш-базе
    if (_subscriptions.containsKey(postId)) return;

    print('🔥 Firestore запрашивает комментарии для поста $postId');
    final sub = FirebaseFirestore.instance
        .collection('comments')
        .where(
          'postId',
          isEqualTo: FirebaseFirestore.instance.collection('posts').doc(postId),
        ) //  это результат запроса к Firestore переменная для получения комментариев по postId (приходит в виде документа FireStore, который потом надо преобразовать)
        .snapshots()
        .listen((snapshot) async {
          final comments = await Future.wait( //переменная, в которой преобразуются из Firestore вида в обычный Flutter-вский вид
            snapshot.docs.map((doc) => CommentWithUser.fromSnapshot(doc)),
          );

          _cache[postId] = comments; //устанавливаем переменную в кэш
          notifyListeners();  //уведомляем всех слушателей об изменение данных по пользователю
        });

    _subscriptions[postId] = sub;
  }

  List<CommentWithUser>? getComments(String postId) { // получаем комментарии из кэша
    print('📦 Чтение из кэша: ${_cache[postId]?.length ?? 0} комментов');
    return _cache[postId];
  } // геттер, который получает список комментариев по postId из кэша
       
  void clearCache() {
    // очистка кэша
    _cache.clear();
    notifyListeners();
  }

  void cancelSubscription(String postId) {
    _subscriptions[postId]?.cancel();
    _subscriptions.remove(postId);
  }
}

/*
ChangeNotifier - внутренний класс во Flutter, который умеет хранить состояние (данные) и помогает слушать изменения этого состояния виджетам апки(вызывает метод notifyListeners(), чтобы уведомить об изменениях)
late final - будут инициализированы позже (в конструкторе), но один раз и навсегда (late - позже, final - один раз)

Все переменные _, т.к. мы устанавливаем неизменяемость user переменной и др. переменных в других частях приложениях, но читать и получать данные из этих переменных можем
*/
