import 'package:flutter/material.dart'; // подключаем базовые виджеты Flutter (по типу Scaffold, AppBar, Text, Column, Center, Icon, ListView)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/user_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState(); //
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<CommentWithUser> _comments = [];

  @override // тут мы изменяем родительский initState функцию
  void initState() {
    //метод, который вызывается при создании виджета
    super
        .initState(); //вызываем родительский initState, чтобы ничего не сломалось
    _loadComments(); // вызываем функцию по загрузке комментариев до того, как сформируется UI
  }

  Future<void> _loadComments() async {
    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(
          widget.post.postId,
        ); //создает объект DocumentReference, который указывает на документ в коллекции posts с ID, заданным в doc(widget.post.postId)

    final commentsSnapshot =
        await FirebaseFirestore.instance
            .collection('comments')
            .where(
              'postId',
              isEqualTo: postRef,
            ) // условие по которому мы ищем комментарии (возвращает список, как list rows)
            .get(); // функция которая помогает вернуть данные

    /*print(
      'commentsSnapshot содержит ${commentsSnapshot.docs.length} документов',
    ); commentsSnapshot.docs - список, в котором лежат данные, length - количество*/
    final loadedComments = await Future.wait(
      commentsSnapshot.docs.map((doc) => CommentWithUser.fromSnapshot(doc)),
    );

    setState(() {
      _comments = loadedComments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.post.description, style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Date of publication: ${widget.post.date.toLocal()}'),
            SizedBox(height: 24),
            Text('Comments:', style: TextStyle(fontWeight: FontWeight.bold)),
            user != null
                ? Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          _submitComment();
                        },
                      ),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'You must be logged in to write a comment.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return ListTile(
                    title: Text(comment.displayName),
                    subtitle: Text(comment.text),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitComment() async {
    final user = context.read<UserProvider>().user;

    if (user == null) {
      return;
    }

    final commentText = _commentController.text;

    if (commentText.isNotEmpty) {
      final commentData = {
        'userId': FirebaseFirestore.instance.collection('users').doc(user.uid),
        'postId': FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post.postId),
        'text': commentText,
        'date': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('comments').add(commentData);

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final userData = userDoc.data();

      final displayName = userData?['displayName'] ?? 'Unknown';

      final newComment = CommentWithUser(
        displayName: displayName,
        userId: user.uid,
        postId: widget.post.postId,
        text: commentText,
        date: DateTime.now(),
      );

      print('Comments added');

      setState(() {
        _comments.add(newComment);
      });

      _commentController.clear(); // очистка поля ввода
    }
  }
}


/* 
const PostDetailScreen({super.key, required this.post}) 
const - по сути устанавливаем константу для этого экрана и говорим, что этот виджет всегда будет одинаковым, 
не меняется — можешь заранее всё просчитать и не пересоздавать его лишний раз.
super.key — механизм, которые передаёт ключ наверх (родительскому классу)
второй аргумент (this.post) - это то, что мы потом будем показывать, допустим описание поста, его заголовок и т.п.

Padding - добавляет отступы вокруг содержимого 
Column - устанавливаем что все будет к колонку
EdgeInsets.all - это класс, который описывает отступы (сверху, снизу, слева, справа). all - говорит со всех сторон 
child — это просто один вложенный элемент внутри другого виджета. (ОДИН)
crossAxisAlignment - настройка как выравнивать child (по центру, слева, справа и т.п.)
children - много элементов, чтобы все работало на них, допустим у нас в колонке и текст и описание и картинка может быть  (МНОГО ЭЛЕМЕНТОВ)


Если элементы строятся динамически (и их количество может меняться) - тогда используется builder и внутри билдера используется itemBuilder по каждому элементу, будь хоть 1, хоть несколько 
сли элементы фиксированные и их много, то используем children
Сhild - нужно использовать только тогда, когда нужно вставить ровно один фиксированный элемент в ОБЕРТКУ (Container, Expanded, Padding, Center, и так далее).

Row - это виджет, который помогает размещать элементы(дочерние) горизонтально(в строчку)
TextField — это виджет для ввода текста, который позволяет пользователю вводить данные
controller - то что позволяет контролировать, что вводят 
decoration — это оформление
IconButton — это встроенный виджет, который представляет собой кнопку с иконкой
TextEditingController - устанавливаем, чтобы можно было управлять текстом из поля ввода
Future.wait — это позволяет запускать несколько Future параллельно и ждать, пока все они завершатся.

Работа с состоянием (StatefulWidget), т.е. когда у нас экран меняется динамически, в зависимости от каких-то данных
createState - создает состояние для виджета, т.е. для PostDetailScreen

После этого мы как бы должны работать непосредственное в "состояние", а не в самом виджете. Это звучит грубо, 
т.к. PostDetailScreen - это оболочка, а _PostDetailScreenState - это состояние, при изменение которого, происходят изменение в оболочке

widget - это переменная на сам виджет, т.е. на PostDetailScreen

var - это установление перменной, которая может быть переназначена
*/