import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String userId;
  final String postId;
  final String text;
  final DateTime date;
  final String? parentCommentId;

  Comment({
    required this.userId,
    required this.postId,
    required this.text,
    required this.date,
    this.parentCommentId,
  });

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      userId: (data['userId'] as DocumentReference?)?.id ?? '',
      postId: (data['postId'] as DocumentReference?)?.id ?? '',
      text: data['text'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      parentCommentId: (data['parentCommentId'] as DocumentReference?)?.id,
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

class CommentWithUser extends Comment {
  final String displayName;
  final String commentId;

  CommentWithUser({
    required this.commentId,
    required this.displayName,
    required super.userId,
    required super.postId,
    required super.text,
    required super.date,
    super.parentCommentId,
  });

  static Future<CommentWithUser> fromSnapshot(DocumentSnapshot doc) async {
    // Это статический асинхронный метод
    // static потому что мы вызываем его без создания экземпляра класса (мы как бы говорим, я ещё не создал CommentWithUser — сначала мне нужно из документа его собрать)
    // DocumentSnapshot — это одна запись из коллекции в Firestore.
    try {
      final data =
          doc.data() as Map<String, dynamic>; // получаем данные из comments
      final comment = Comment.fromMap(data); // преобразуем в Comment класс
      final userRef =
          data['userId']
              as DocumentReference; // ссылка на пользователя с типом DocumentReference(лукап)
      final userSnap = await userRef.get(); // получаем данные по users
      final userData =
          userSnap.data() as Map<String, dynamic>?; //преобразуем данные юзера
      final displayName =
          userData?['displayName'] ?? 'Unknown'; // получаем DisplayName

      return CommentWithUser(
        commentId: doc.id,
        displayName: displayName,
        userId: comment.userId,
        postId: comment.postId,
        text: comment.text,
        date: comment.date,
        parentCommentId: comment.parentCommentId,
      );
    } catch (error) {
      print('Ошибка при загрузке комментария: $error');
      return CommentWithUser(
        commentId: '',
        displayName: 'Ошибка',
        userId: '',
        postId: '',
        text: 'Не удалось загрузить комментарий',
        date: DateTime.now(),
        parentCommentId: '',
      );
    }
  }
}

class CommentNode {
  final CommentWithUser comment; // Сам комментарий
  final List<CommentNode> replies; // Список ответов (другие узлы)

  CommentNode({required this.comment, this.replies = const []}); // Конструктор с обязательным комментарием и опциональным списком ответов
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
