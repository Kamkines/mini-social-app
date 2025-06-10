import 'package:flutter/material.dart'; // подключаем базовые виджеты Flutter (по типу Scaffold, AppBar, Text, Column, Center, Icon, ListView)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/provider.dart';

class CommentTreeWidget extends StatelessWidget {
  // класс для отображения дерева комментарий
  final CommentNode node; // текущий комментарий и его ответы
  final int indentLevel; // уровень вложенности для отступов
  final Function(String?, String?) onReply; // ф-ция для обработки нажатия Reply

  const CommentTreeWidget({
    super.key, // Ключ для управления виджетом
    required this.node, // Обязательный параметр (комментарий)
    this.indentLevel = 0, // По умолчанию 0 (нет отступов)
    required this.onReply, // Обязательная функция обратного вызова
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // выравниванием текст слева
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0 * indentLevel),
          child: ListTile(
            title: Text(
              node.comment.displayName, // Имя пользователя
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node.comment.text), // Текст комментария
                Text(
                  node.comment.date.toLocal().toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                TextButton(
                  onPressed: () {
                    onReply(
                      node.comment.commentId,
                      node.comment.displayName,
                    ); // Вызов функции при нажатии "Reply"
                  },
                  child: const Text('Reply'),
                ),
              ],
            ),
          ),
        ),
        for (var reply in node.replies) // Цикл для отображения всех ответов
          CommentTreeWidget(
            node: reply, // Передаем следующий комментарий
            indentLevel: indentLevel + 1, // Увеличиваем уровень вложенности
            onReply: onReply, // Передаем функцию дальше
          ),
      ],
    );
  }
}

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isInit = true;

  String?
  _replyCommentId; //переменная , которая хранит в себе id коммента, на которым мы отвечаем
  String?
  _replyToDisplayName; //переменная , которая хранит в себе найм пользователя коммента, который его написал

  @override // тут мы изменяем родительский initState функцию
  void initState() {
    //метод, который вызывается при создании виджета
    super
        .initState(); //вызываем родительский initState, чтобы ничего не сломалось
  }

  List<CommentNode> buildCommentTree(List<CommentWithUser> comments) { // Построение дерева комментариев
    final Map<String, CommentNode> map = {}; // Хранит все комментарии с их ID как ключ
    final List<CommentNode> roots = []; // Список корневых комментариев

    for (var instanceComment in comments) { // Проходим по всем комментариям
      map[instanceComment.commentId] = CommentNode( // Создаем узел для каждого комментария
        comment: instanceComment, // Сам комментарий
        replies: [], // Пустой список ответов
      );
    }

    for (var instanceComment in comments) { // Проходим снова
      final parentId = instanceComment.parentCommentId; // ID родительского комментария
      if (parentId != null && map.containsKey(parentId)) { // Если есть родитель и он существует
        map[parentId]!.replies.add(map[instanceComment.commentId]!); // Добавляем как ответ
      } else { // Если нет родителя
        roots.add(map[instanceComment.commentId]!); // Добавляем в корневые
      }
    }

    return roots; // Возвращаем список корневых комментариев
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final provider = Provider.of<CommentsProvider>(context, listen: false);
      provider.listenToComments(widget.post.postId);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    Provider.of<CommentsProvider>(
      context,
      listen: false,
    ).cancelSubscription(widget.post.postId);
    _commentController.dispose(); // Очистка контроллера
    super.dispose();
  }

  void _setReply(String? commentId, String? displayName) { // Обновление состояния для ответа
    setState(() {
      _replyCommentId = commentId; // Устанавливаем ID комментария для ответа
      _replyToDisplayName = displayName; // Устанавливаем имя пользователя для отображения
    });
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
        'parentCommentId': FirebaseFirestore.instance
            .collection('comments')
            .doc(_replyCommentId),
      };

      await FirebaseFirestore.instance.collection('comments').add(commentData);
      print('Comments added');

      _commentController.clear(); // очистка поля ввода
      setState(() {
        _replyCommentId = null;
        _replyToDisplayName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    final commentsProvider = Provider.of<CommentsProvider>(context);
    final comments = commentsProvider.getComments(widget.post.postId);

    final commentTree = comments != null ? buildCommentTree(comments) : null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.post.description, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('Date of publication: ${widget.post.date.toLocal()}'),
            const SizedBox(height: 24),
            const Text(
              'Comments:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_replyToDisplayName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text('Replying to $_replyToDisplayName'),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _replyCommentId = null;
                                  _replyToDisplayName = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _submitComment,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'You must be logged in to write a comment.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            Expanded(
              child:
                  comments == null
                      ? const Center(child: CircularProgressIndicator())
                      : commentTree!.isEmpty
                      ? const Center(child: Text('No comments yet.'))
                      : ListView.builder(
                        itemCount: commentTree.length,
                        itemBuilder: (context, index) {
                          return CommentTreeWidget(
                            node: commentTree[index],
                            onReply: _setReply,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
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