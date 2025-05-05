import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String userId;
  final String postId;
  final String text;
  final DateTime date;

  Comment({
    required this.userId,
    required this.postId,
    required this.text,
    required this.date,
  });

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      userId: data['userId'] ?? '',
      postId: data['postId'] ?? '',
      text: data['text'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Post {
  String postId;
  String title;
  String description;
  DateTime date;

  Post({
    required this.postId,
    required this.title,
    required this.description,
    required this.date,
  });

  factory Post.fromMap(Map<String, dynamic> postData, String docId) {
    //docId - это запись post (document ID - по сути guid записи)
    return Post(
      postId: docId,
      title: postData['title'] ?? '',
      description: postData['description'] ?? '',
      date: (postData['date'] as Timestamp).toDate(),
    );
  }
}


/*
final - означает, что значение в переменной назначается всего ОДИН РАЗ (не дает переопределять)
Конструкция установление типизации данных похожа на constuctor
required - установление обязательности
List — это стандартная коллекция для хранения упорядоченных данных в Dart. Аналог массива в других языках программирования.

fromMap - это метод, который создает объект. Он берет словарь (Map (по типу объекта в JS(ключ-значение))) и извелкает из него значения 
Map<String, dynamic> - говорим, что у нас будет параметром входа словарь, где String - это тип ключа и dynamic - это различные типы данных у значений
data - это имя параметра которое мы даем полученному словарю
factory - тип конструктора, по сути это функция внутри класса, если сравнивать в JS, для более углубленной обработки
*/