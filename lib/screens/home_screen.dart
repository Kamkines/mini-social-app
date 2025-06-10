import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';


import './post_detail_screen.dart';
import './auth_screen.dart';
import './post_create_screen.dart';
import '../models/post.dart';
import '../providers/provider.dart';


class HomeScreen extends StatelessWidget {
  //Это означает, что HomeScreen не будет иметь состояния, которое меняется по ходу работы приложения.
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      // контейнер для, благодаря которому происходит вся визуализация
      appBar: AppBar(
        title: Text('News feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
          ),
          if(user != null)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostCreateScreen()),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>( // StreamBuilder - это виджет с помощью которого можно автоматически переделывать интерфейс, когда данные обновляются (создаются, удаляются,обновляются). Грубо говорят это некий вебсокет, который слушает(подписан) на бд
      // QuerySnapshot  - это объект, который содержит результат запроса к Firestore.
        stream: // устанавливаем что надо слушать, поток данных
            FirebaseFirestore.instance
                .collection('posts') // название коллекции (таблицы)
                .orderBy('date', descending: true) // сортировка
                .snapshots(), // команда, которая возвращает поток (stream) из Firestore и помогает "слушать" изменения
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // пока подключаемся к бд (проверяем статус потока), показываем загрузочный экран 

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('There are no posts yet'));
          }
          // проверяем данные из бд, т.е. пустая ли бд, а именно поток ничего не принес

          // если данные есть, то происходит получаем именно данные по записям таблицы, лежат в docs и проходим по каждому
          // snapshot.data - это как раз QuerySnapshot
          final posts =
              snapshot.data!.docs.map((doc) {
                return Post.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              }).toList(); // Преобразование  .map(...) в обычный список List<Post> в нашем случае

          return ListView.builder(
            // ListView.builder - стандартный виджет для отображения списка, который ты должен использовать для создания списка с прокруткой.
            // builder - функция строящий новый экран
            itemCount: posts.length, // определяет, сколько элементов будет в списке
            itemBuilder: (context, index) { // помогает для каждого элемента отобразить данные
              final post = posts[index];
              return ListTile(
                title: Text(post.title),
                subtitle: Text(post.description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: post),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/* 
extends - расширять класс с помощью другого класса
StatelessWidget — это базовый класс, который предоставляет функциональность для безсостояния (stateless) виджетов. Виджеты в Flutter могут быть двух типов:
- Stateful (состояние) — виджет, который изменяется в процессе работы приложения.
- Stateless (без состояния) — виджет, который не меняется после того, как он был построен.


@override - механизм, благодаря которму происходит переопределение метода из родительского(основного класса), в примере метод build из класса StatelessWidget
Widget build(BuildContext context) — это метод, который отвечает за создание и отображение UI для этого виджета.
!!!!
в Flutter Widget — это тип данных, основной строительный блок пользовательского интерфейса (UI). Он описывает, как должен выглядеть интерфейс на экране и действия в нем или действия, которые могут изменять его
!!!!
BuildContext — это объект, который представляет контекст текущего состояния виджета. 
Он хранит информацию о том, где в дереве виджетов находится данный виджет, а также предоставляет доступ к окружающему состоянию. 

Scaffold - это основной контейнер, который визуализирует виджет
- AppBar  - то что наверху (верхняя панель с заголовками/кнопками)
- body - основная часть экрана, где могут распологаться другие виджеты (в примере это ListView)

builder — это механизм, который создаёт виджеты, когда это необходимо (по мере прокрутки), и помогает управлять списками и другими коллекциями элементов более эффективно. 
Это одна из ключевых особенностей Flutter для работы с длинными списками или сложными интерфейсами, где нужно эффективно работать с памятью.


Navigator.push — это команда Flutter'а перейти на новый экран (открывается поверх старой)
context — это информация о том, где в дереве виджетов мы находимся
MaterialPageRoute — это способ сказать Flutter'(«Открой новый экран с анимацией, как в стандартных приложениях для Android/iOS»)

*/
