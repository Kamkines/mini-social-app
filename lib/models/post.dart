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
}

class Post {
  final String postId;
  final String title;
  final String description;
  final DateTime date;
  final List<Comment> comments;

  Post({
    required this.postId,
    required this.title,
    required this.description,
    required this.date,
    required this.comments,
  });
}




/*
final - означает, что значение в переменной назначается всего ОДИН РАЗ (не дает переопределять)
Конструкция установление типизации данных похожа на constuctor
required - установление обязательности
List — это стандартная коллекция для хранения упорядоченных данных в Dart. Аналог массива в других языках программирования.
*/